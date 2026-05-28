import 'package:zapps/core/models/user_model.dart';
import 'package:zapps/core/models/message_model.dart';

class ConversationModel {
  final int conversId;
  final bool isGroup;
  final String? groupName;
  final String? groupPhoto;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool isArchived;
  final bool isPinned;
  final List<UserModel> participants;

  const ConversationModel({
    required this.conversId,
    this.isGroup = false,
    this.groupName,
    this.groupPhoto,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.isArchived = false,
    this.isPinned = false,
    this.participants = const [],
  });

  /// Pour un DM: retourne l'autre participant
  UserModel? otherParticipant(int myId) {
    try {
      return participants.firstWhere((p) => p.alanyaId != myId);
    } catch (_) {
      return null;
    }
  }

  String displayName(int myId) {
    if (isGroup) return groupName ?? 'Groupe';
    return otherParticipant(myId)?.displayName ?? 'Inconnu';
  }

  String? displayAvatar(int myId) {
    if (isGroup) return groupPhoto;
    return otherParticipant(myId)?.avatarUrl;
  }

  String? displayInitials(int myId) {
    if (isGroup) return groupName?.substring(0, 1).toUpperCase();
    return otherParticipant(myId)?.initials;
  }

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    bool? parseBool(dynamic val) {
      if (val == null) return null;
      return val == true || val == 1 || val == '1';
    }

    int parseId(dynamic val) {
      if (val is String) return int.parse(val);
      return (val as num).toInt();
    }

    return ConversationModel(
      conversId: parseId(json['conversId'] ?? json['convers_id']),
      isGroup: parseBool(json['isGroup'] ?? json['is_group']) ?? false,
      groupName: (json['groupName'] ?? json['group_name']) as String?,
      groupPhoto: (json['groupPhoto'] ?? json['group_photo']) as String?,
      lastMessage: (json['lastMessage'] ?? json['last_message']) as String?,
      lastMessageAt: (json['lastMessageAt'] ?? json['last_message_at']) != null
          ? DateTime.tryParse((json['lastMessageAt'] ?? json['last_message_at']) as String)
          : null,
      unreadCount: ((json['unreadCount'] ?? json['unread_count']) as num?)?.toInt() ?? 0,
      isArchived: parseBool(json['isArchived'] ?? json['is_archived']) ?? false,
      isPinned: parseBool(json['isPinned'] ?? json['is_pinned']) ?? false,
      participants: (json['participants'] as List<dynamic>? ?? [])
          .map((p) => UserModel.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  ConversationModel copyWith({
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
    MessageModel? latestMessage,
  }) {
    return ConversationModel(
      conversId: conversId,
      isGroup: isGroup,
      groupName: groupName,
      groupPhoto: groupPhoto,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      isArchived: isArchived,
      isPinned: isPinned,
      participants: participants,
    );
  }
}
