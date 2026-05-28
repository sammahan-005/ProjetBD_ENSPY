import { GroupParticipantSchema } from '#database/schema'
import { belongsTo } from '@adonisjs/lucid/orm'
import type { BelongsTo } from '@adonisjs/lucid/types/relations'
import User from '#models/user'
import Conversation from '#models/conversation'

export default class GroupParticipant extends GroupParticipantSchema {
  @belongsTo(() => Conversation, {
    foreignKey: 'conversId',
  })
  declare conversation: BelongsTo<typeof Conversation>

  @belongsTo(() => User, {
    foreignKey: 'userId',
  })
  declare user: BelongsTo<typeof User>
}
