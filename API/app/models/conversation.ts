import { ConversationSchema } from '#database/schema'
import { hasMany, manyToMany } from '@adonisjs/lucid/orm'
import type { HasMany, ManyToMany } from '@adonisjs/lucid/types/relations'
import Message from '#models/message'
import User from '#models/user'

export default class Conversation extends ConversationSchema {
  @hasMany(() => Message, {
    foreignKey: 'conversationId',
  })
  declare messages: HasMany<typeof Message>

  @manyToMany(() => User, {
    pivotTable: 'group_participants',
    localKey: 'conversId',
    pivotForeignKey: 'convers_id',
    relatedKey: 'alanyaId',
    pivotRelatedForeignKey: 'user_id',
  })
  declare participants: ManyToMany<typeof User>
}