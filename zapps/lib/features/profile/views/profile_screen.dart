import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zapps/core/models/user_model.dart';
import 'package:zapps/features/auth/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _service = AuthService();
  UserModel? _user;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final user = await _service.getProfile();
    if (mounted) setState(() { _user = user; _loading = false; });
  }

  Future<void> _logout() async {
    await _service.logout();
    if (mounted) context.go('/auth/phone');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil'), actions: [
        IconButton(icon: const Icon(Icons.edit_outlined),
          onPressed: _user == null ? null : () => context.push('/profile/edit', extra: _user).then((_) => _load())),
      ]),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : _user == null ? const Center(child: Text('Erreur')) : ListView(children: [
              Container(
                padding: const EdgeInsets.all(28),
                child: Column(children: [
                  CircleAvatar(radius: 48,
                    backgroundImage: _user!.avatarUrl != null ? NetworkImage(_user!.avatarUrl!) : null,
                    backgroundColor: const Color(0xFF6C63FF).withOpacity(0.3),
                    child: _user!.avatarUrl == null
                        ? Text(_user!.initials ?? _user!.pseudo[0].toUpperCase(),
                            style: const TextStyle(color: Color(0xFF6C63FF), fontSize: 32, fontWeight: FontWeight.w700))
                        : null),
                  const SizedBox(height: 16),
                  Text(_user!.displayName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('@${_user!.pseudo}', style: const TextStyle(color: Color(0xFF666680))),
                  Text('Numéro: ${_user!.alanyaPhone}', style: const TextStyle(color: Color(0xFF666680), fontSize: 13)),
                ]),
              ),
              const Divider(color: Color(0xFF2A2A3E), height: 1),
              ListTile(leading: const Icon(Icons.people_outline, color: Color(0xFF9999BB)),
                title: const Text('Mes contacts', style: TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.chevron_right, color: Color(0xFF444460)),
                onTap: () => context.push('/contacts')),
              ListTile(leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
                onTap: _logout),
            ]),
    );
  }
}
