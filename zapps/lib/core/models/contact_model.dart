import 'package:zapps/core/models/user_model.dart';

class ContactModel {
  final int idPrefContact;
  final UserModel? friend;

  const ContactModel({required this.idPrefContact, this.friend});

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      idPrefContact: json['idPrefContact'] as int,
      friend: json['friend'] != null
          ? UserModel.fromJson(json['friend'] as Map<String, dynamic>)
          : null,
    );
  }
}
