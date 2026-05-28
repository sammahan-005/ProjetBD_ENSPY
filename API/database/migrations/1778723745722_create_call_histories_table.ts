import { BaseSchema } from '@adonisjs/lucid/schema'

export default class extends BaseSchema {
  protected tableName = 'call_histories'

  async up() {
    this.schema.createTable(this.tableName, (table) => {
      table.bigIncrements('id_call').primary()
      table.integer('id_caller').unsigned().references('alanya_id').inTable('users').onDelete('CASCADE')
      table.integer('id_receiver').unsigned().references('alanya_id').inTable('users').onDelete('CASCADE')
      table.smallint('type').defaultTo(1) // 1: audio, 2: video
      table.smallint('status').defaultTo(1) // 1: missed, 2: accepted, etc.
      table.timestamp('start_time').nullable()
      table.integer('duree').defaultTo(0)

      table.timestamp('created_at')
      table.timestamp('updated_at')
    })
  }

  async down() {
    this.schema.dropTable(this.tableName)
  }
}