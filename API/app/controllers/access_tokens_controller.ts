import User from '#models/user'
import { loginValidator } from '#validators/user'
import type { HttpContext } from '@adonisjs/core/http'
import UserTransformer from '#transformers/user_transformer'

export default class AccessTokensController {
  async store({ request, serialize }: HttpContext) {
    const { alanyaPhone, password } = await request.validateUsing(loginValidator)

    const user = await User.verifyCredentials(alanyaPhone, password)
    const token = await User.accessTokens.create(user)

    return serialize({
      user: UserTransformer.transform(user),
      token: token.value!.release(),
    })
  }

  async checkPhone({ request, response }: HttpContext) {
    const { alanyaPhone } = request.only(['alanyaPhone'])
    if (!alanyaPhone) {
      return response.badRequest({ error: 'Le numéro de téléphone est requis' })
    }
    const user = await User.findBy('alanyaPhone', alanyaPhone)
    return { exists: !!user }
  }

  async destroy({ auth }: HttpContext) {
    const user = auth.getUserOrFail()
    if (user.currentAccessToken) {
      await User.accessTokens.delete(user, user.currentAccessToken.identifier)
    }

    return {
      message: 'Logged out successfully',
    }
  }
}
