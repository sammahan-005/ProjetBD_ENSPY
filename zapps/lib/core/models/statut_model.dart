import 'package:zapps/core/models/user_model.dart';

class StatutModel {
  final int id;
  final int alanyaId;
  final int type; // 1: Text, 2: Media
  final String? text;
  final String? mediaUrl;
  final String? backgroundColor;
  final DateTime? expiresAt;
  final int viewedBy;
  final int likedBy;
  final UserModel? author;
  final bool isExpired;

  const StatutModel({
    required this.id,
    required this.alanyaId,
    this.type = 1,
    this.text,
    this.mediaUrl,
    this.backgroundColor,
    this.expiresAt,
    this.viewedBy = 0,
    this.likedBy = 0,
    this.author,
    this.isExpired = false,
  });

  bool get isText => type == 1;
  bool get isMedia => type == 2;

  factory StatutModel.fromJson(Map<String, dynamic> json) {
    final expStr = json['expiresAt'] ?? json['expires_at'];
    final expiresAt = expStr != null ? DateTime.tryParse(expStr as String) : null;

    int parseId(dynamic val) {
      if (val is String) return int.parse(val);
      return (val as num).toInt();
    }

    return StatutModel(
      id: parseId(json['id']),
      alanyaId: parseId(json['alanyaId'] ?? json['alanya_id']),
      type: ((json['type'] ?? json['type']) as num?)?.toInt() ?? 1,
      text: (json['text'] ?? json['text']) as String?,
      mediaUrl: (json['mediaUrl'] ?? json['media_url']) as String?,
      backgroundColor: (json['backgroundColor'] ?? json['background_color']) as String?,
      expiresAt: expiresAt,
      viewedBy: ((json['viewedBy'] ?? json['viewed_by']) as num?)?.toInt() ?? 0,
      likedBy: ((json['likedBy'] ?? json['liked_by']) as num?)?.toInt() ?? 0,
      author: json['author'] != null
          ? UserModel.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      isExpired: expiresAt != null && expiresAt.isBefore(DateTime.now()),
    );
  }
}

/// Groupe de statuts par utilisateur (style WhatsApp)
class StatutGroup {
  final UserModel author;
  final List<StatutModel> statuts;
  bool hasUnviewed;

  StatutGroup({
    required this.author,
    required this.statuts,
    this.hasUnviewed = false,
  });
}
