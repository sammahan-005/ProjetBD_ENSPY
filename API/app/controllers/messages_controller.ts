import type { HttpContext } from '@adonisjs/core/http'
import Message from '#models/message'
import Conversation from '#models/conversation'
import { createMessageValidator } from '#validators/message'
import transmit from '@adonisjs/transmit/services/main'
import { DateTime } from 'luxon'

export default class MessagesController {
  /**
   * Envoyer un message dans une conversation
   */
  async store({ request, auth, response }: HttpContext) {
    const user = auth.getUserOrFail()
    const { conversationId, content, type, mediaUrl, replyToId } = await request.validateUsing(createMessageValidator)

    // Vérifier l'accès à la conversation
    const conversation = await Conversation.query()
      .where('conversId', conversationId)
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

    // Créer le message
    const message = await Message.create({
      senderId: user.alanyaId,
      conversationId,
      content,
      type,
      mediaUrl,
      replyToId: replyToId ? BigInt(replyToId) : null,
      sendAt: DateTime.now(),
      status: false, // Non lu
      isDeleted: false,
      isEdited: false,
    })

    // Mettre à jour la conversation
    conversation.lastMessage = content || (type === 2 ? '[Image]' : '[Média]')
    conversation.lastMessageAt = DateTime.now()
    conversation.unreadCount = (conversation.unreadCount || 0) + 1
    await conversation.save()

    // Charger les relations
    await message.load('sender')

    // Diffuser en temps réel via Transmit
    transmit.broadcast(`conversations/${conversationId}`, {
      event: 'message:new',
      message: message.toJSON(),
    })

    return message
  }

  /**
   * Marquer les messages d'une conversation comme lus
   */
  async markAsRead({ params, auth, response }: HttpContext) {
    const user = auth.getUserOrFail()
    const { conversationId } = params

    // Vérifier l'accès
    const conversation = await Conversation.query()
      .where('conversId', conversationId)
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

    // Mettre à jour les messages reçus non-lus
    await Message.query()
      .where('conversationId', conversationId)
      .whereNot('senderId', user.alanyaId)
      .where('status', false)
      .update({
        status: true,
        readAt: DateTime.now().toSQL(),
      })

    // Réinitialiser le compteur de non-lus
    conversation.unreadCount = 0
    await conversation.save()

    // Diffuser la lecture
    transmit.broadcast(`conversations/${conversationId}`, {
      event: 'message:read',
      userId: user.alanyaId,
    })

    return { success: true }
  }

  /**
   * Supprimer (ou masquer) un message
   */
  async destroy({ params, auth, response }: HttpContext) {
    const user = auth.getUserOrFail()
    const { id } = params

    const message = await Message.find(id)
    if (!message) {
      return response.notFound({ error: 'Message introuvable' })
    }

    // Seul l'expéditeur peut supprimer son message
    if (message.senderId !== user.alanyaId) {
      return response.forbidden({ error: 'Vous ne pouvez pas supprimer ce message' })
    }

    message.isDeleted = true
    message.content = 'Ce message a été supprimé'
    await message.save()

    // Diffuser la suppression
    transmit.broadcast(`conversations/${message.conversationId}`, {
      event: 'message:deleted',
      msgId: message.msgId,
    })

    return message
  }
}
