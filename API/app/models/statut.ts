import { StatutSchema } from '#database/schema'
import { belongsTo, hasMany } from '@adonisjs/lucid/orm'
import type { BelongsTo, HasMany } from '@adonisjs/lucid/types/relations'
import User from '#models/user'
import StatusView from '#models/status_view'
import StatusLike from '#models/status_like'

export default class Statut extends StatutSchema {
  @belongsTo(() => User, {
    foreignKey: 'alanyaId',
  })
  declare author: BelongsTo<typeof User>

  @hasMany(() => StatusView, {
    foreignKey: 'statusId',
  })
  declare views: HasMany<typeof StatusView>

  @hasMany(() => StatusLike, {
    foreignKey: 'statusId',
  })
  declare likes: HasMany<typeof StatusLike>
}