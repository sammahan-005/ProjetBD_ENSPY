import { BaseSchema } from '@adonisjs/lucid/schema'

export default class extends BaseSchema {
  protected tableName = 'participants'

  async up() {
    this.schema.createTable(this.tableName, (table) => {
      table.increments('id').primary()
      table.integer('id_meeting').unsigned().references('id_meeting').inTable('meetings').onDelete('CASCADE')
      table.integer('id_participant').unsigned().references('alanya_id').inTable('users').onDelete('CASCADE')
      table.tinyint('status').defaultTo(1)
      table.timestamp('start_time').nullable()
      table.boolean('connecte').defaultTo(false)
      table.integer('duree').defaultTo(0)

      table.timestamp('created_at')
      table.timestamp('updated_at')
    })
  }

  async down() {
    this.schema.dropTable(this.tableName)
  }
}