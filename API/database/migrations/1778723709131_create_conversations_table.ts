import { BaseSchema } from '@adonisjs/lucid/schema'

export default class extends BaseSchema {
  protected tableName = 'conversations'

  async up() {
    this.schema.createTable(this.tableName, (table) => {
      table.bigIncrements('convers_id').primary()
      table.integer('participant_id').unsigned().references('alanya_id').inTable('users').onDelete('CASCADE')
      table.boolean('is_group').defaultTo(false)
      table.string('group_name').nullable()
      table.string('group_photo').nullable()
      table.text('last_message').nullable()
      table.timestamp('last_message_at').nullable()
      table.boolean('is_pinned').defaultTo(false)
      table.boolean('is_archived').defaultTo(false)
      table.smallint('unread_count').defaultTo(0)

      table.timestamp('created_at')
      table.timestamp('updated_at')
    })
  }

  async down() {
    this.schema.dropTable(this.tableName)
  }
}