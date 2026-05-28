import type { HttpContext } from '@adonisjs/core/http'
import CallHistory from '#models/call_history'
import User from '#models/user'
import transmit from '@adonisjs/transmit/services/main'
import vine from '@vinejs/vine'
import { DateTime } from 'luxon'

export default class CallsController {
  /**
   * Récupérer l'historique d'appels de l'utilisateur
   */
  async index({ auth }: HttpContext) {
    const user = auth.getUserOrFail()

    const calls = await CallHistory.query()
      .where('idCaller', user.alanyaId)
      .orWhere('idReceiver', user.alanyaId)
      .preload('caller')
      .preload('receiver')
      .orderBy('startTime', 'desc')

    return calls
  }

  /**
   * Initier un appel (Génère l'historique et signale le destinataire)
   */
  async store({ request, auth, response }: HttpContext) {
    const user = auth.getUserOrFail()

    const validator = vine.compile(
      vine.object({
        idReceiver: vine.number(),
        type: vine.number().optional(), // 1: Audio, 2: Vidéo
      })
    )

    const { idReceiver, type } = await request.validateUsing(validator)

    // Vérifier si le destinataire existe et n'est pas soi-même
    if (idReceiver === user.alanyaId) {
      return response.badRequest({ error: 'Vous ne pouvez pas vous appeler vous-même' })
    }

    const receiver = await User.find(idReceiver)
    if (!receiver) {
      return response.notFound({ error: 'Destinataire introuvable' })
    }

    // Créer l'appel
    const call = await CallHistory.create({
      idCaller: user.alanyaId,
      idReceiver,
      type: type || 1,
      status: 1, // 1: Calling (en cours de sonnerie)
      startTime: DateTime.now() as any,
    })

    await call.load('caller')
    await call.load('receiver')

    // Signaler le destinataire via son canal personnel de Transmit
    transmit.broadcast(`users/${idReceiver}`, {
      event: 'calls:incoming',
      call: call.toJSON(),
    })

    return call
  }

  /**
   * Mettre à jour le statut de l'appel (Décrocher, Rejeter, Raccrocher)
   */
  async update({ params, request, auth, response }: HttpContext) {
    const user = auth.getUserOrFail()
    const { id } = params // idCall

    const validator = vine.compile(
      vine.object({
        status: vine.number(), // 2: Accepté/Décroché, 3: Rejeté, 4: Terminé
        duree: vine.number().optional(), // en secondes
      })
    )

    const { status, duree } = await request.validateUsing(validator)

    const call = await CallHistory.find(id)
    if (!call) {
      return response.notFound({ error: 'Appel introuvable' })
    }

    // Vérifier que l'utilisateur fait partie de l'appel
    if (call.idCaller !== user.alanyaId && call.idReceiver !== user.alanyaId) {
      return response.forbidden({ error: 'Accès refusé' })
    }

    call.status = status
    if (duree !== undefined) {
      call.duree = duree
    }
    await call.save()

    await call.load('caller')
    await call.load('receiver')

    // Notifier l'autre participant
    const targetId = call.idCaller === user.alanyaId ? call.idReceiver : call.idCaller
    transmit.broadcast(`users/${targetId}`, {
      event: 'calls:status_updated',
      call: call.toJSON(),
    })

    return call
  }

  /**
   * Route de signalisation WebRTC pour transmettre les SDP et ICE candidates
   */
  async signal({ request, auth, response }: HttpContext) {
    const user = auth.getUserOrFail()

    const validator = vine.compile(
      vine.object({
        targetUserId: vine.number(),
        signalData: vine.any(), // Objet SDP (offer/answer) ou ICE Candidate
      })
    )

    const { targetUserId, signalData } = await request.validateUsing(validator)

    // Diffuser le signal en temps réel au destinataire cible via Transmit
    transmit.broadcast(`users/${targetUserId}`, {
      event: 'calls:signal',
      senderId: user.alanyaId,
      signalData,
    })

    return response.ok({ success: true })
  }
}
