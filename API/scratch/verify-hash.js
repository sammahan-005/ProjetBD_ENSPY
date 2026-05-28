import { Scrypt } from '@adonisjs/core/hash/drivers/scrypt'

const hash = '$scrypt$n=16384,r=8,p=1$l/2ag7jvkMKUNzk53C3LjA$6B9nrh8EVc4KwX9ekbrfkDZq4kQsUeWMQvz9lqTJeKOOClCsabseaciB6oIYhDZirhfctmQwhazh76feexPbXg'

const scrypt = new Scrypt({
  cost: 16384,
  blockSize: 8,
  parallelization: 1,
  saltSize: 16,
  keyLength: 64,
})

async function test() {
  const candidates = ['123456', 'password', 'sam', 'Sam', 'password123', 'qwerty', '123457', '123458']
  for (const candidate of candidates) {
    const ok = await scrypt.verify(hash, candidate)
    if (ok) {
      console.log(`FOUND PASSWORD: "${candidate}"`)
      return
    }
  }
  console.log('None of the candidates matched.')
}

test()
