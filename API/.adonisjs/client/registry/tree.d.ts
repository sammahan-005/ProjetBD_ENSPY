/* eslint-disable prettier/prettier */
import type { routes } from './index.ts'

export interface ApiDefinition {
  drive: {
    fs: {
      serve: typeof routes['drive.fs.serve']
    }
  }
  auth: {
    newAccount: {
      store: typeof routes['auth.new_account.store']
    }
    accessTokens: {
      store: typeof routes['auth.access_tokens.store']
      checkPhone: typeof routes['auth.access_tokens.check_phone']
    }
  }
  profile: {
    show: typeof routes['profile.show']
    update: typeof routes['profile.update']
    index: typeof routes['profile.index']
  }
  accessTokens: {
    destroy: typeof routes['access_tokens.destroy']
  }
  contacts: {
    index: typeof routes['contacts.index']
    store: typeof routes['contacts.store']
    destroy: typeof routes['contacts.destroy']
  }
  uploads: {
    store: typeof routes['uploads.store']
  }
  conversations: {
    index: typeof routes['conversations.index']
    store: typeof routes['conversations.store']
    show: typeof routes['conversations.show']
  }
  messages: {
    store: typeof routes['messages.store']
    markAsRead: typeof routes['messages.mark_as_read']
    destroy: typeof routes['messages.destroy']
  }
  statuts: {
    index: typeof routes['statuts.index']
    store: typeof routes['statuts.store']
    view: typeof routes['statuts.view']
    like: typeof routes['statuts.like']
  }
  calls: {
    index: typeof routes['calls.index']
    store: typeof routes['calls.store']
    update: typeof routes['calls.update']
    signal: typeof routes['calls.signal']
  }
  meetings: {
    index: typeof routes['meetings.index']
    store: typeof routes['meetings.store']
    join: typeof routes['meetings.join']
    leave: typeof routes['meetings.leave']
    end: typeof routes['meetings.end']
  }
}
