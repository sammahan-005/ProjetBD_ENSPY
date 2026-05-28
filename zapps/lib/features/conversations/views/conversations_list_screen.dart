import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zapps/core/models/conversation_model.dart';
import 'package:zapps/core/models/message_model.dart';
import 'package:zapps/core/utils/auth_storage.dart';
import 'package:zapps/core/api/transmit_service.dart';
import 'package:zapps/features/conversations/conversation_service.dart';

class ConversationsListScreen extends StatefulWidget {
  const ConversationsListScreen({super.key});

  @override
  State<ConversationsListScreen> createState() => _ConversationsListScreenState();
}

class _ConversationsListScreenState extends State<ConversationsListScreen> {
  final _service = ConversationService();
  List<ConversationModel> _conversations = [];
  bool _loading = true;
  int _myId = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _myId = (await AuthStorage.getUserId()) ?? 0;
    final convs = await _service.getConversations();
    if (mounted) setState(() { _conversations = convs; _loading = false; });

    // S'abonner aux événements SSE de chaque conversation
    for (final conv in convs) {
      TransmitService().subscribe('conversations/${conv.conversId}');
      TransmitService().on('conversations/${conv.conversId}', _onConvEvent);
    }
  }

  void _onConvEvent(String event, Map<String, dynamic> data) {
    if (event == 'message:new') {
      final msg = MessageModel.fromJson(data['message'] as Map<String, dynamic>);
      setState(() {
        _conversations = _conversations.map((c) {
          if (c.conversId == msg.conversationId) {
            return c.copyWith(
              lastMessage: msg.displayContent,
              lastMessageAt: msg.sendAt,
              unreadCount: c.unreadCount + (msg.senderId != _myId ? 1 : 0),
            );
          }
          return c;
        }).toList()
          ..sort((a, b) =>
              (b.lastMessageAt ?? DateTime(0)).compareTo(a.lastMessageAt ?? DateTime(0)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discussions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'new_chat_fab',
        backgroundColor: const Color(0xFF6C63FF),
        onPressed: () => context.push('/chat/new'),
        child: const Icon(Icons.edit_outlined, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : _conversations.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: _conversations.length,
                    itemBuilder: (_, i) => _ConvTile(
                      conv: _conversations[i],
                      myId: _myId,
                      onTap: () => context.push(
                        '/chat/${_conversations[i].conversId}',
                        extra: _conversations[i],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline,
              size: 64, color: Colors.white.withOpacity(0.15)),
          const SizedBox(height: 16),
          Text('Aucune conversation',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: const Color(0xFF666680))),
          const SizedBox(height: 8),
          Text('Appuyez sur ✏️ pour démarrer une discussion',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: const Color(0xFF444460))),
        ],
      ),
    );
  }
}

class _ConvTile extends StatelessWidget {
  final ConversationModel conv;
  final int myId;
  final VoidCallback onTap;

  const _ConvTile({required this.conv, required this.myId, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = conv.displayName(myId);
    final initials = conv.displayInitials(myId) ?? name.substring(0, 1).toUpperCase();
    final avatar = conv.displayAvatar(myId);
    final hasUnread = conv.unreadCount > 0;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      onTap: onTap,
      leading: CircleAvatar(
        radius: 26,
        backgroundImage: avatar != null ? NetworkImage(avatar) : null,
        backgroundColor: const Color(0xFF6C63FF).withOpacity(0.3),
        child: avatar == null
            ? Text(initials,
                style: const TextStyle(
                    color: Color(0xFF6C63FF), fontWeight: FontWeight.w700))
            : null,
      ),
      title: Text(name,
          style: TextStyle(
              fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
              color: Colors.white)),
      subtitle: Text(
        conv.lastMessage ?? 'Démarrer la conversation',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            color: hasUnread ? Colors.white70 : const Color(0xFF666680),
            fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (conv.lastMessageAt != null)
            Text(
              _formatTime(conv.lastMessageAt!),
              style: TextStyle(
                  fontSize: 11,
                  color: hasUnread ? const Color(0xFF6C63FF) : const Color(0xFF666680)),
            ),
          const SizedBox(height: 4),
          if (hasUnread)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('${conv.unreadCount}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Hier';
    } else {
      return '${dt.day}/${dt.month}';
    }
  }
}
