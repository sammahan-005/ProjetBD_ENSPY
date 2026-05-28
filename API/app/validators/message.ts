import vine from '@vinejs/vine'

export const createMessageValidator = vine.create({
  content: vine.string().maxLength(5000).nullable().optional(),
  type: vine.number().optional(), // 1: Text, 2: Image, etc.
  mediaUrl: vine.string().maxLength(255).nullable().optional(),
  replyToId: vine.number().optional(),
  conversationId: vine.number(),
})
