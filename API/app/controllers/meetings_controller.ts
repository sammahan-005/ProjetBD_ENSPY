import type { HttpContext } from '@adonisjs/core/http'
import Meeting from '#models/meeting'
import Participant from '#models/participant'
import transmit from '@adonisjs/transmit/services/main'
import vine from '@vinejs/vine'

export default class MeetingsController {
  /**
   * Lister tous les meetings actifs
   */
  async index() {
    const meetings = await Meeting.query()
      .where('isEnd', false)
      .preload('organiser')
      .preload('participants', (b) => b.preload('user'))
      .orderBy('startTime', 'desc')

    return meetings
  }

  /**
   * Créer une nouvelle visioconférence (room de meeting)
   */
  async store({ request, auth }: HttpContext) {
    const user = auth.getUserOrFail()

    const validator = vine.compile(
      vine.object({
        objet: vine.string().maxLength(255),
        typeMedia: vine.boolean().optional(), // true: Vidéo + Audio, false: Audio uniquement
      })
    )

    const { objet, typeMedia } = await request.validateUsing(validator)

    // Générer une room unique
    const room = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15)

    const meeting = await Meeting.create({
      idOrganiser: user.alanyaId,
      objet,
      room,
      typeMedia: typeMedia === undefined ? true : typeMedia,
      isEnd: false,
      startTime: new Date() as any,
    })

    await meeting.load('organiser')
    return meeting
  }

  /**
   * Rejoindre un meeting
   */
  async join({ params, auth, response }: HttpContext) {
    const user = auth.getUserOrFail()
    const { id } = params // idMeeting

    const meeting = await Meeting.find(id)
    if (!meeting || meeting.isEnd) {
      return response.notFound({ error: 'Meeting introuvable ou déjà terminé' })
    }

    // Vérifier si déjà participant
    let participant = await Participant.query()
      .where('idMeeting', id)
      .where('idParticipant', user.alanyaId)
      .first()

    if (participant) {
      participant.connecte = true
      participant.startTime = new Date() as any
      await participant.save()
    } else {
      participant = await Participant.create({
        idMeeting: Number(id),
        idParticipant: user.alanyaId,
        connecte: true,
        status: true,
        startTime: new Date() as any,
      })
    }

    await participant.load('user')

    // Notifier la room du meeting via Transmit
    transmit.broadcast(`meetings/${meeting.room}`, {
      event: 'meetings:participant_joined',
      participant: participant.toJSON(),
    })

    return participant
  }

  /**
   * Quitter un meeting
   */
  async leave({ params, auth, response }: HttpContext) {
    const user = auth.getUserOrFail()
    const { id } = params // idMeeting

    const meeting = await Meeting.find(id)
    if (!meeting) {
      return response.notFound({ error: 'Meeting introuvable' })
    }

    const participant = await Participant.query()
      .where('idMeeting', id)
      .where('idParticipant', user.alanyaId)
      .first()

    if (!participant) {
      return response.notFound({ error: 'Vous ne faites pas partie de ce meeting' })
    }

    // Calculer la durée passée dans le meeting
    const leaveTime = new Date()
    const entryTime = new Date(participant.startTime as any)
    const sessionDuree = Math.round((leaveTime.getTime() - entryTime.getTime()) / 1000) // en secondes

    participant.connecte = false
    participant.duree = (participant.duree || 0) + sessionDuree
    await participant.save()

    await participant.load('user')

    // Notifier la room
    transmit.broadcast(`meetings/${meeting.room}`, {
      event: 'meetings:participant_left',
      participant: participant.toJSON(),
    })

    return { success: true }
  }

  /**
   * Clore définitivement le meeting (Organisateur uniquement)
   */
  async end({ params, auth, response }: HttpContext) {
    const user = auth.getUserOrFail()
    const { id } = params

    const meeting = await Meeting.find(id)
    if (!meeting) {
      return response.notFound({ error: 'Meeting introuvable' })
    }

    if (meeting.idOrganiser !== user.alanyaId) {
      return response.forbidden({ error: 'Seul l’organisateur peut clore ce meeting' })
    }

    meeting.isEnd = true
    // Calculer la durée totale
    const now = new Date()
    const start = new Date(meeting.startTime as any)
    meeting.duree = Math.round((now.getTime() - start.getTime()) / 1000)
    await meeting.save()

    // Déconnecter tous les participants actifs
    await Participant.query()
      .where('idMeeting', id)
      .update({ connecte: false })

    // Notifier la room que le meeting est clos
    transmit.broadcast(`meetings/${meeting.room}`, {
      event: 'meetings:ended',
      meetingId: meeting.idMeeting,
    })

    return meeting
  }
}
