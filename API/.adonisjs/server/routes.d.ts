import '@adonisjs/core/types/http'

type ParamValue = string | number | bigint | boolean

export type ScannedRoutes = {
  ALL: {
    'drive.fs.serve': { paramsTuple: [...ParamValue[]]; params: {'*': ParamValue[]} }
    'auth.new_account.store': { paramsTuple?: []; params?: {} }
    'auth.access_tokens.store': { paramsTuple?: []; params?: {} }
    'auth.access_tokens.check_phone': { paramsTuple?: []; params?: {} }
    'profile.show': { paramsTuple?: []; params?: {} }
    'profile.update': { paramsTuple?: []; params?: {} }
    'profile.index': { paramsTuple?: []; params?: {} }
    'access_tokens.destroy': { paramsTuple?: []; params?: {} }
    'contacts.index': { paramsTuple?: []; params?: {} }
    'contacts.store': { paramsTuple?: []; params?: {} }
    'contacts.destroy': { paramsTuple: [ParamValue]; params: {'id': ParamValue} }
    'uploads.store': { paramsTuple?: []; params?: {} }
    'conversations.index': { paramsTuple?: []; params?: {} }
    'conversations.store': { paramsTuple?: []; params?: {} }
    'conversations.show': { paramsTuple: [ParamValue]; params: {'id': ParamValue} }
    'messages.store': { paramsTuple?: []; params?: {} }
    'messages.mark_as_read': { paramsTuple: [ParamValue]; params: {'conversationId': ParamValue} }
    'messages.destroy': { paramsTuple: [ParamValue]; params: {'id': ParamValue} }
    'statuts.index': { paramsTuple?: []; params?: {} }
    'statuts.store': { paramsTuple?: []; params?: {} }
    'statuts.view': { paramsTuple: [ParamValue]; params: {'id': ParamValue} }
    'statuts.like': { paramsTuple: [ParamValue]; params: {'id': ParamValue} }
    'calls.index': { paramsTuple?: []; params?: {} }
    'calls.store': { paramsTuple?: []; params?: {} }
    'calls.update': { paramsTuple: [ParamValue]; params: {'id': ParamValue} }
    'calls.signal': { paramsTuple?: []; params?: {} }
    'meetings.index': { paramsTuple?: []; params?: {} }
    'meetings.store': { paramsTuple?: []; params?: {} }
    'meetings.join': { paramsTuple: [ParamValue]; params: {'id': ParamValue} }
    'meetings.leave': { paramsTuple: [ParamValue]; params: {'id': ParamValue} }
    'meetings.end': { paramsTuple: [ParamValue]; params: {'id': ParamValue} }
  }
  GET: {
    'drive.fs.serve': { paramsTuple: [...ParamValue[]]; params: {'*': ParamValue[]} }
    'profile.show': { paramsTuple?: []; params?: {} }
    'profile.index': { paramsTuple?: []; params?: {} }
    'contacts.index': { paramsTuple?: []; params?: {} }
    'conversations.index': { paramsTuple?: []; params?: {} }
    'conversations.show': { paramsTuple: [ParamValue]; params: {'id': ParamValue} }
    'statuts.index': { paramsTuple?: []; params?: {} }
    'calls.index': { paramsTuple?: []; params?: {} }
    'meetings.index': { paramsTuple?: []; params?: {} }
  }
  HEAD: {
    'drive.fs.serve': { paramsTuple: [...ParamValue[]]; params: {'*': ParamValue[]} }
    'profile.show': { paramsTuple?: []; params?: {} }
    'profile.index': { paramsTuple?: []; params?: {} }
    'contacts.index': { paramsTuple?: []; params?: {} }
    'conversations.index': { paramsTuple?: []; params?: {} }
    'conversations.show': { paramsTuple: [ParamValue]; params: {'id': ParamValue} }
    'statuts.index': { paramsTuple?: []; params?: {} }
    'calls.index': { paramsTuple?: []; params?: {} }
    'meetings.index': { paramsTuple?: []; params?: {} }
  }
  POST: {
    'auth.new_account.store': { paramsTuple?: []; params?: {} }
    'auth.access_tokens.store': { paramsTuple?: []; params?: {} }
    'auth.access_tokens.check_phone': { paramsTuple?: []; params?: {} }
    'access_tokens.destroy': { paramsTuple?: []; params?: {} }
    'contacts.store': { paramsTuple?: []; params?: {} }
    'uploads.store': { paramsTuple?: []; params?: {} }
    'conversations.store': { paramsTuple?: []; params?: {} }
    'messages.store': { paramsTuple?: []; params?: {} }
    'statuts.store': { paramsTuple?: []; params?: {} }
    'statuts.view': { paramsTuple: [ParamValue]; params: {'id': ParamValue} }
    'statuts.like': { paramsTuple: [ParamValue]; params: {'id': ParamValue} }
    'calls.store': { paramsTuple?: []; params?: {} }
    'calls.signal': { paramsTuple?: []; params?: {} }
    'meetings.store': { paramsTuple?: []; params?: {} }
    'meetings.join': { paramsTuple: [ParamValue]; params: {'id': ParamValue} }
    'meetings.leave': { paramsTuple: [ParamValue]; params: {'id': ParamValue} }
    'meetings.end': { paramsTuple: [ParamValue]; params: {'id': ParamValue} }
  }
  PUT: {
    'profile.update': { paramsTuple?: []; params?: {} }
    'messages.mark_as_read': { paramsTuple: [ParamValue]; params: {'conversationId': ParamValue} }
    'calls.update': { paramsTuple: [ParamValue]; params: {'id': ParamValue} }
  }
  DELETE: {
    'contacts.destroy': { paramsTuple: [ParamValue]; params: {'id': ParamValue} }
    'messages.destroy': { paramsTuple: [ParamValue]; params: {'id': ParamValue} }
  }
}
declare module '@adonisjs/core/types/http' {
  export interface RoutesList extends ScannedRoutes {}
}