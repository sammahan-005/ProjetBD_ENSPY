import { PreferredContactSchema } from '#database/schema'
import { belongsTo } from '@adonisjs/lucid/orm'
import type { BelongsTo } from '@adonisjs/lucid/types/relations'
import User from '#models/user'

export default class PreferredContact extends PreferredContactSchema {
  @belongsTo(() => User, {
    foreignKey: 'idFriend',
  })
  declare friend: BelongsTo<typeof User>
}