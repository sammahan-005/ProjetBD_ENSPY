import 'package:zapps/core/api/api_client.dart';
import 'package:zapps/core/models/user_model.dart';
import 'package:zapps/core/utils/auth_storage.dart';

class AuthService {
  final _api = ApiClient();

  Future<bool> checkPhone(String phone) async {
    final res = await _api.post('/auth/check-phone', data: {'alanyaPhone': phone});
    final exists = res.data['exists'];
    if (exists is bool) return exists;
    if (exists is int) return exists == 1;
    if (exists is String) return exists == '1' || exists == 'true';
    return false;
  }

  /// Connexion
  Future<UserModel> login(String phone, String password) async {
    final res = await _api.post('/auth/login', data: {
      'alanyaPhone': phone,
      'password': password,
    });
    final data = res.data['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    await AuthStorage.saveToken(token);
    await AuthStorage.saveUserId(user.alanyaId);
    return user;
  }

  /// Inscription
  Future<UserModel> signup({
    required String phone,
    required String pseudo,
    required String password,
    String? nom,
  }) async {
    final res = await _api.post('/auth/signup', data: {
      'alanyaPhone': phone,
      'pseudo': pseudo,
      'password': password,
      if (nom != null) 'nom': nom,
    });
    final data = res.data['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    await AuthStorage.saveToken(token);
    await AuthStorage.saveUserId(user.alanyaId);
    return user;
  }

  /// Déconnexion
  Future<void> logout() async {
    try {
      await _api.post('/account/logout');
    } catch (_) {}
    await AuthStorage.clear();
  }

  /// Récupérer le profil courant
  Future<UserModel> getProfile() async {
    final res = await _api.get('/account/profile');
    final data = res.data['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  /// Mettre à jour le profil
  Future<UserModel> updateProfile({
    String? nom,
    String? pseudo,
    String? avatarUrl,
  }) async {
    final res = await _api.put('/account/profile', data: {
      if (nom != null) 'nom': nom,
      if (pseudo != null) 'pseudo': pseudo,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    });
    final data = res.data['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  /// Rechercher des utilisateurs par pseudo
  Future<List<UserModel>> searchUsers(String q) async {
    final res = await _api.get('/users', params: {'q': q});
    final data = (res.data is Map && res.data['data'] != null)
        ? res.data['data'] as List<dynamic>
        : res.data as List<dynamic>;
    print("SEARCH RESULTS JSON: $data");
    return data.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
