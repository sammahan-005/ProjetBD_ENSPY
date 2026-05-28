import 'package:zapps/core/models/user_model.dart';

class MessageModel {
  final int msgId;
  final int conversationId;
  final int? senderId;
  final String? content;
  final int type; // 1: Text, 2: Image, 3: Vidéo, 4: Audio, 5: Document
  final String? mediaUrl;
  final bool status; // false=non-lu, true=lu
  final bool isDeleted;
  final bool isEdited;
  final int? replyToId;
  final DateTime sendAt;
  final DateTime? readAt;
  final UserModel? sender;

  const MessageModel({
    required this.msgId,
    required this.conversationId,
    this.senderId,
    this.content,
    this.type = 1,
    this.mediaUrl,
    this.status = false,
    this.isDeleted = false,
    this.isEdited = false,
    this.replyToId,
    required this.sendAt,
    this.readAt,
    this.sender,
  });

  bool get isText => type == 1;
  bool get isMedia => type == 2 || type == 3;
  bool get isAudio => type == 4;

  String get displayContent {
    if (isDeleted) return 'Ce message a été supprimé';
    if (content != null && content!.isNotEmpty) return content!;
    if (type == 2) return '📷 Photo';
    if (type == 3) return '🎥 Vidéo';
    if (type == 4) return '🎵 Audio';
    if (type == 5) return '📄 Document';
    return '';
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    int parseId(dynamic val) {
      if (val is String) return int.parse(val);
      return (val as num).toInt();
    }

    return MessageModel(
      msgId: parseId(json['msgId'] ?? json['msg_id']),
      conversationId: parseId(json['conversationId'] ?? json['conversation_id']),
      senderId: (json['senderId'] ?? json['sender_id']) != null
          ? parseId(json['senderId'] ?? json['sender_id'])
          : null,
      content: json['content'] as String?,
      type: ((json['type'] ?? json['type']) as int?) ?? 1,
      mediaUrl: (json['mediaUrl'] ?? json['media_url']) as String?,
      status: (json['status'] ?? json['status']) == true || 
              (json['status'] ?? json['status']) == 1 || 
              (json['status'] ?? json['status']) == '1',
      isDeleted: (json['isDeleted'] ?? json['is_deleted']) == true || 
                 (json['isDeleted'] ?? json['is_deleted']) == 1 || 
                 (json['isDeleted'] ?? json['is_deleted']) == '1',
      isEdited: (json['isEdited'] ?? json['is_edited']) == true || 
                (json['isEdited'] ?? json['is_edited']) == 1 || 
                (json['isEdited'] ?? json['is_edited']) == '1',
      replyToId: (json['replyToId'] ?? json['reply_to_id']) != null
          ? parseId(json['replyToId'] ?? json['reply_to_id'])
          : null,
      sendAt: DateTime.parse((json['sendAt'] ?? json['send_at']) as String),
      readAt: (json['readAt'] ?? json['read_at']) != null
          ? DateTime.tryParse((json['readAt'] ?? json['read_at']) as String)
          : null,
      sender: json['sender'] != null
          ? UserModel.fromJson(json['sender'] as Map<String, dynamic>)
          : null,
    );
  }

  MessageModel copyWith({bool? isDeleted, String? content}) {
    return MessageModel(
      msgId: msgId,
      conversationId: conversationId,
      senderId: senderId,
      content: content ?? this.content,
      type: type,
      mediaUrl: mediaUrl,
      status: status,
      isDeleted: isDeleted ?? this.isDeleted,
      isEdited: isEdited,
      replyToId: replyToId,
      sendAt: sendAt,
      readAt: readAt,
      sender: sender,
    );
  }
}
