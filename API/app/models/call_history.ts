import { CallHistorySchema } from '#database/schema'
import { belongsTo } from '@adonisjs/lucid/orm'
import type { BelongsTo } from '@adonisjs/lucid/types/relations'
import User from '#models/user'

export default class CallHistory extends CallHistorySchema {
  @belongsTo(() => User, {
    foreignKey: 'idCaller',
  })
  declare caller: BelongsTo<typeof User>

  @belongsTo(() => User, {
    foreignKey: 'idReceiver',
  })
  declare receiver: BelongsTo<typeof User>
}