import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:zapps/core/models/user_model.dart';
import 'package:zapps/features/auth/auth_service.dart';
import 'package:zapps/features/conversations/conversation_service.dart';

class NewConversationScreen extends StatefulWidget {
  const NewConversationScreen({super.key});

  @override
  State<NewConversationScreen> createState() => _NewConversationScreenState();
}

class _NewConversationScreenState extends State<NewConversationScreen> {
  final _searchCtrl = TextEditingController();
  final _authService = AuthService();
  final _convService = ConversationService();
  List<UserModel> _results = [];
  bool _searching = false;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearch);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchCtrl.text.trim();
    if (q.length < 2) {
      setState(() => _results = []);
      return;
    }
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_searchCtrl.text.trim() == q) _search(q);
    });
  }

  Future<void> _search(String q) async {
    setState(() => _searching = true);
    try {
      final users = await _authService.searchUsers(q);
      if (mounted) setState(() => _results = users);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de recherche: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _startDM(UserModel user) async {
    setState(() => _creating = true);
    try {
      final conv = await _convService.createDM(user.alanyaId);
      if (mounted) {
        context.pop();
        context.push('/chat/${conv.conversId}', extra: conv);
      }
    } catch (e) {
      if (mounted) {
        String msg = e.toString();
        if (e is DioException && e.response?.data != null) {
          msg = e.response?.data['error'] ?? msg;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible de créer: $msg')),
        );
      }
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle conversation')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Rechercher un pseudo...',
                prefixIcon: _searching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Color(0xFF6C63FF)),
                        ),
                      )
                    : const Icon(Icons.search, color: Color(0xFF666680)),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFF666680)),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _results = []);
                        },
                      )
                    : null,
              ),
            ),
          ),
          if (_searchCtrl.text.length < 2 && _results.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_search,
                        size: 56, color: Colors.white.withOpacity(0.1)),
                    const SizedBox(height: 12),
                    Text('Tapez au moins 2 caractères',
                        style: TextStyle(color: Colors.white.withOpacity(0.3))),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: _results.isEmpty && !_searching
                  ? Center(
                      child: Text('Aucun utilisateur trouvé',
                          style: TextStyle(color: Colors.white.withOpacity(0.3))),
                    )
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (_, i) {
                        final user = _results[i];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          leading: CircleAvatar(
                            backgroundImage: user.avatarUrl != null
                                ? NetworkImage(user.avatarUrl!)
                                : null,
                            backgroundColor:
                                const Color(0xFF6C63FF).withOpacity(0.3),
                            child: user.avatarUrl == null
                                ? Text(user.initials ?? user.pseudo[0].toUpperCase(),
                                    style: const TextStyle(
                                        color: Color(0xFF6C63FF),
                                        fontWeight: FontWeight.w700))
                                : null,
                          ),
                          title: Text(user.pseudo,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                          subtitle: user.nom != null
                              ? Text(user.nom!,
                                  style: const TextStyle(color: Color(0xFF666680)))
                              : null,
                          trailing: _creating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.chevron_right,
                                  color: Color(0xFF666680)),
                          onTap: _creating ? null : () => _startDM(user),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}
