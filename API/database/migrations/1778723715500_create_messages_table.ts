import { BaseSchema } from '@adonisjs/lucid/schema'

export default class extends BaseSchema {
  protected tableName = 'messages'

  async up() {
    this.schema.createTable(this.tableName, (table) => {
      table.bigIncrements('msg_id').primary()
      table.integer('sender_id').unsigned().references('alanya_id').inTable('users').onDelete('CASCADE')
      table.bigint('conversation_id').unsigned().references('convers_id').inTable('conversations').onDelete('CASCADE')
      table.text('content').nullable()
      table.smallint('type').defaultTo(1) // 1: text, 2: image, etc.
      table.tinyint('status').defaultTo(0) // 0: sent, 1: delivered, 2: read
      table.timestamp('send_at').notNullable()
      table.timestamp('read_at').nullable()
      table.string('media_url').nullable()
      table.boolean('is_deleted').defaultTo(false)
      table.boolean('is_edited').defaultTo(false)
      table.bigint('reply_to_id').nullable()

      table.timestamp('created_at')
      table.timestamp('updated_at')
    })
  }

  async down() {
    this.schema.dropTable(this.tableName)
  }
}