import 'package:zapps/core/api/api_client.dart';
import 'package:zapps/core/models/conversation_model.dart';
import 'package:zapps/core/models/message_model.dart';

class ConversationService {
  final _api = ApiClient();

  Future<List<ConversationModel>> getConversations() async {
    final res = await _api.get('/conversations');
    final list = res.data as List<dynamic>;
    return list
        .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ConversationModel> createDM(int participantId) async {
    final res = await _api.post('/conversations', data: {'participantId': participantId});
    return ConversationModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<ConversationModel> createGroup({
    required String groupName,
    required List<int> participantIds,
    String? groupPhoto,
  }) async {
    final res = await _api.post('/conversations', data: {
      'isGroup': true,
      'groupName': groupName,
      'participantIds': participantIds,
      if (groupPhoto != null) 'groupPhoto': groupPhoto,
    });
    return ConversationModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<MessageModel>> getMessages(int conversationId, {int page = 1}) async {
    final res = await _api.get(
      '/conversations/$conversationId/messages',
      params: {'page': page},
    );
    // La réponse est paginée: { data: [...], meta: {...} } ou directement [...]
    final data = (res.data is Map && res.data['data'] != null)
        ? res.data['data'] as List<dynamic>
        : res.data as List<dynamic>;
    return data
        .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class MessageService {
  final _api = ApiClient();

  Future<MessageModel> sendMessage({
    required int conversationId,
    String? content,
    int type = 1,
    String? mediaUrl,
    int? replyToId,
  }) async {
    final res = await _api.post('/messages', data: {
      'conversationId': conversationId,
      if (content != null) 'content': content,
      'type': type,
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
      if (replyToId != null) 'replyToId': replyToId,
    });
    return MessageModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> markAsRead(int conversationId) async {
    await _api.put('/conversations/$conversationId/read');
  }

  Future<MessageModel> deleteMessage(int msgId) async {
    final res = await _api.delete('/messages/$msgId');
    return MessageModel.fromJson(res.data as Map<String, dynamic>);
  }
}
