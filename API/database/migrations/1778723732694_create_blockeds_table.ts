import { BaseSchema } from '@adonisjs/lucid/schema'

export default class extends BaseSchema {
  protected tableName = 'blockeds'

  async up() {
    this.schema.createTable(this.tableName, (table) => {
      table.increments('id_block').primary()
      table.integer('alanya_id').unsigned().references('alanya_id').inTable('users').onDelete('CASCADE')
      table.integer('id_caller_block').unsigned().references('alanya_id').inTable('users').onDelete('CASCADE')
      table.timestamp('date_block').notNullable()

      table.timestamp('created_at')
      table.timestamp('updated_at')
    })
  }

  async down() {
    this.schema.dropTable(this.tableName)
  }
}