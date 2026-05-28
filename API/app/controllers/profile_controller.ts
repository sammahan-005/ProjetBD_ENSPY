import UserTransformer from '#transformers/user_transformer'
import type { HttpContext } from '@adonisjs/core/http'
import User from '#models/user'
import vine from '@vinejs/vine'

export default class ProfileController {
  async show({ auth, serialize }: HttpContext) {
    return serialize(UserTransformer.transform(auth.getUserOrFail()))
  }

  async index({ auth, request, serialize }: HttpContext) {
    const currentUser = auth.getUserOrFail()
    const q = request.input('q', '').trim()

    const query = User.query().whereNot('alanya_id', currentUser.alanyaId)

    if (q.length > 0) {
      query.where((builder) => {
        builder.where('pseudo', 'like', `%${q}%`).orWhere('nom', 'like', `%${q}%`)
      })
    }

    const users = await query.limit(20)
    return serialize(UserTransformer.transform(users))
  }

  async update({ auth, request, serialize }: HttpContext) {
    const user = auth.getUserOrFail()

    const validator = vine.compile(
      vine.object({
        nom: vine.string().maxLength(60).optional(),
        pseudo: vine.string().maxLength(80).optional(),
        avatarUrl: vine.string().maxLength(255).nullable().optional(),
      })
    )

    const payload = await request.validateUsing(validator)

    if (payload.nom !== undefined) user.nom = payload.nom
    if (payload.pseudo !== undefined) user.pseudo = payload.pseudo
    if (payload.avatarUrl !== undefined) user.avatarUrl = payload.avatarUrl

    await user.save()

    return serialize(UserTransformer.transform(user))
  }
}
