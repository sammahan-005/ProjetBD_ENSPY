import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zapps/core/models/user_model.dart';
import 'package:zapps/features/auth/auth_service.dart';
import 'package:zapps/features/statuts/statut_service.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel? user;
  const EditProfileScreen({super.key, this.user});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nomCtrl;
  late TextEditingController _pseudoCtrl;
  final _service = AuthService();
  final _uploadService = UploadService();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nomCtrl = TextEditingController(text: widget.user?.nom ?? '');
    _pseudoCtrl = TextEditingController(text: widget.user?.pseudo ?? '');
  }

  @override
  void dispose() { _nomCtrl.dispose(); _pseudoCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      await _service.updateProfile(nom: _nomCtrl.text.trim(), pseudo: _pseudoCtrl.text.trim());
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur lors de la sauvegarde')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _changeAvatar() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() => _loading = true);
    try {
      final url = await _uploadService.uploadFile(file);
      await _service.updateProfile(avatarUrl: url);
    } catch (_) {} finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le profil')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          GestureDetector(
            onTap: _changeAvatar,
            child: Stack(children: [
              CircleAvatar(radius: 48,
                backgroundImage: widget.user?.avatarUrl != null ? NetworkImage(widget.user!.avatarUrl!) : null,
                backgroundColor: const Color(0xFF6C63FF).withOpacity(0.3),
                child: widget.user?.avatarUrl == null
                    ? Text(widget.user?.initials ?? '?', style: const TextStyle(color: Color(0xFF6C63FF), fontSize: 32, fontWeight: FontWeight.w700))
                    : null),
              Positioned(right: 0, bottom: 0,
                child: Container(width: 28, height: 28, decoration: const BoxDecoration(color: Color(0xFF6C63FF), shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, size: 16, color: Colors.white))),
            ]),
          ),
          const SizedBox(height: 32),
          TextField(controller: _nomCtrl, decoration: const InputDecoration(hintText: 'Nom complet', prefixIcon: Icon(Icons.person_outline, color: Color(0xFF666680)))),
          const SizedBox(height: 16),
          TextField(controller: _pseudoCtrl, decoration: const InputDecoration(hintText: 'Pseudo', prefixIcon: Icon(Icons.alternate_email, color: Color(0xFF666680)))),
          const Spacer(),
          ElevatedButton(
            onPressed: _loading ? null : _save,
            child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Enregistrer'),
          ),
        ]),
      ),
    );
  }
}
