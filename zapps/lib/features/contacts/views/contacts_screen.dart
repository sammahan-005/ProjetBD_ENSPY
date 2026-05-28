import 'package:flutter/material.dart';
import 'package:zapps/core/models/contact_model.dart';
import 'package:zapps/core/models/user_model.dart';
import 'package:zapps/features/auth/auth_service.dart';
import 'package:zapps/features/statuts/statut_service.dart';
import 'package:dio/dio.dart';
import 'package:zapps/core/utils/auth_storage.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});
  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _contactService = ContactService();
  final _authService = AuthService();
  List<ContactModel> _contacts = [];
  List<UserModel> _searchResults = [];
  bool _loading = true;
  bool _searching = false;
  final _searchCtrl = TextEditingController();

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final contacts = await _contactService.getContacts();
    if (mounted) setState(() { _contacts = contacts; _loading = false; });
  }

  Future<void> _search(String q) async {
    if (q.trim().length < 2) { setState(() => _searchResults = []); return; }
    setState(() => _searching = true);
    final results = await _authService.searchUsers(q.trim());
    final myId = await AuthStorage.getUserId();
    if (myId != null) {
      results.removeWhere((u) => u.alanyaId == myId);
    }
    if (mounted) setState(() { _searchResults = results; _searching = false; });
  }

  Future<void> _addContact(UserModel user) async {
    try {
      await _contactService.addContact(user.alanyaId);
      _searchCtrl.clear();
      setState(() => _searchResults = []);
      await _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${user.pseudo} ajouté aux contacts')));
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Impossible d\'ajouter ce contact';
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg.toString())));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible d\'ajouter ce contact')));
    }
  }

  Future<void> _removeContact(ContactModel contact) async {
    final confirmed = await showDialog<bool>(context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E30),
        title: const Text('Retirer ce contact ?', style: TextStyle(color: Colors.white)),
        content: Text('${contact.friend?.pseudo ?? 'Ce contact'} sera retiré de votre liste.', style: const TextStyle(color: Color(0xFF9999BB))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Retirer', style: TextStyle(color: Colors.red))),
        ],
      ));
    if (confirmed == true) {
      await _contactService.removeContact(contact.idPrefContact);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes contacts')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (q) => Future.delayed(const Duration(milliseconds: 300), () { if (_searchCtrl.text == q) _search(q); }),
            decoration: InputDecoration(
              hintText: 'Ajouter un contact par pseudo...',
              prefixIcon: _searching ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6C63FF)))) : const Icon(Icons.person_add_outlined, color: Color(0xFF666680)),
              suffixIcon: _searchCtrl.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, color: Color(0xFF666680)), onPressed: () { _searchCtrl.clear(); setState(() => _searchResults = []); }) : null,
            ),
          ),
        ),
        if (_searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: const Color(0xFF1E1E30), borderRadius: BorderRadius.circular(12)),
            child: Column(children: _searchResults.map((user) => ListTile(
              leading: CircleAvatar(backgroundColor: const Color(0xFF6C63FF).withOpacity(0.3), child: Text(user.initials ?? user.pseudo[0].toUpperCase(), style: const TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.w700))),
              title: Text(user.pseudo, style: const TextStyle(color: Colors.white)),
              subtitle: user.nom != null ? Text(user.nom!, style: const TextStyle(color: Color(0xFF666680))) : null,
              trailing: IconButton(icon: const Icon(Icons.add_circle, color: Color(0xFF6C63FF)), onPressed: () => _addContact(user)),
            )).toList()),
          ),
        const SizedBox(height: 8),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
              : _contacts.isEmpty
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.white.withOpacity(0.1)),
                      const SizedBox(height: 12),
                      Text('Aucun contact', style: TextStyle(color: Colors.white.withOpacity(0.3))),
                      const SizedBox(height: 4),
                      Text('Recherchez un pseudo pour ajouter', style: TextStyle(color: Colors.white.withOpacity(0.15), fontSize: 12)),
                    ]))
                  : ListView.builder(
                      itemCount: _contacts.length,
                      itemBuilder: (_, i) {
                        final c = _contacts[i];
                        final user = c.friend;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                            backgroundColor: const Color(0xFF6C63FF).withOpacity(0.3),
                            child: user?.avatarUrl == null ? Text(user?.initials ?? '?', style: const TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.w700)) : null),
                          title: Text(user?.pseudo ?? 'Inconnu', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          subtitle: user?.nom != null ? Text(user!.nom!, style: const TextStyle(color: Color(0xFF666680))) : null,
                          trailing: IconButton(
                            icon: const Icon(Icons.person_remove_outlined, color: Color(0xFF666680)),
                            onPressed: () => _removeContact(c)),
                        );
                      }),
        ),
      ]),
    );
  }
}
