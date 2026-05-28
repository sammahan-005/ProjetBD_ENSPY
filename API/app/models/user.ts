import { UserSchema } from '#database/schema'
import hash from '@adonisjs/core/services/hash'
import { compose } from '@adonisjs/core/helpers'
import { withAuthFinder } from '@adonisjs/auth/mixins/lucid'
import { type AccessToken, DbAccessTokensProvider } from '@adonisjs/auth/access_tokens'
import { belongsTo, hasMany } from '@adonisjs/lucid/orm'
import type { BelongsTo, HasMany } from '@adonisjs/lucid/types/relations'
import Pays from '#models/pay'
import PreferredContact from '#models/preferred_contact'
import Blocked from '#models/blocked'
import Statut from '#models/statut'
import Message from '#models/message'

export default class User extends compose(UserSchema, withAuthFinder(hash, { uids: ['alanyaPhone'] })) {
  static accessTokens = DbAccessTokensProvider.forModel(User)
  declare currentAccessToken?: AccessToken

  /**
   * Auth configuration
   */
  static uids = ['alanyaPhone']

  @belongsTo(() => Pays, {
    foreignKey: 'idPays',
  })
  declare pays: BelongsTo<typeof Pays>

  @hasMany(() => PreferredContact, {
    foreignKey: 'alanyaId',
  })
  declare preferredContacts: HasMany<typeof PreferredContact>

  @hasMany(() => Blocked, {
    foreignKey: 'alanyaId',
  })
  declare blockedUsers: HasMany<typeof Blocked>

  @hasMany(() => Statut, {
    foreignKey: 'alanyaId',
  })
  declare statuts: HasMany<typeof Statut>

  @hasMany(() => Message, {
    foreignKey: 'senderId',
  })
  declare messages: HasMany<typeof Message>

  get initials() {
    const [first, last] = this.nom ? this.nom.split(' ') : [this.pseudo, '']
    if (first && last) {
      return `${first.charAt(0)}${last.charAt(0)}`.toUpperCase()
    }
    return `${first.slice(0, 2)}`.toUpperCase()
  }
}
