import 'package:zapps/core/models/user_model.dart';

class CallModel {
  final int idCall;
  final int? idCaller;
  final int? idReceiver;
  final int type; // 1: Audio, 2: Vidéo
  final int status; // 1:Calling, 2:Accepted, 3:Rejected, 4:Ended
  final int? duree; // en secondes
  final DateTime? startTime;
  final UserModel? caller;
  final UserModel? receiver;

  const CallModel({
    required this.idCall,
    this.idCaller,
    this.idReceiver,
    this.type = 1,
    this.status = 1,
    this.duree,
    this.startTime,
    this.caller,
    this.receiver,
  });

  bool get isAudio => type == 1;
  bool get isVideo => type == 2;
  bool get isCalling => status == 1;
  bool get isAccepted => status == 2;
  bool get isRejected => status == 3;
  bool get isEnded => status == 4;

  String get statusLabel {
    switch (status) {
      case 1:
        return 'Appel...';
      case 2:
        return 'En cours';
      case 3:
        return 'Refusé';
      case 4:
        return 'Terminé';
      default:
        return 'Inconnu';
    }
  }

  factory CallModel.fromJson(Map<String, dynamic> json) {
    return CallModel(
      idCall: json['idCall'] as int,
      idCaller: json['idCaller'] as int?,
      idReceiver: json['idReceiver'] as int?,
      type: (json['type'] as int?) ?? 1,
      status: (json['status'] as int?) ?? 1,
      duree: json['duree'] as int?,
      startTime: json['startTime'] != null
          ? DateTime.tryParse(json['startTime'] as String)
          : null,
      caller: json['caller'] != null
          ? UserModel.fromJson(json['caller'] as Map<String, dynamic>)
          : null,
      receiver: json['receiver'] != null
          ? UserModel.fromJson(json['receiver'] as Map<String, dynamic>)
          : null,
    );
  }
}

class MeetingModel {
  final int idMeeting;
  final String objet;
  final String room;
  final bool typeMedia; // true: Video+Audio, false: Audio seulement
  final bool isEnd;
  final DateTime startTime;
  final int? duree;
  final UserModel? organiser;

  const MeetingModel({
    required this.idMeeting,
    required this.objet,
    required this.room,
    this.typeMedia = true,
    this.isEnd = false,
    required this.startTime,
    this.duree,
    this.organiser,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      idMeeting: json['idMeeting'] as int,
      objet: json['objet'] as String,
      room: json['room'] as String,
      typeMedia: json['typeMedia'] == null || json['typeMedia'] == true || json['typeMedia'] == 1 || json['typeMedia'] == '1',
      isEnd: json['isEnd'] == true || json['isEnd'] == 1 || json['isEnd'] == '1',
      startTime: DateTime.parse(json['startTime'] as String),
      duree: json['duree'] as int?,
      organiser: json['organiser'] != null
          ? UserModel.fromJson(json['organiser'] as Map<String, dynamic>)
          : null,
    );
  }
}

