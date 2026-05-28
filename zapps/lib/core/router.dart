import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zapps/core/models/user_model.dart';
import 'package:zapps/core/models/conversation_model.dart';

// Auth
import 'package:zapps/features/auth/views/splash_screen.dart';
import 'package:zapps/features/auth/views/phone_input_screen.dart';
import 'package:zapps/features/auth/views/login_screen.dart';
import 'package:zapps/features/auth/views/signup_screen.dart';

// Shell principal
import 'package:zapps/features/home/main_shell.dart';

// Conversations
import 'package:zapps/features/conversations/views/conversations_list_screen.dart';
import 'package:zapps/features/conversations/views/chat_screen.dart';
import 'package:zapps/features/conversations/views/new_conversation_screen.dart';

// Statuts
import 'package:zapps/features/statuts/views/statuts_screen.dart';
import 'package:zapps/features/statuts/views/create_statut_screen.dart';

// Appels
import 'package:zapps/features/calls/views/calls_history_screen.dart';

// Profil
import 'package:zapps/features/profile/views/profile_screen.dart';
import 'package:zapps/features/profile/views/edit_profile_screen.dart';

// Contacts
import 'package:zapps/features/contacts/views/contacts_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    // ─── Ecrans hors shell ────────────────────────────────────────────────
    GoRoute(
      path: '/splash',
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: '/auth/phone',
      builder: (_, __) => const PhoneInputScreen(),
    ),
    GoRoute(
      path: '/auth/login',
      builder: (context, state) {
        final phone = state.extra as String? ?? '';
        return LoginScreen(phone: phone);
      },
    ),
    GoRoute(
      path: '/auth/signup',
      builder: (context, state) {
        final phone = state.extra as String? ?? '';
        return SignupScreen(phone: phone);
      },
    ),

    // ─── Chat (hors shell pour plein écran) ──────────────────────────────
    GoRoute(
      path: '/chat/new',
      builder: (_, __) => const NewConversationScreen(),
    ),

    GoRoute(
      path: '/chat/:id',
      builder: (context, state) {
        final conv = state.extra as ConversationModel?;
        final id = int.parse(state.pathParameters['id']!);
        return ChatScreen(conversationId: id, conversation: conv);
      },
    ),

    GoRoute(
      path: '/statuts/create',
      builder: (_, __) => const CreateStatutScreen(),
    ),

    GoRoute(
      path: '/contacts',
      builder: (_, __) => const ContactsScreen(),
    ),

    GoRoute(
      path: '/profile/edit',
      builder: (context, state) {
        final user = state.extra as UserModel?;
        return EditProfileScreen(user: user);
      },
    ),

    // ─── Shell avec Bottom Navigation ─────────────────────────────────────
    StatefulShellRoute.indexedStack(
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellKey,
          routes: [
            GoRoute(
              path: '/conversations',
              builder: (_, __) => const ConversationsListScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/statuts',
              builder: (_, __) => const StatutsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/calls',
              builder: (_, __) => const CallsHistoryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (_, __) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
