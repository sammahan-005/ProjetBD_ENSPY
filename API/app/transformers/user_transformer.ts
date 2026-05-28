import type User from '#models/user'
import { BaseTransformer } from '@adonisjs/core/transformers'

export default class UserTransformer extends BaseTransformer<User> {
  toObject() {
    return this.pick(this.resource, [
      'alanyaId',
      'nom',
      'pseudo',
      'alanyaPhone',
      'idPays',
      'avatarUrl',
      'typeCompte',
      'isOnline',
      'lastSeen',
      'exclus',
      'inCall',
      'biometric',
      'fcmToken',
      'deviceId',
      'createdAt',
      'updatedAt',
      'initials',
    ])
  }
}
