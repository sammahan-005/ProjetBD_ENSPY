import mysql from 'mysql2/promise'
import fs from 'fs'
import path from 'path'

// Simple .env parser
function loadEnv() {
  const envPath = path.resolve(process.cwd(), '.env')
  if (!fs.existsSync(envPath)) return
  const lines = fs.readFileSync(envPath, 'utf8').split('\n')
  for (const line of lines) {
    const trimmed = line.trim()
    if (!trimmed || trimmed.startsWith('#')) continue
    const parts = trimmed.split('=')
    if (parts.length >= 2) {
      const key = parts[0].trim()
      const val = parts.slice(1).join('=').trim()
      process.env[key] = val
    }
  }
}

loadEnv()

async function run() {
  const connection = await mysql.createConnection({
    host: process.env.MYSQL_HOST,
    port: parseInt(process.env.MYSQL_PORT || '3306', 10),
    user: process.env.MYSQL_USER,
    password: process.env.MYSQL_PASSWORD,
    database: process.env.MYSQL_DATABASE,
  })

  try {
    const [rows] = await connection.execute('SELECT alanya_id, pseudo, alanya_phone, password FROM users LIMIT 10')
    console.log('--- Users in Database ---')
    console.log(JSON.stringify(rows, null, 2))
  } catch (error) {
    console.error('Error fetching users:', error)
  } finally {
    await connection.end()
  }
}

run()
