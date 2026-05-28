import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zapps/core/api/api_client.dart';
import 'package:zapps/core/models/statut_model.dart';
import 'package:zapps/core/models/contact_model.dart';

class UploadService {
  final _api = ApiClient();

  Future<String> uploadFile(XFile file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: file.name),
    });
    final res = await _api.postFormData('/upload', formData);
    return res.data['url'] as String;
  }
}

class StatutService {
  final _api = ApiClient();

  Future<List<StatutModel>> getStatuts() async {
    final res = await _api.get('/statuts');
    final list = res.data as List<dynamic>;
    return list
        .map((e) => StatutModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Grouper les statuts par auteur (style WhatsApp)
  List<StatutGroup> groupByAuthor(List<StatutModel> statuts, int myId) {
    final Map<int, StatutGroup> groups = {};

    for (final statut in statuts) {
      if (statut.author == null) continue;
      final authorId = statut.author!.alanyaId;
      if (!groups.containsKey(authorId)) {
        groups[authorId] = StatutGroup(
          author: statut.author!,
          statuts: [],
        );
      }
      groups[authorId]!.statuts.add(statut);
    }

    // Séparer mon statut des autres
    final myGroup = groups.remove(myId);
    final others = groups.values.toList();

    if (myGroup != null) {
      return [myGroup, ...others];
    }
    return others;
  }

  Future<StatutModel> createTextStatut({
    required String text,
    String? backgroundColor,
  }) async {
    final res = await _api.post('/statuts', data: {
      'type': 1,
      'text': text,
      if (backgroundColor != null) 'backgroundColor': backgroundColor,
    });
    return StatutModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<StatutModel> createMediaStatut(String mediaUrl) async {
    final res = await _api.post('/statuts', data: {'type': 2, 'mediaUrl': mediaUrl});
    return StatutModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> viewStatut(int id) async {
    await _api.post('/statuts/$id/view');
  }

  Future<bool> likeStatut(int id) async {
    final res = await _api.post('/statuts/$id/like');
    return (res.data['liked'] as bool?) ?? false;
  }
}


class ContactService {
  final _api = ApiClient();

  Future<List<ContactModel>> getContacts() async {
    final res = await _api.get('/contacts');
    final data = res.data as List<dynamic>;
    return data.map((e) => ContactModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ContactModel> addContact(int friendId) async {
    final res = await _api.post('/contacts', data: {'idFriend': friendId});
    final data = res.data as Map<String, dynamic>;
    return ContactModel.fromJson(data);
  }

  Future<void> removeContact(int idPrefContact) async {
    await _api.delete('/contacts/$idPrefContact');
  }
}
