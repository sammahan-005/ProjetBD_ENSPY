import { BaseSchema } from '@adonisjs/lucid/schema'

export default class extends BaseSchema {
  protected tableName = 'meetings'

  async up() {
    this.schema.createTable(this.tableName, (table) => {
      table.increments('id_meeting').primary()
      table.integer('id_organiser').unsigned().references('alanya_id').inTable('users').onDelete('CASCADE')
      table.timestamp('start_time').notNullable()
      table.integer('duree').defaultTo(0)
      table.string('objet').nullable()
      table.string('room').nullable()
      table.boolean('is_end').defaultTo(false)
      table.tinyint('type_media').defaultTo(1) // 1: video, 2: audio

      table.timestamp('created_at')
      table.timestamp('updated_at')
    })
  }

  async down() {
    this.schema.dropTable(this.tableName)
  }
}