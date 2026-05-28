import { BaseSchema } from '@adonisjs/lucid/schema'

export default class extends BaseSchema {
  protected tableName = 'user_accesses'

  async up() {
    this.schema.createTable(this.tableName, (table) => {
      table.bigIncrements('id_login').primary()
      table.integer('alanya_id').unsigned().references('alanya_id').inTable('users').onDelete('CASCADE')
      table.string('device').nullable()
      table.timestamp('date_login').notNullable()
      table.string('ip_adress').nullable()
      table.string('os_system').nullable()

      table.timestamp('created_at')
      table.timestamp('updated_at')
    })
  }

  async down() {
    this.schema.dropTable(this.tableName)
  }
}