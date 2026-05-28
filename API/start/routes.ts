import { middleware } from '#start/kernel'
import router from '@adonisjs/core/services/router'

const NewAccountController = () => import('#controllers/new_account_controller')
const AccessTokensController = () => import('#controllers/access_tokens_controller')
const ProfileController = () => import('#controllers/profile_controller')

const ConversationsController = () => import('#controllers/conversations_controller')
const MessagesController = () => import('#controllers/messages_controller')
const StatutsController = () => import('#controllers/statuts_controller')
const CallsController = () => import('#controllers/calls_controller')
const MeetingsController = () => import('#controllers/meetings_controller')
const UploadsController = () => import('#controllers/uploads_controller')
const ContactsController = () => import('#controllers/contacts_controller')

router.get('/', () => {
  return { hello: 'world' }
})

router
  .group(() => {
    // Auth routes
    router
      .group(() => {
        router.post('signup', [NewAccountController, 'store'])
        router.post('login', [AccessTokensController, 'store'])
        router.post('check-phone', [AccessTokensController, 'checkPhone'])
      })
      .prefix('auth')
      .as('auth')

    // Authenticated API routes
    router
      .group(() => {
        // Account & Profile
        router.get('account/profile', [ProfileController, 'show'])
        router.put('account/profile', [ProfileController, 'update'])
        router.get('users', [ProfileController, 'index'])
        router.post('account/logout', [AccessTokensController, 'destroy'])

        // Contacts préférés
        router.get('contacts', [ContactsController, 'index'])
        router.post('contacts', [ContactsController, 'store'])
        router.delete('contacts/:id', [ContactsController, 'destroy'])

        // Uploads
        router.post('upload', [UploadsController, 'store'])

        // Conversations
        router.get('conversations', [ConversationsController, 'index'])
        router.post('conversations', [ConversationsController, 'store'])
        router.get('conversations/:id/messages', [ConversationsController, 'show'])

        // Messages
        router.post('messages', [MessagesController, 'store'])
        router.put('conversations/:conversationId/read', [MessagesController, 'markAsRead'])
        router.delete('messages/:id', [MessagesController, 'destroy'])

        // Statuts (Stories)
        router.get('statuts', [StatutsController, 'index'])
        router.post('statuts', [StatutsController, 'store'])
        router.post('statuts/:id/view', [StatutsController, 'view'])
        router.post('statuts/:id/like', [StatutsController, 'like'])

        // Calls (Appels individuels WebRTC)
        router.get('calls', [CallsController, 'index'])
        router.post('calls', [CallsController, 'store'])
        router.put('calls/:id', [CallsController, 'update'])
        router.post('calls/signal', [CallsController, 'signal'])

        // Meetings (Visioconférences de groupe)
        router.get('meetings', [MeetingsController, 'index'])
        router.post('meetings', [MeetingsController, 'store'])
        router.post('meetings/:id/join', [MeetingsController, 'join'])
        router.post('meetings/:id/leave', [MeetingsController, 'leave'])
        router.post('meetings/:id/end', [MeetingsController, 'end'])
      })
      .use(middleware.auth())
  })
  .prefix('/api/v1')
