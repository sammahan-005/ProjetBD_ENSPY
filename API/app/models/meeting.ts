import { MeetingSchema } from '#database/schema'
import { belongsTo, hasMany } from '@adonisjs/lucid/orm'
import type { BelongsTo, HasMany } from '@adonisjs/lucid/types/relations'
import User from '#models/user'
import Participant from '#models/participant'

export default class Meeting extends MeetingSchema {
  @belongsTo(() => User, {
    foreignKey: 'idOrganiser',
  })
  declare organiser: BelongsTo<typeof User>

  @hasMany(() => Participant, {
    foreignKey: 'idMeeting',
  })
  declare participants: HasMany<typeof Participant>
}