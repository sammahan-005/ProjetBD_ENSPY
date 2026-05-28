import { StatusViewSchema } from '#database/schema'
import { belongsTo } from '@adonisjs/lucid/orm'
import type { BelongsTo } from '@adonisjs/lucid/types/relations'
import User from '#models/user'
import Statut from '#models/statut'

export default class StatusView extends StatusViewSchema {
  @belongsTo(() => Statut, {
    foreignKey: 'statusId',
  })
  declare status: BelongsTo<typeof Statut>

  @belongsTo(() => User, {
    foreignKey: 'userId',
  })
  declare user: BelongsTo<typeof User>
}
