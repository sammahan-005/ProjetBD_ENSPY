import type { HttpContext } from '@adonisjs/core/http'
import Statut from '#models/statut'
import PreferredContact from '#models/preferred_contact'
import StatusView from '#models/status_view'
import StatusLike from '#models/status_like'
import vine from '@vinejs/vine'
import { DateTime } from 'luxon'

export default class StatutsController {
  /**
   * Récupérer les statuts récents non expirés des contacts préférés
   */
  async index({ auth }: HttpContext) {
    const user = auth.getUserOrFail()

    // 1. Mes contacts préférés
    const myContacts = await PreferredContact.query().where('alanyaId', user.alanyaId)
    const myContactIds = myContacts.map((f) => f.idFriend).filter(Boolean) as number[]

    // 2. Parmi mes contacts, ceux qui m'ont aussi ajouté (réciprocité)
    const mutualContacts = await PreferredContact.query()
      .whereIn('alanyaId', myContactIds.length > 0 ? myContactIds : [-1])
      .where('idFriend', user.alanyaId)
    const mutualIds = mutualContacts.map((f) => f.alanyaId).filter(Boolean) as number[]

    // 3. Inclure toujours soi-même
    mutualIds.push(user.alanyaId)

    // 4. Récupérer les statuts actifs (< 24h) des contacts mutuels
    const statuts = await Statut.query()
      .whereIn('alanya_id', mutualIds)
      .preload('author')
      .preload('views', (b) => b.preload('user'))
      .preload('likes', (b) => b.preload('user'))
      .orderBy('createdAt', 'desc')

    console.log("STATUTS RETURNED FOR", user.alanyaId, ":", statuts.map(s => s.toJSON()))

    return statuts
  }

  /**
   * Publier un statut
   */
  async store({ request, auth, response }: HttpContext) {
    try {
      const user = auth.getUserOrFail()

      const validator = vine.compile(
        vine.object({
          type: vine.number().optional(), // 1: Text, 2: Image/Vidéo
          text: vine.string().maxLength(1000).optional(),
          mediaUrl: vine.string().maxLength(255).optional(),
          backgroundColor: vine.string().maxLength(20).optional(),
        })
      )

      const payload = await request.validateUsing(validator)

      // Expire dans 24 heures
      const expiresAt = DateTime.now().plus({ hours: 24 })

      const statut = await Statut.create({
        alanyaId: user.alanyaId,
        type: payload.type || 1,
        text: payload.text,
        mediaUrl: payload.mediaUrl,
        backgroundColor: payload.backgroundColor,
        expiresAt: expiresAt,
        viewedBy: 0,
        likedBy: 0,
      })

      await statut.load('author')
      return statut
    } catch (e) {
      console.error('ERROR IN STATUT STORE:', e);
      return response.internalServerError({ error: e.message, stack: e.stack });
    }
  }

  /**
   * Enregistrer une vue sur un statut
   */
  async view({ params, auth, response }: HttpContext) {
    const user = auth.getUserOrFail()
    const { id } = params

    const statut = await Statut.find(id)
    if (!statut) {
      return response.notFound({ error: 'Statut introuvable' })
    }

    // Vérifier si déjà vu
    const existingView = await StatusView.query()
      .where('statusId', id)
      .where('userId', user.alanyaId)
      .first()

    if (!existingView) {
      await StatusView.create({
        statusId: Number(id),
        userId: user.alanyaId,
      })

      // Mettre à jour le compteur sur le statut
      statut.viewedBy = (statut.viewedBy || 0) + 1
      await statut.save()
    }

    return { success: true }
  }

  /**
   * Liker / Unliker un statut
   */
  async like({ params, auth, response }: HttpContext) {
    const user = auth.getUserOrFail()
    const { id } = params

    const statut = await Statut.find(id)
    if (!statut) {
      return response.notFound({ error: 'Statut introuvable' })
    }

    // Vérifier si déjà aimé
    const existingLike = await StatusLike.query()
      .where('statusId', id)
      .where('userId', user.alanyaId)
      .first()

    if (existingLike) {
      // Retirer le like
      await existingLike.delete()
      statut.likedBy = Math.max(0, (statut.likedBy || 0) - 1)
      await statut.save()
      return { liked: false }
    } else {
      // Ajouter le like
      await StatusLike.create({
        statusId: Number(id),
        userId: user.alanyaId,
      })
      statut.likedBy = (statut.likedBy || 0) + 1
      await statut.save()
      return { liked: true }
    }
  }
}
