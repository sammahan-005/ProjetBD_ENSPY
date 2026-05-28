import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:zapps/core/models/conversation_model.dart';
import 'package:zapps/core/models/message_model.dart';
import 'package:zapps/core/utils/auth_storage.dart';
import 'package:zapps/core/api/transmit_service.dart';
import 'package:zapps/features/conversations/conversation_service.dart';
import 'package:zapps/features/conversations/conversation_service.dart' show MessageService;

class ChatScreen extends StatefulWidget {
  final int conversationId;
  final ConversationModel? conversation;

  const ChatScreen({
    super.key,
    required this.conversationId,
    this.conversation,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgService = MessageService();
  final _convService = ConversationService();
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  List<MessageModel> _messages = [];
  bool _loading = true;
  bool _sending = false;
  int _myId = 0;
  int _page = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _init();
    _scrollCtrl.addListener(_onScroll);
  }

  Future<void> _init() async {
    _myId = (await AuthStorage.getUserId()) ?? 0;
    await _loadMessages();
    await _msgService.markAsRead(widget.conversationId);

    // SSE temps réel
    final channel = 'conversations/${widget.conversationId}';
    await TransmitService().subscribe(channel);
    TransmitService().on(channel, _onSseEvent);
  }

  Future<void> _loadMessages({bool loadMore = false}) async {
    if (loadMore) _page++;
    final msgs = await _convService.getMessages(
      widget.conversationId,
      page: _page,
    );
    setState(() {
      if (loadMore) {
        _messages.addAll(msgs);
      } else {
        _messages = msgs;
      }
      _hasMore = msgs.length >= 30;
      _loading = false;
    });
  }

  void _onScroll() {
    // Scroll vers le haut = messages plus anciens
    if (_scrollCtrl.position.atEdge &&
        _scrollCtrl.position.pixels == _scrollCtrl.position.maxScrollExtent &&
        _hasMore) {
      _loadMessages(loadMore: true);
    }
  }

  void _onSseEvent(String event, Map<String, dynamic> data) {
    if (!mounted) return;
    if (event == 'message:new') {
      final msg = MessageModel.fromJson(data['message'] as Map<String, dynamic>);
      if (msg.conversationId == widget.conversationId) {
        setState(() => _messages.insert(0, msg));
        _msgService.markAsRead(widget.conversationId);
      }
    } else if (event == 'message:deleted') {
      final msgId = data['msgId'] as int;
      setState(() {
        _messages = _messages.map((m) {
          if (m.msgId == msgId) return m.copyWith(isDeleted: true, content: 'Ce message a été supprimé');
          return m;
        }).toList();
      });
    }
  }

  Future<void> _send() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() { _sending = true; });
    _textCtrl.clear();
    try {
      final msg = await _msgService.sendMessage(
        conversationId: widget.conversationId,
        content: text,
        type: 1,
      );
      if (mounted) {
        if (!_messages.any((m) => m.msgId == msg.msgId)) {
          setState(() => _messages.insert(0, msg));
        }
      }
    } catch (e) {
      _textCtrl.text = text; // Restaurer si erreur
      if (mounted) {
        String msg = e.toString();
        if (e is DioException && e.response?.data != null) {
          msg = e.response?.data['error'] ?? msg;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $msg')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    TransmitService().unsubscribe('conversations/${widget.conversationId}');
    TransmitService().off('conversations/${widget.conversationId}');
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conv = widget.conversation;
    final title = conv?.displayName(_myId) ?? 'Conversation';

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: conv?.displayAvatar(_myId) != null
                  ? NetworkImage(conv!.displayAvatar(_myId)!)
                  : null,
              backgroundColor: const Color(0xFF6C63FF).withOpacity(0.3),
              child: conv?.displayAvatar(_myId) == null
                  ? Text(conv?.displayInitials(_myId) ?? '?',
                      style: const TextStyle(
                          color: Color(0xFF6C63FF),
                          fontSize: 12,
                          fontWeight: FontWeight.w700))
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
                : ListView.builder(
                    controller: _scrollCtrl,
                    reverse: true, // Afficher du bas (récent) vers le haut (ancien)
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) => _MessageBubble(
                      message: _messages[i],
                      isMe: _messages[i].senderId == _myId,
                    ),
                  ),
          ),
          _buildComposer(),
        ],
      ),
    );
  }

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textCtrl,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Message...',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _send,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 2,
          bottom: 2,
          left: isMe ? 60 : 0,
          right: isMe ? 0 : 60,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isMe
              ? const Color(0xFF6C63FF)
              : const Color(0xFF1E1E30),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe && message.sender != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  message.sender!.pseudo,
                  style: const TextStyle(
                      color: Color(0xFF6C63FF),
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ),
            Text(
              message.displayContent,
              style: TextStyle(
                color: message.isDeleted
                    ? Colors.white38
                    : Colors.white,
                fontStyle: message.isDeleted
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${message.sendAt.hour.toString().padLeft(2, '0')}:${message.sendAt.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.4)),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.status ? Icons.done_all : Icons.done,
                    size: 12,
                    color: message.status
                        ? const Color(0xFF03DAC6)
                        : Colors.white38,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
