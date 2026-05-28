import { BaseSchema } from '@adonisjs/lucid/schema'

export default class extends BaseSchema {
  protected tableName = 'users'

  async up() {
    this.schema.createTable(this.tableName, (table) => {
      table.increments('alanya_id').primary()
      table.string('nom', 60).nullable()
      table.string('pseudo', 80).notNullable().unique()
      table.string('alanya_phone', 20).notNullable().unique()
      table.integer('id_pays').unsigned().references('id_pays').inTable('pays').onDelete('SET NULL')
      table.string('password').notNullable()
      table.string('avatar_url').nullable()
      table.smallint('type_compte').defaultTo(1)
      table.boolean('is_online').defaultTo(false)
      table.timestamp('last_seen').nullable()
      table.boolean('exclus').defaultTo(false)
      table.boolean('in_call').defaultTo(false)
      table.boolean('biometric').defaultTo(false)
      table.string('fcm_token').nullable()
      table.string('device_id').nullable()

      table.timestamp('created_at').notNullable()
      table.timestamp('updated_at').nullable()
    })
  }

  async down() {
    this.schema.dropTable(this.tableName)
  }
}
