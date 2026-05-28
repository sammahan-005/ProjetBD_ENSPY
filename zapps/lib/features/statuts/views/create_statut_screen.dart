import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:zapps/features/statuts/statut_service.dart';

class CreateStatutScreen extends StatefulWidget {
  const CreateStatutScreen({super.key});

  @override
  State<CreateStatutScreen> createState() => _CreateStatutScreenState();
}

class _CreateStatutScreenState extends State<CreateStatutScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _textCtrl = TextEditingController();
  final _service = StatutService();
  final _uploadService = UploadService();
  bool _loading = false;
  Color _bgColor = const Color(0xFF6C63FF);

  static const _colors = [
    Color(0xFF6C63FF), Color(0xFF03DAC6), Color(0xFFFF6584),
    Color(0xFFF39C12), Color(0xFF2ECC71), Color(0xFF1A1A2E),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _publishText() async {
    if (_textCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      await _service.createTextStatut(
        text: _textCtrl.text.trim(),
        backgroundColor: '#${_bgColor.value.toRadixString(16).substring(2).toUpperCase()}',
      );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        String msg = e.toString();
        if (e is DioException && e.response?.data != null) {
          msg = e.response?.data['error'] ?? msg;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $msg')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickAndPublishMedia() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() => _loading = true);
    try {
      final url = await _uploadService.uploadFile(file);
      await _service.createMediaStatut(url);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        String msg = e.toString();
        if (e is DioException && e.response?.data != null) {
          msg = e.response?.data['error'] ?? msg;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $msg')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau statut'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: const Color(0xFF6C63FF),
          labelColor: const Color(0xFF6C63FF),
          unselectedLabelColor: const Color(0xFF666680),
          tabs: const [
            Tab(icon: Icon(Icons.text_fields), text: 'Texte'),
            Tab(icon: Icon(Icons.photo_library), text: 'Photo'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // Tab Texte
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Prévisualisation
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: _bgColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _textCtrl.text.isEmpty ? 'Votre statut...' : _textCtrl.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Palette couleurs
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _colors.map((c) => GestureDetector(
                    onTap: () => setState(() => _bgColor = c),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: _bgColor == c
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _textCtrl,
                  maxLines: 3,
                  maxLength: 1000,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(hintText: 'Écrivez votre statut...'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loading ? null : _publishText,
                  child: _loading
                      ? const SizedBox(height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Publier le statut'),
                ),
              ],
            ),
          ),
          // Tab Photo
          Center(
            child: _loading
                ? const CircularProgressIndicator(color: Color(0xFF6C63FF))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library_outlined,
                          size: 80, color: Colors.white.withOpacity(0.1)),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _pickAndPublishMedia,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Choisir une photo'),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
