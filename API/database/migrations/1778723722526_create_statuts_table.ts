import { BaseSchema } from '@adonisjs/lucid/schema'

export default class extends BaseSchema {
  protected tableName = 'statuts'

  async up() {
    this.schema.createTable(this.tableName, (table) => {
      table.increments('id').primary()
      table.integer('alanya_id').unsigned().references('alanya_id').inTable('users').onDelete('CASCADE')
      table.smallint('type').defaultTo(1)
      table.text('text').nullable()
      table.string('media_url').nullable()
      table.string('background_color', 20).nullable()
      table.timestamp('expires_at').nullable()
      table.integer('viewed_by').defaultTo(0)
      table.integer('liked_by').defaultTo(0)

      table.timestamp('created_at')
      table.timestamp('updated_at')
    })
  }

  async down() {
    this.schema.dropTable(this.tableName)
  }
}