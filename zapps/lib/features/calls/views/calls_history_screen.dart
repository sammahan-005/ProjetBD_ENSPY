import 'package:flutter/material.dart';
import 'package:zapps/core/models/call_model.dart';
import 'package:zapps/core/utils/auth_storage.dart';
import 'package:zapps/features/calls/call_service.dart';

class CallsHistoryScreen extends StatefulWidget {
  const CallsHistoryScreen({super.key});

  @override
  State<CallsHistoryScreen> createState() => _CallsHistoryScreenState();
}

class _CallsHistoryScreenState extends State<CallsHistoryScreen> {
  final _service = CallService();
  List<CallModel> _calls = [];
  bool _loading = true;
  int _myId = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _myId = (await AuthStorage.getUserId()) ?? 0;
    final calls = await _service.getCalls();
    if (mounted) setState(() { _calls = calls; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appels')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : _calls.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.call_outlined,
                          size: 64, color: Colors.white.withOpacity(0.1)),
                      const SizedBox(height: 12),
                      Text('Aucun appel',
                          style: TextStyle(color: Colors.white.withOpacity(0.3))),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: _calls.length,
                    itemBuilder: (_, i) => _CallTile(call: _calls[i], myId: _myId),
                  ),
                ),
    );
  }
}

class _CallTile extends StatelessWidget {
  final CallModel call;
  final int myId;
  const _CallTile({required this.call, required this.myId});

  @override
  Widget build(BuildContext context) {
    final isOutgoing = call.idCaller == myId;
    final other = isOutgoing ? call.receiver : call.caller;
    final name = other?.displayName ?? 'Inconnu';

    IconData statusIcon;
    Color statusColor;
    if (call.isRejected) {
      statusIcon = Icons.call_missed;
      statusColor = Colors.red;
    } else if (isOutgoing) {
      statusIcon = Icons.call_made;
      statusColor = const Color(0xFF03DAC6);
    } else {
      statusIcon = Icons.call_received;
      statusColor = const Color(0xFF6C63FF);
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: other?.avatarUrl != null ? NetworkImage(other!.avatarUrl!) : null,
        backgroundColor: const Color(0xFF6C63FF).withOpacity(0.3),
        child: other?.avatarUrl == null
            ? Text(other?.initials ?? '?',
                style: const TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.w700))
            : null,
      ),
      title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      subtitle: Row(
        children: [
          Icon(statusIcon, size: 14, color: statusColor),
          const SizedBox(width: 4),
          Text(
            call.isVideo ? 'Appel vidéo' : 'Appel audio',
            style: TextStyle(color: statusColor, fontSize: 12),
          ),
          if (call.duree != null && call.duree! > 0) ...[
            Text(' · ${_formatDuree(call.duree!)}',
                style: const TextStyle(color: Color(0xFF666680), fontSize: 12)),
          ],
        ],
      ),
      trailing: IconButton(
        icon: Icon(
          call.isVideo ? Icons.videocam_outlined : Icons.call_outlined,
          color: const Color(0xFF6C63FF),
        ),
        onPressed: () async {
          if (other == null) return;
          await _service(context).initiateCall(other.alanyaId, type: call.isVideo ? 2 : 1);
        },
      ),
    );
  }

  CallService _service(BuildContext context) => CallService();

  String _formatDuree(int secs) {
    if (secs < 60) return '${secs}s';
    final m = secs ~/ 60;
    final s = secs % 60;
    return '${m}m${s.toString().padLeft(2, '0')}s';
  }
}
