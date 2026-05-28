import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zapps/core/models/statut_model.dart';
import 'package:zapps/core/utils/auth_storage.dart';
import 'package:zapps/features/statuts/statut_service.dart';

class StatutsScreen extends StatefulWidget {
  const StatutsScreen({super.key});

  @override
  State<StatutsScreen> createState() => _StatutsScreenState();
}

class _StatutsScreenState extends State<StatutsScreen> {
  final _service = StatutService();
  List<StatutGroup> _groups = [];
  StatutGroup? _myGroup;
  bool _loading = true;
  int _myId = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _myId = (await AuthStorage.getUserId()) ?? 0;
    final statuts = await _service.getStatuts();
    final groups = _service.groupByAuthor(statuts, _myId);
    setState(() {
      _myGroup = groups.isNotEmpty && groups.first.author.alanyaId == _myId
          ? groups.first
          : null;
      _groups = groups.where((g) => g.author.alanyaId != _myId).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statuts')),
      floatingActionButton: FloatingActionButton(
        heroTag: 'new_status_fab',
        backgroundColor: const Color(0xFF6C63FF),
        onPressed: () => context.push('/statuts/create').then((_) => _load()),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                children: [
                  // Mon statut
                  _SectionHeader(title: 'Mon statut'),
                  _MyStatutTile(group: _myGroup, myId: _myId),
                  if (_groups.isNotEmpty) ...[
                    _SectionHeader(title: 'Contacts récents'),
                    ..._groups.map((g) => _ContactStatutTile(group: g)),
                  ],
                ],
              ),
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(title,
          style: const TextStyle(
              color: Color(0xFF6C63FF),
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 1)),
    );
  }
}

class _MyStatutTile extends StatelessWidget {
  final StatutGroup? group;
  final int myId;
  const _MyStatutTile({required this.group, required this.myId});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFF6C63FF).withOpacity(0.3),
            child: const Icon(Icons.person, color: Color(0xFF6C63FF)),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFF6C63FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
      title: const Text('Mon statut',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
      subtitle: Text(
        group == null
            ? 'Appuyez pour ajouter un statut'
            : '${group!.statuts.length} statut(s) actif(s)',
        style: const TextStyle(color: Color(0xFF666680)),
      ),
      onTap: () => context.push('/statuts/create'),
    );
  }
}

class _ContactStatutTile extends StatelessWidget {
  final StatutGroup group;
  const _ContactStatutTile({required this.group});

  @override
  Widget build(BuildContext context) {
    final user = group.author;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF6C63FF), width: 2.5),
        ),
        child: CircleAvatar(
          backgroundImage:
              user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
          backgroundColor: const Color(0xFF1E1E30),
          child: user.avatarUrl == null
              ? Text(user.initials ?? user.pseudo[0].toUpperCase(),
                  style: const TextStyle(
                      color: Color(0xFF6C63FF), fontWeight: FontWeight.w700))
              : null,
        ),
      ),
      title: Text(user.displayName,
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
      subtitle: Text(
        '${group.statuts.length} statut(s)',
        style: const TextStyle(color: Color(0xFF666680)),
      ),
    );
  }
}
