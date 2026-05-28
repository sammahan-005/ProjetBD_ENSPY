import vine from '@vinejs/vine'

const password = () => vine.string().minLength(6).maxLength(32)

/**
 * Numéro à 6 chiffres exactement
 */
const alanyaPhone = () => vine.string().regex(/^\d{6}$/)

/**
 * Validator to use when performing self-signup
 */
export const signupValidator = vine.create({
  nom: vine.string().maxLength(60).nullable().optional(),
  pseudo: vine.string().maxLength(80).unique({ table: 'users', column: 'pseudo' }),
  alanyaPhone: alanyaPhone().unique({ table: 'users', column: 'alanya_phone' }),
  password: password(),
})

/**
 * Validator to use before validating user credentials
 * during login
 */
export const loginValidator = vine.create({
  alanyaPhone: alanyaPhone(),
  password: vine.string(),
})

/**
 * Validator to use when checking if a phone number exists
 */
export const checkPhoneValidator = vine.create({
  alanyaPhone: alanyaPhone(),
})

