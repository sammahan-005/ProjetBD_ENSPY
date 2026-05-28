import { ParticipantSchema } from '#database/schema'
import { belongsTo } from '@adonisjs/lucid/orm'
import type { BelongsTo } from '@adonisjs/lucid/types/relations'
import Meeting from '#models/meeting'
import User from '#models/user'

export default class Participant extends ParticipantSchema {
  @belongsTo(() => Meeting, {
    foreignKey: 'idMeeting',
  })
  declare meeting: BelongsTo<typeof Meeting>

  @belongsTo(() => User, {
    foreignKey: 'idParticipant',
  })
  declare user: BelongsTo<typeof User>
}