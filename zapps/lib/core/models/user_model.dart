class UserModel {
  final int alanyaId;
  final String pseudo;
  final String alanyaPhone;
  final String? nom;
  final String? avatarUrl;
  final bool? isOnline;
  final DateTime? lastSeen;
  final String? initials;
  final bool? inCall;
  final int? typeCompte;

  const UserModel({
    required this.alanyaId,
    required this.pseudo,
    required this.alanyaPhone,
    this.nom,
    this.avatarUrl,
    this.isOnline,
    this.lastSeen,
    this.initials,
    this.inCall,
    this.typeCompte,
  });

  String get displayName => nom ?? pseudo;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    bool? parseBool(dynamic val) {
      if (val == null) return null;
      return val == true || val == 1 || val == '1';
    }

    return UserModel(
      alanyaId: (json['alanyaId'] ?? json['alanya_id']) as int,
      pseudo: json['pseudo'] as String,
      alanyaPhone: (json['alanyaPhone'] ?? json['alanya_phone']) as String,
      nom: json['nom'] as String?,
      avatarUrl: (json['avatarUrl'] ?? json['avatar_url']) as String?,
      isOnline: parseBool(json['isOnline'] ?? json['is_online']),
      lastSeen: (json['lastSeen'] ?? json['last_seen']) != null
          ? DateTime.tryParse((json['lastSeen'] ?? json['last_seen']) as String)
          : null,
      initials: json['initials'] as String?,
      inCall: parseBool(json['inCall'] ?? json['in_call']),
      typeCompte: (json['typeCompte'] ?? json['type_compte']) as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'alanyaId': alanyaId,
        'pseudo': pseudo,
        'alanyaPhone': alanyaPhone,
        'nom': nom,
        'avatarUrl': avatarUrl,
        'isOnline': isOnline,
        'lastSeen': lastSeen?.toIso8601String(),
        'initials': initials,
        'inCall': inCall,
        'typeCompte': typeCompte,
      };

  UserModel copyWith({
    String? nom,
    String? pseudo,
    String? avatarUrl,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return UserModel(
      alanyaId: alanyaId,
      pseudo: pseudo ?? this.pseudo,
      alanyaPhone: alanyaPhone,
      nom: nom ?? this.nom,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      initials: initials,
      inCall: inCall,
      typeCompte: typeCompte,
    );
  }
}
