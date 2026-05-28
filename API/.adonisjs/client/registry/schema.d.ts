/* eslint-disable prettier/prettier */
/// <reference path="../manifest.d.ts" />

import type { ExtractBody, ExtractErrorResponse, ExtractQuery, ExtractQueryForGet, ExtractResponse } from '@tuyau/core/types'
import type { InferInput, SimpleError } from '@vinejs/vine/types'

export type ParamValue = string | number | bigint | boolean

export interface Registry {
  'drive.fs.serve': {
    methods: ["GET","HEAD"]
    pattern: '/uploads/*'
    types: {
      body: {}
      paramsTuple: [ParamValue]
      params: { '*': ParamValue[] }
      query: {}
      response: unknown
      errorResponse: unknown
    }
  }
  'auth.new_account.store': {
    methods: ["POST"]
    pattern: '/api/v1/auth/signup'
    types: {
      body: ExtractBody<InferInput<(typeof import('#validators/user').signupValidator)>>
      paramsTuple: []
      params: {}
      query: ExtractQuery<InferInput<(typeof import('#validators/user').signupValidator)>>
      response: ExtractResponse<Awaited<ReturnType<import('#controllers/new_account_controller').default['store']>>>
      errorResponse: ExtractErrorResponse<Awaited<ReturnType<import('#controllers/new_account_controller').default['store']>>> | { status: 422; response: { errors: SimpleError[] } }
    }
  }
  'auth.access_tokens.store': {
    methods: ["POST"]
    pattern: '/api/v1/auth/login'
    types: {
      body: ExtractBody<InferInput<(typeof import('#validators/user').loginValidator)>>
      paramsTuple: []
      params: {}
      query: ExtractQuery<InferInput<(typeof import('#validators/user').loginValidator)>>
      response: ExtractResponse<Awaited<ReturnType<import('#controllers/access_tokens_controller').default['store']>>>
      errorResponse: ExtractErrorResponse<Awaited<ReturnType<import('#controllers/access_tokens_controller').default['store']>>> | { status: 422; response: { errors: SimpleError[] } }
    }
  }
  'auth.access_tokens.check_phone': {
    methods: ["POST"]
    pattern: '/api/v1/auth/check-phone'
    types: {
      body: {}
      paramsTuple: []
      params: {}
      query: {}
      response: ExtractResponse<Awaited<ReturnType<import('#controllers/access_tokens_controller').default['checkPhone']>>>
      errorResponse: ExtractErrorResponse<Awaited<ReturnType<import('#controllers/access_tokens_controller').default['checkPhone']>>>
    }
  }
  'profile.show': {
    methods: ["GET","HEAD"]
    pattern: '/api/v1/account/profile'
    types: {
      body: {}
      paramsTuple: []
      params: {}
      query: {}
      response: ExtractResponse<Awaited<ReturnType<import('#controllers/profile_controller').default['show']>>>
      errorResponse: ExtractErrorResponse<Awaited<ReturnType<import('#controllers/profile_controller').default['show']>>>
    }
  }
  'profile.update': {
    methods: ["PUT"]
    pattern: '/api/v1/account/profile'
    types: {
      body: {}
      paramsTuple: []
      params: {}
      query: {}
      response: ExtractResponse<Awaited<ReturnType<import('#controllers/profile_controller').default['update']>>>
      errorResponse: ExtractErrorResponse<Awaited<ReturnType<import('#controllers/profile_controller').default['update']>>>
    }
  }
  'profile.index': {
    methods: ["GET","HEAD"]
    pattern: '/api/v1/users'
    types: {
      body: {}
      paramsTuple: []
      params: {}
      query: {}
      response: ExtractResponse<Awaited<ReturnType<import('#controllers/profile_controller').default['index']>>>
      errorResponse: ExtractErrorResponse<Awaited<ReturnType<import('#controllers/profile_controller').default['index']>>>
    }
  }
  'access_tokens.destroy': {
    methods: ["POST"]
    pattern: '/api/v1/account/logout'
    types: {
      body: {}
      paramsTuple: []
      params: {}
      query: {}
      response: ExtractResponse<Awaited<ReturnType<import('#controllers/access_tokens_controller').default['destroy']>>>
      errorResponse: ExtractErrorResponse<Awaited<ReturnType<import('#controllers/access_tokens_controller').default['destroy']>>>
    }
  }
  'contacts.index': {
    methods: ["GET","HEAD"]
    pattern: '/api/v1/contacts'
    types: {
      body: {}
      paramsTuple: []
      params: {}
      query: {}
      response: ExtractResponse<Awaited<ReturnType<import('#controllers/contacts_controller').default['index']>>>
      errorResponse: ExtractErrorResponse<Awaited<ReturnType<import('#controllers/contacts_controller').default['index']>>>
    }
  }
  'contacts.store': {
    methods: ["POST"]
    pattern: '/api/v1/contacts'
    types: {
      body: {}
      paramsTuple: []
      params: {}
      query: {}
      response: ExtractResponse<Awaited<ReturnType<import('#controllers/contacts_controller').default['store']>>>
      errorResponse: ExtractErrorResponse<Awaited<ReturnType<import('#controllers/contacts_controller').default['store']>>>
    }
  }
  'contacts.destroy': {
    methods: ["DELETE"]
    pattern: '/api/v1/contacts/:id'
    types: {
      body: {}
      paramsTuple: [ParamValue]
      params: { id: ParamValue }
      query: {}
      response: ExtractResponse<Awaited<ReturnType<import('#controllers/contacts_controller').default['destroy']>>>
      errorResponse: ExtractErrorResponse<Awaited<ReturnType<import('#controllers/contacts_controller').default['destroy']>>>
    }
  }
  'uploads.store': {
    methods: ["POST"]
    pattern: '/api/v1/upload'
    types: {
      body: {}
      paramsTuple: []
      params: {}
      query: {}
      response: ExtractResponse<Awaited<ReturnType<import('#controllers/uploads_controller').default['store']>>>
      errorResponse: ExtractErrorResponse<Awaited<ReturnType<import('#controllers/uploads_controller').default['store']>>>
    }
  }
  'conversations.index': {
    methods: ["GET","HEAD"]
    pattern: '/api/v1/conversations'
    types: {
      body: {}
      paramsTuple: []
      params: {}
      query: {}
      response: ExtractResponse<Awaited<ReturnType<import('#controllers/conversations_controller').default['index']>>>
      errorResponse: ExtractErrorResponse<Awaited<ReturnType<import('#controllers/conversations_controller').default['index']>>>
    }
  }
  'conversations.store': {
    methods: ["POST"]
    pattern: '/api/v1/conversations'
    types: {
      body: {}
      paramsTuple: []
      params: {}
      query: {}
      response: ExtractResponse<Awaited<ReturnType<import('#controllers/conversations_controller').default['store']>>>
      errorResponse: ExtractErrorResponse<Awaited<ReturnType<import('#controllers/conversations_controller').default['store']>>>
    }
  }
  'conversations.show': {
    methods: ["GET","HEAD"]
    pattern: '/api/v1/conversations/:id/messages'
    types: {
      body: {}
      paramsTuple: [ParamValue]
      params: { id: ParamValue }
      query: {}
      response: ExtractResponse<Awaited<ReturnType<import('#controllers/conversations_controller').default['show']>>>
      errorResponse: ExtractErrorResponse<Awaited<ReturnType<import('#controllers/conversations_controller').default['show']>>>
    }
  }
  'messages.store': {
    methods: ["POST"]
    pattern: '/api/v1/messages'
    types: {
      body: ExtractBody<InferInput<(typeof import('#validators/message').createMessageValidator)>>
      paramsTuple: []
      params: {}
      query: ExtractQuery<InferInput<(typeof import('#validators/message').createMessageValidator)>>
      response: ExtractResponse<Awaited<ReturnType<import('#controllers/messages_controller').default['store']>>>
      errorResponse: ExtractErrorResponse<Awaited<ReturnType<import('#controllers/messages_controller').default['store']>>> | { status: 422; response: { errors: SimpleError[] } }
    }
  }
  'messages.mark_as_read': {
    methods: ["PUT"]
    pattern: '/api/v1/conversations/:conversationId/read'
    types: {
      body: {}
      paramsTuple: [ParamValue]
      params: { conversationId: ParamValue }
      query: {}
      response: ExtractResponse<Awaited<ReturnType<import('#controllers/messages_controller').default['markAsRead']>>>
      errorResponse: ExtractErrorResponse<Awaited<ReturnType<import('#controllers/messages_controller').default['markAsRead']>>>
    }
  }
  'messages.destroy': {
    methods: ["DELETE"]
    pattern: '/api/v1/messages/:id'
    types: {
      body: {}
      paramsTuple: [ParamValue]
      params: { id: ParamValue }
      query: {}
      response: ExtractResponse<Awaited<ReturnType<import('#controllers/messages_controller').default['destroy']>>>
      errorResponse: ExtractErrorResponse<Awaited<ReturnType<import('#controllers/messages_controller').default['destroy']>>>
    }
  }
  'statuts.index': {
    methods: ["GET","HEAD"]
    pattern: '/api/v1/statuts'
    types: {
      body: {}
      paramsTuple: []
      params: {}
      query: {}
      response: ExtractResponse<Awaited<ReturnType<import('#controllers/statuts_controller').default['index']>>>
      errorResponse: ExtractErrorResponse<Awaited<ReturnType<import('#controllers/statuts_controller').default['index']>>>
    }
  }
  'statuts.store': {
    methods: ["POST"]
    pattern: '/api/v1/statuts'
    types: {
      body: {}
      paramsTuple: []
      params: {}
      query: {}
      response: ExtractResponse<Awaited<ReturnType<import('#controllers/statuts_controller').default['store']>>>
      errorResponse: ExtractErrorResponse<Awaited<ReturnType<import('#controllers/statuts_controller').default['store']>>>
    }
  }
  'statuts.view': {
    methods: ["POST"]
    pattern: '/api/v1/statuts/:id/view'
    types: {
      body: {}
      paramsTuple: [ParamValue]
      params: { id: ParamValue }
      query: {}
      response: ExtractResponse<Awaited<ReturnType<import('#controllers/statuts_controller').default['view']>>>
      errorResponse: ExtractErrorResponse<Awaited<ReturnType<import('#controllers/statuts_controller').default['view']>>>
    }
  }
  'statuts.like': {
    methods: ["POST"]
    pattern: '/api/v1/statuts/:id/like'
    types: {
      body: {}
      paramsTuple: [ParamValue]
      params: { id: ParamValue }
      query: {}
      response: ExtractResponse<Awaited<ReturnType<import('#controllers/statuts_controller').default['like']>>>
      errorResponse: ExtractErrorResponse<Awaited<ReturnType<import('#controllers/statuts_controller').default['like']>>>
    }
  }
  'calls.index': {
    methods: ["GET","HEAD"]
    pattern: '/api/v1/calls'
    types: {
      body: {}
      paramsTuple: []
      params: {}
      query: {}
      response: ExtractResponse<Awaited<ReturnType<import('#controllers/calls_controller').default['index']>>>
      errorResponse: ExtractErrorResponse<Awaited<ReturnType<import('#controllers/calls_controller').default['index']>>>
    }
  }
  'calls.store': {
    methods: ["POST"]
    pattern: '/api/v1/calls'
    types: {
      body: {}
      paramsTuple: []
      params: {}
      query: {}
      response: ExtractResponse<Awaited<ReturnType<import('#controllers/calls_controller').default['store']>>>
      errorResponse: ExtractErrorResponse<Awaited<ReturnType<import('#controllers/calls_controller').default['store']>>>
    }
  }
  'calls.update': {
    methods: ["PUT"]
    pattern: '/api/v1/calls/:id'
    types: {
      body: {}
      paramsTuple: [ParamValue]
      params: { id: ParamValue }
      query: {}
      response: ExtractResponse<Awaited<ReturnType<import('#controllers/calls_controller').default['update']>>>
      errorResponse: ExtractErrorResponse<Awaited<ReturnType<import('#controllers/calls_controller').default['update']>>>
    }
  }
  'calls.signal': {
    methods: ["POST"]
    pattern: '/api/v1/calls/signal'
    types: {
      body: {}
      paramsTuple: []
      params: {}
      query: {}
      response: ExtractResponse<Awaited<ReturnType<import('#controllers/calls_controller').default['signal']>>>
      errorResponse: ExtractErrorResponse<Awaited<ReturnType<import('#controllers/calls_controller').default['signal']>>>
    }
  }
  'meetings.index': {
    methods: ["GET","HEAD"]
    pattern: '/api/v1/meetings'
    types: {
      body: {}
      paramsTuple: []
      params: {}
      query: {}
      response: ExtractResponse<Awaited<ReturnType<import('#controllers/meetings_controller').default['index']>>>
      errorResponse: ExtractErrorResponse<Awaited<ReturnType<import('#controllers/meetings_controller').default['index']>>>
    }
  }
  'meetings.store': {
    methods: ["POST"]
    pattern: '/api/v1/meetings'
    types: {
      body: {}
      paramsTuple: []
      params: {}
      query: {}
      response: ExtractResponse<Awaited<ReturnType<import('#controllers/meetings_controller').default['store']>>>
      errorResponse: ExtractErrorResponse<Awaited<ReturnType<import('#controllers/meetings_controller').default['store']>>>
    }
  }
  'meetings.join': {
    methods: ["POST"]
    pattern: '/api/v1/meetings/:id/join'
    types: {
      body: {}
      paramsTuple: [ParamValue]
      params: { id: ParamValue }
      query: {}
      response: ExtractResponse<Awaited<ReturnType<import('#controllers/meetings_controller').default['join']>>>
      errorResponse: ExtractErrorResponse<Awaited<ReturnType<import('#controllers/meetings_controller').default['join']>>>
    }
  }
  'meetings.leave': {
    methods: ["POST"]
    pattern: '/api/v1/meetings/:id/leave'
    types: {
      body: {}
      paramsTuple: [ParamValue]
      params: { id: ParamValue }
      query: {}
      response: ExtractResponse<Awaited<ReturnType<import('#controllers/meetings_controller').default['leave']>>>
      errorResponse: ExtractErrorResponse<Awaited<ReturnType<import('#controllers/meetings_controller').default['leave']>>>
    }
  }
  'meetings.end': {
    methods: ["POST"]
    pattern: '/api/v1/meetings/:id/end'
    types: {
      body: {}
      paramsTuple: [ParamValue]
      params: { id: ParamValue }
      query: {}
      response: ExtractResponse<Awaited<ReturnType<import('#controllers/meetings_controller').default['end']>>>
      errorResponse: ExtractErrorResponse<Awaited<ReturnType<import('#controllers/meetings_controller').default['end']>>>
    }
  }
}
