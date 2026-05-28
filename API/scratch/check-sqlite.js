import Database from 'better-sqlite3'
import path from 'path'

const dbPath = path.resolve(process.cwd(), 'tmp/db.sqlite3')
console.log('Opening SQLite database at:', dbPath)

try {
  const db = new Database(dbPath)
  const rows = db.prepare('SELECT alanya_id, pseudo, alanya_phone, password FROM users').all()
  console.log('--- Users in SQLite Database ---')
  console.log(JSON.stringify(rows, null, 2))
} catch (error) {
  console.error('Error querying SQLite database:', error)
}
