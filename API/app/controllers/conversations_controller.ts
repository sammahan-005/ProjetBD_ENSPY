import type { HttpContext } from '@adonisjs/core/http'
import Conversation from '#models/conversation'
import User from '#models/user'
import Message from '#models/message'
import vine from '@vinejs/vine'
import { DateTime } from 'luxon'

export default class ConversationsController {
  /**
   * Lister toutes les conversations de l'utilisateur connecté
   */
  async index({ auth }: HttpContext) {
    const user = auth.getUserOrFail()

    // Récupérer les conversations créées pour ce user ou où il participe
    const conversations = await Conversation.query()
      .where('participantId', user.alanyaId)
      .orWhereHas('participants', (builder) => {
        builder.where('users.alanya_id', user.alanyaId)
      })
      .preload('participants')
      .orderBy('lastMessageAt', 'desc')

    // Calculer le vrai nombre de messages non-lus pour l'utilisateur actuel
    for (const conv of conversations) {
      const countResult = await Message.query()
        .where('conversationId', conv.conversId)
        .whereNot('senderId', user.alanyaId)
        .where('status', false)
        .count('* as total')
      conv.unreadCount = Number(countResult[0].$extras.total || 0)
    }

    return conversations
  }

  /**
   * Créer une nouvelle conversation (Direct Message ou Groupe)
   */
  async store({ request, auth, response }: HttpContext) {
    try {
      const user = auth.getUserOrFail()

      const validator = vine.compile(
        vine.object({
          isGroup: vine.boolean().optional(),
          groupName: vine.string().maxLength(255).optional(),
          groupPhoto: vine.string().maxLength(255).optional(),
          participantId: vine.number().optional(), // Pour DM
          participantIds: vine.array(vine.number()).optional(), // Pour Groupe
        })
      )

      const payload = await request.validateUsing(validator)
      const isGroup = payload.isGroup || false

      if (isGroup) {
        if (!payload.groupName) {
          return response.badRequest({ error: 'Le nom du groupe est requis' })
        }

        const conversation = await Conversation.create({
          isGroup: true,
          groupName: payload.groupName,
          groupPhoto: payload.groupPhoto || null,
          lastMessageAt: DateTime.now(),
        })

        // Attacher les participants
        const ids = payload.participantIds || []
        if (!ids.includes(user.alanyaId)) {
          ids.push(user.alanyaId)
        }

        await conversation.related('participants').attach(ids)
        await conversation.load('participants')

        return conversation
      } else {
        if (!payload.participantId) {
          return response.badRequest({ error: 'Le participant_id est requis pour un DM' })
        }

        // Vérifier si le destinataire existe
        const recipient = await User.find(payload.participantId)
        if (!recipient) {
          return response.notFound({ error: 'Utilisateur destinataire introuvable' })
        }

        // Vérifier si une conversation DM existe déjà entre les deux utilisateurs
        let conversation = await Conversation.query()
          .where('isGroup', false)
          .whereHas('participants', (builder) => {
            builder.where('users.alanya_id', user.alanyaId)
          })
          .whereHas('participants', (builder) => {
            builder.where('users.alanya_id', payload.participantId!)
          })
          .first()

        if (conversation) {
          await conversation.load('participants')
          return conversation
        }

        // Sinon, la créer
        conversation = await Conversation.create({
          isGroup: false,
          participantId: payload.participantId,
          lastMessageAt: DateTime.now(),
        })

        // Attacher les deux participants dans la table pivot
        await conversation.related('participants').attach([user.alanyaId, payload.participantId])
        await conversation.load('participants')

        return conversation
      }
    } catch (error) {
      console.error("ERROR IN STORE:", error);
      return response.internalServerError({ error: error.message, stack: error.stack })
    }
  }

  /**
   * Récupérer les messages d'une conversation avec pagination
   */
  async show({ params, request, auth, response }: HttpContext) {
    const user = auth.getUserOrFail()
    const { id } = params
    const page = request.input('page', 1)

    // Vérifier l'accès
    const conversation = await Conversation.query()
      .where('conversId', id)
      .andWhere((query) => {
        query
          .where('participantId', user.alanyaId)
          .orWhereHas('participants', (builder) => {
            builder.where('users.alanya_id', user.alanyaId)
          })
      })
      .first()

    if (!conversation) {
      return response.forbidden({ error: 'Accès refusé ou conversation introuvable' })
    }

    const messages = await Message.query()
      .where('conversationId', id)
      .preload('sender')
      .orderBy('sendAt', 'desc')
      .paginate(page, 30)

    return messages
  }
}
