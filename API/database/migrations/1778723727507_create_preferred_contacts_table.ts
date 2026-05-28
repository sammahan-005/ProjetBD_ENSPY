import { BaseSchema } from '@adonisjs/lucid/schema'

export default class extends BaseSchema {
  protected tableName = 'preferred_contacts'

  async up() {
    this.schema.createTable(this.tableName, (table) => {
      table.bigIncrements('id_pref_contact').primary()
      table.integer('alanya_id').unsigned().references('alanya_id').inTable('users').onDelete('CASCADE')
      table.integer('id_friend').unsigned().references('alanya_id').inTable('users').onDelete('CASCADE')

      table.timestamp('created_at')
      table.timestamp('updated_at')
    })
  }

  async down() {
    this.schema.dropTable(this.tableName)
  }
}