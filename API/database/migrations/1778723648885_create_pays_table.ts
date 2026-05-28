import { BaseSchema } from '@adonisjs/lucid/schema'

export default class extends BaseSchema {
  protected tableName = 'pays'

  async up() {
    this.schema.createTable(this.tableName, (table) => {
      table.increments('id_pays').primary()
      table.string('libelle', 100).notNullable()
      table.string('prefix', 4).notNullable()
      table.string('time_zone', 100).nullable()
      table.integer('decalage_horaire').nullable()

      table.timestamp('created_at')
      table.timestamp('updated_at')
    })
  }

  async down() {
    this.schema.dropTable(this.tableName)
  }
}