import type { HttpContext } from '@adonisjs/core/http'
import PreferredContact from '#models/preferred_contact'
import User from '#models/user'
import UserTransformer from '#transformers/user_transformer'
import vine from '@vinejs/vine'

export default class ContactsController {
  /**
   * Lister tous mes contacts préférés avec leurs infos utilisateur
   */
  async index({ auth, serialize }: HttpContext) {
    const user = auth.getUserOrFail()

    const contacts = await PreferredContact.query()
      .where('alanyaId', user.alanyaId)
      .preload('friend')

    return serialize(
      contacts.map((c) => ({
        idPrefContact: c.idPrefContact,
        friend: c.friend ? UserTransformer.transform(c.friend) : null,
      }))
    )
  }

  /**
   * Ajouter un contact préféré
   */
  async store({ request, auth, response, serialize }: HttpContext) {
    const user = auth.getUserOrFail()

    const validator = vine.compile(
      vine.object({
        idFriend: vine.number(),
      })
    )

    const { idFriend } = await request.validateUsing(validator)

    // Vérifier qu'on ne s'ajoute pas soi-même
    if (idFriend === user.alanyaId) {
      return response.badRequest({ error: 'Vous ne pouvez pas vous ajouter vous-même' })
    }

    // Vérifier que l'utilisateur cible existe
    const friend = await User.find(idFriend)
    if (!friend) {
      return response.notFound({ error: 'Utilisateur introuvable' })
    }

    // Vérifier si le contact existe déjà
    const existing = await PreferredContact.query()
      .where('alanyaId', user.alanyaId)
      .where('idFriend', idFriend)
      .first()

    if (existing) {
      return response.conflict({ error: 'Ce contact est déjà dans votre liste' })
    }

    const contact = await PreferredContact.create({
      alanyaId: user.alanyaId,
      idFriend,
    })

    await contact.load('friend')

    return serialize({
      idPrefContact: contact.idPrefContact,
      friend: contact.friend ? UserTransformer.transform(contact.friend) : null,
    })
  }

  /**
   * Supprimer un contact préféré
   */
  async destroy({ params, auth, response }: HttpContext) {
    const user = auth.getUserOrFail()
    const { id } = params

    const contact = await PreferredContact.query()
      .where('idPrefContact', id)
      .where('alanyaId', user.alanyaId)
      .first()

    if (!contact) {
      return response.notFound({ error: 'Contact introuvable' })
    }

    await contact.delete()

    return { success: true }
  }
}
