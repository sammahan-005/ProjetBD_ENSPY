import 'package:flutter/material.dart';
import 'package:zapps/core/models/call_model.dart';
import 'package:zapps/core/models/user_model.dart';
import 'package:zapps/features/calls/call_service.dart';

class IncomingCallScreen extends StatelessWidget {
  final CallModel call;
  final UserModel caller;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const IncomingCallScreen({
    super.key,
    required this.call,
    required this.caller,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final bool isVideo = call.type == 2;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color(0xFF6C63FF).withOpacity(0.3),
                  backgroundImage: caller.avatarUrl != null ? NetworkImage(caller.avatarUrl!) : null,
                  child: caller.avatarUrl == null
                      ? Text(
                          caller.initials ?? '?',
                          style: const TextStyle(fontSize: 40, color: Color(0xFF6C63FF)),
                        )
                      : null,
                ),
                const SizedBox(height: 24),
                Text(
                  caller.displayName,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  isVideo ? 'Appel vidéo entrant...' : 'Appel audio entrant...',
                  style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.7)),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _CallButton(
                  icon: Icons.call_end,
                  color: Colors.red,
                  onPressed: () async {
                    await CallService().updateCallStatus(call.idCall, 3); // 3 = Rejected
                    onReject();
                  },
                  label: 'Refuser',
                ),
                _CallButton(
                  icon: isVideo ? Icons.videocam : Icons.call,
                  color: Colors.green,
                  onPressed: () async {
                    await CallService().updateCallStatus(call.idCall, 2); // 2 = Accepted
                    onAccept();
                  },
                  label: 'Accepter',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final String label;

  const _CallButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
        ),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ],
    );
  }
}
