/* eslint-disable prettier/prettier */
import type { AdonisEndpoint } from '@tuyau/core/types'
import type { Registry } from './schema.d.ts'
import type { ApiDefinition } from './tree.d.ts'

const placeholder: any = {}

const routes = {
  'drive.fs.serve': {
    methods: ["GET","HEAD"],
    pattern: '/uploads/*',
    tokens: [{"old":"/uploads/*","type":0,"val":"uploads","end":""},{"old":"/uploads/*","type":2,"val":"*","end":""}],
    types: placeholder as Registry['drive.fs.serve']['types'],
  },
  'auth.new_account.store': {
    methods: ["POST"],
    pattern: '/api/v1/auth/signup',
    tokens: [{"old":"/api/v1/auth/signup","type":0,"val":"api","end":""},{"old":"/api/v1/auth/signup","type":0,"val":"v1","end":""},{"old":"/api/v1/auth/signup","type":0,"val":"auth","end":""},{"old":"/api/v1/auth/signup","type":0,"val":"signup","end":""}],
    types: placeholder as Registry['auth.new_account.store']['types'],
  },
  'auth.access_tokens.store': {
    methods: ["POST"],
    pattern: '/api/v1/auth/login',
    tokens: [{"old":"/api/v1/auth/login","type":0,"val":"api","end":""},{"old":"/api/v1/auth/login","type":0,"val":"v1","end":""},{"old":"/api/v1/auth/login","type":0,"val":"auth","end":""},{"old":"/api/v1/auth/login","type":0,"val":"login","end":""}],
    types: placeholder as Registry['auth.access_tokens.store']['types'],
  },
  'auth.access_tokens.check_phone': {
    methods: ["POST"],
    pattern: '/api/v1/auth/check-phone',
    tokens: [{"old":"/api/v1/auth/check-phone","type":0,"val":"api","end":""},{"old":"/api/v1/auth/check-phone","type":0,"val":"v1","end":""},{"old":"/api/v1/auth/check-phone","type":0,"val":"auth","end":""},{"old":"/api/v1/auth/check-phone","type":0,"val":"check-phone","end":""}],
    types: placeholder as Registry['auth.access_tokens.check_phone']['types'],
  },
  'profile.show': {
    methods: ["GET","HEAD"],
    pattern: '/api/v1/account/profile',
    tokens: [{"old":"/api/v1/account/profile","type":0,"val":"api","end":""},{"old":"/api/v1/account/profile","type":0,"val":"v1","end":""},{"old":"/api/v1/account/profile","type":0,"val":"account","end":""},{"old":"/api/v1/account/profile","type":0,"val":"profile","end":""}],
    types: placeholder as Registry['profile.show']['types'],
  },
  'profile.update': {
    methods: ["PUT"],
    pattern: '/api/v1/account/profile',
    tokens: [{"old":"/api/v1/account/profile","type":0,"val":"api","end":""},{"old":"/api/v1/account/profile","type":0,"val":"v1","end":""},{"old":"/api/v1/account/profile","type":0,"val":"account","end":""},{"old":"/api/v1/account/profile","type":0,"val":"profile","end":""}],
    types: placeholder as Registry['profile.update']['types'],
  },
  'profile.index': {
    methods: ["GET","HEAD"],
    pattern: '/api/v1/users',
    tokens: [{"old":"/api/v1/users","type":0,"val":"api","end":""},{"old":"/api/v1/users","type":0,"val":"v1","end":""},{"old":"/api/v1/users","type":0,"val":"users","end":""}],
    types: placeholder as Registry['profile.index']['types'],
  },
  'access_tokens.destroy': {
    methods: ["POST"],
    pattern: '/api/v1/account/logout',
    tokens: [{"old":"/api/v1/account/logout","type":0,"val":"api","end":""},{"old":"/api/v1/account/logout","type":0,"val":"v1","end":""},{"old":"/api/v1/account/logout","type":0,"val":"account","end":""},{"old":"/api/v1/account/logout","type":0,"val":"logout","end":""}],
    types: placeholder as Registry['access_tokens.destroy']['types'],
  },
  'contacts.index': {
    methods: ["GET","HEAD"],
    pattern: '/api/v1/contacts',
    tokens: [{"old":"/api/v1/contacts","type":0,"val":"api","end":""},{"old":"/api/v1/contacts","type":0,"val":"v1","end":""},{"old":"/api/v1/contacts","type":0,"val":"contacts","end":""}],
    types: placeholder as Registry['contacts.index']['types'],
  },
  'contacts.store': {
    methods: ["POST"],
    pattern: '/api/v1/contacts',
    tokens: [{"old":"/api/v1/contacts","type":0,"val":"api","end":""},{"old":"/api/v1/contacts","type":0,"val":"v1","end":""},{"old":"/api/v1/contacts","type":0,"val":"contacts","end":""}],
    types: placeholder as Registry['contacts.store']['types'],
  },
  'contacts.destroy': {
    methods: ["DELETE"],
    pattern: '/api/v1/contacts/:id',
    tokens: [{"old":"/api/v1/contacts/:id","type":0,"val":"api","end":""},{"old":"/api/v1/contacts/:id","type":0,"val":"v1","end":""},{"old":"/api/v1/contacts/:id","type":0,"val":"contacts","end":""},{"old":"/api/v1/contacts/:id","type":1,"val":"id","end":""}],
    types: placeholder as Registry['contacts.destroy']['types'],
  },
  'uploads.store': {
    methods: ["POST"],
    pattern: '/api/v1/upload',
    tokens: [{"old":"/api/v1/upload","type":0,"val":"api","end":""},{"old":"/api/v1/upload","type":0,"val":"v1","end":""},{"old":"/api/v1/upload","type":0,"val":"upload","end":""}],
    types: placeholder as Registry['uploads.store']['types'],
  },
  'conversations.index': {
    methods: ["GET","HEAD"],
    pattern: '/api/v1/conversations',
    tokens: [{"old":"/api/v1/conversations","type":0,"val":"api","end":""},{"old":"/api/v1/conversations","type":0,"val":"v1","end":""},{"old":"/api/v1/conversations","type":0,"val":"conversations","end":""}],
    types: placeholder as Registry['conversations.index']['types'],
  },
  'conversations.store': {
    methods: ["POST"],
    pattern: '/api/v1/conversations',
    tokens: [{"old":"/api/v1/conversations","type":0,"val":"api","end":""},{"old":"/api/v1/conversations","type":0,"val":"v1","end":""},{"old":"/api/v1/conversations","type":0,"val":"conversations","end":""}],
    types: placeholder as Registry['conversations.store']['types'],
  },
  'conversations.show': {
    methods: ["GET","HEAD"],
    pattern: '/api/v1/conversations/:id/messages',
    tokens: [{"old":"/api/v1/conversations/:id/messages","type":0,"val":"api","end":""},{"old":"/api/v1/conversations/:id/messages","type":0,"val":"v1","end":""},{"old":"/api/v1/conversations/:id/messages","type":0,"val":"conversations","end":""},{"old":"/api/v1/conversations/:id/messages","type":1,"val":"id","end":""},{"old":"/api/v1/conversations/:id/messages","type":0,"val":"messages","end":""}],
    types: placeholder as Registry['conversations.show']['types'],
  },
  'messages.store': {
    methods: ["POST"],
    pattern: '/api/v1/messages',
    tokens: [{"old":"/api/v1/messages","type":0,"val":"api","end":""},{"old":"/api/v1/messages","type":0,"val":"v1","end":""},{"old":"/api/v1/messages","type":0,"val":"messages","end":""}],
    types: placeholder as Registry['messages.store']['types'],
  },
  'messages.mark_as_read': {
    methods: ["PUT"],
    pattern: '/api/v1/conversations/:conversationId/read',
    tokens: [{"old":"/api/v1/conversations/:conversationId/read","type":0,"val":"api","end":""},{"old":"/api/v1/conversations/:conversationId/read","type":0,"val":"v1","end":""},{"old":"/api/v1/conversations/:conversationId/read","type":0,"val":"conversations","end":""},{"old":"/api/v1/conversations/:conversationId/read","type":1,"val":"conversationId","end":""},{"old":"/api/v1/conversations/:conversationId/read","type":0,"val":"read","end":""}],
    types: placeholder as Registry['messages.mark_as_read']['types'],
  },
  'messages.destroy': {
    methods: ["DELETE"],
    pattern: '/api/v1/messages/:id',
    tokens: [{"old":"/api/v1/messages/:id","type":0,"val":"api","end":""},{"old":"/api/v1/messages/:id","type":0,"val":"v1","end":""},{"old":"/api/v1/messages/:id","type":0,"val":"messages","end":""},{"old":"/api/v1/messages/:id","type":1,"val":"id","end":""}],
    types: placeholder as Registry['messages.destroy']['types'],
  },
  'statuts.index': {
    methods: ["GET","HEAD"],
    pattern: '/api/v1/statuts',
    tokens: [{"old":"/api/v1/statuts","type":0,"val":"api","end":""},{"old":"/api/v1/statuts","type":0,"val":"v1","end":""},{"old":"/api/v1/statuts","type":0,"val":"statuts","end":""}],
    types: placeholder as Registry['statuts.index']['types'],
  },
  'statuts.store': {
    methods: ["POST"],
    pattern: '/api/v1/statuts',
    tokens: [{"old":"/api/v1/statuts","type":0,"val":"api","end":""},{"old":"/api/v1/statuts","type":0,"val":"v1","end":""},{"old":"/api/v1/statuts","type":0,"val":"statuts","end":""}],
    types: placeholder as Registry['statuts.store']['types'],
  },
  'statuts.view': {
    methods: ["POST"],
    pattern: '/api/v1/statuts/:id/view',
    tokens: [{"old":"/api/v1/statuts/:id/view","type":0,"val":"api","end":""},{"old":"/api/v1/statuts/:id/view","type":0,"val":"v1","end":""},{"old":"/api/v1/statuts/:id/view","type":0,"val":"statuts","end":""},{"old":"/api/v1/statuts/:id/view","type":1,"val":"id","end":""},{"old":"/api/v1/statuts/:id/view","type":0,"val":"view","end":""}],
    types: placeholder as Registry['statuts.view']['types'],
  },
  'statuts.like': {
    methods: ["POST"],
    pattern: '/api/v1/statuts/:id/like',
    tokens: [{"old":"/api/v1/statuts/:id/like","type":0,"val":"api","end":""},{"old":"/api/v1/statuts/:id/like","type":0,"val":"v1","end":""},{"old":"/api/v1/statuts/:id/like","type":0,"val":"statuts","end":""},{"old":"/api/v1/statuts/:id/like","type":1,"val":"id","end":""},{"old":"/api/v1/statuts/:id/like","type":0,"val":"like","end":""}],
    types: placeholder as Registry['statuts.like']['types'],
  },
  'calls.index': {
    methods: ["GET","HEAD"],
    pattern: '/api/v1/calls',
    tokens: [{"old":"/api/v1/calls","type":0,"val":"api","end":""},{"old":"/api/v1/calls","type":0,"val":"v1","end":""},{"old":"/api/v1/calls","type":0,"val":"calls","end":""}],
    types: placeholder as Registry['calls.index']['types'],
  },
  'calls.store': {
    methods: ["POST"],
    pattern: '/api/v1/calls',
    tokens: [{"old":"/api/v1/calls","type":0,"val":"api","end":""},{"old":"/api/v1/calls","type":0,"val":"v1","end":""},{"old":"/api/v1/calls","type":0,"val":"calls","end":""}],
    types: placeholder as Registry['calls.store']['types'],
  },
  'calls.update': {
    methods: ["PUT"],
    pattern: '/api/v1/calls/:id',
    tokens: [{"old":"/api/v1/calls/:id","type":0,"val":"api","end":""},{"old":"/api/v1/calls/:id","type":0,"val":"v1","end":""},{"old":"/api/v1/calls/:id","type":0,"val":"calls","end":""},{"old":"/api/v1/calls/:id","type":1,"val":"id","end":""}],
    types: placeholder as Registry['calls.update']['types'],
  },
  'calls.signal': {
    methods: ["POST"],
    pattern: '/api/v1/calls/signal',
    tokens: [{"old":"/api/v1/calls/signal","type":0,"val":"api","end":""},{"old":"/api/v1/calls/signal","type":0,"val":"v1","end":""},{"old":"/api/v1/calls/signal","type":0,"val":"calls","end":""},{"old":"/api/v1/calls/signal","type":0,"val":"signal","end":""}],
    types: placeholder as Registry['calls.signal']['types'],
  },
  'meetings.index': {
    methods: ["GET","HEAD"],
    pattern: '/api/v1/meetings',
    tokens: [{"old":"/api/v1/meetings","type":0,"val":"api","end":""},{"old":"/api/v1/meetings","type":0,"val":"v1","end":""},{"old":"/api/v1/meetings","type":0,"val":"meetings","end":""}],
    types: placeholder as Registry['meetings.index']['types'],
  },
  'meetings.store': {
    methods: ["POST"],
    pattern: '/api/v1/meetings',
    tokens: [{"old":"/api/v1/meetings","type":0,"val":"api","end":""},{"old":"/api/v1/meetings","type":0,"val":"v1","end":""},{"old":"/api/v1/meetings","type":0,"val":"meetings","end":""}],
    types: placeholder as Registry['meetings.store']['types'],
  },
  'meetings.join': {
    methods: ["POST"],
    pattern: '/api/v1/meetings/:id/join',
    tokens: [{"old":"/api/v1/meetings/:id/join","type":0,"val":"api","end":""},{"old":"/api/v1/meetings/:id/join","type":0,"val":"v1","end":""},{"old":"/api/v1/meetings/:id/join","type":0,"val":"meetings","end":""},{"old":"/api/v1/meetings/:id/join","type":1,"val":"id","end":""},{"old":"/api/v1/meetings/:id/join","type":0,"val":"join","end":""}],
    types: placeholder as Registry['meetings.join']['types'],
  },
  'meetings.leave': {
    methods: ["POST"],
    pattern: '/api/v1/meetings/:id/leave',
    tokens: [{"old":"/api/v1/meetings/:id/leave","type":0,"val":"api","end":""},{"old":"/api/v1/meetings/:id/leave","type":0,"val":"v1","end":""},{"old":"/api/v1/meetings/:id/leave","type":0,"val":"meetings","end":""},{"old":"/api/v1/meetings/:id/leave","type":1,"val":"id","end":""},{"old":"/api/v1/meetings/:id/leave","type":0,"val":"leave","end":""}],
    types: placeholder as Registry['meetings.leave']['types'],
  },
  'meetings.end': {
    methods: ["POST"],
    pattern: '/api/v1/meetings/:id/end',
    tokens: [{"old":"/api/v1/meetings/:id/end","type":0,"val":"api","end":""},{"old":"/api/v1/meetings/:id/end","type":0,"val":"v1","end":""},{"old":"/api/v1/meetings/:id/end","type":0,"val":"meetings","end":""},{"old":"/api/v1/meetings/:id/end","type":1,"val":"id","end":""},{"old":"/api/v1/meetings/:id/end","type":0,"val":"end","end":""}],
    types: placeholder as Registry['meetings.end']['types'],
  },
} as const satisfies Record<string, AdonisEndpoint>

export { routes }

export const registry = {
  routes,
  $tree: {} as ApiDefinition,
}

declare module '@tuyau/core/types' {
  export interface UserRegistry {
    routes: typeof routes
    $tree: ApiDefinition
  }
}
