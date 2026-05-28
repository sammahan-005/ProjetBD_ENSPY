import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:zapps/features/calls/webrtc_service.dart';

class ActiveCallScreen extends StatefulWidget {
  final WebRTCService webrtcService;
  final bool isVideo;
  final String peerName;
  final VoidCallback onEndCall;

  const ActiveCallScreen({
    super.key,
    required this.webrtcService,
    required this.isVideo,
    required this.peerName,
    required this.onEndCall,
  });

  @override
  State<ActiveCallScreen> createState() => _ActiveCallScreenState();
}

class _ActiveCallScreenState extends State<ActiveCallScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  
  bool _isMuted = false;
  bool _isVideoOff = false;

  @override
  void initState() {
    super.initState();
    _initRenderers();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    widget.webrtcService.onLocalStream = (stream) {
      if (mounted) {
        setState(() {
          _localRenderer.srcObject = stream;
        });
      }
    };

    widget.webrtcService.onRemoteStream = (stream) {
      if (mounted) {
        setState(() {
          _remoteRenderer.srcObject = stream;
        });
      }
    };

    widget.webrtcService.onCallEnded = () {
      if (mounted) {
        widget.onEndCall();
      }
    };
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Remote Video or Audio Background
            if (widget.isVideo)
              Positioned.fill(
                child: RTCVideoView(
                  _remoteRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              )
            else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(0xFF6C63FF),
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.peerName,
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Appel Audio...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

            // Local Video (PIP)
            if (widget.isVideo)
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  width: 100,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: RTCVideoView(
                      _localRenderer,
                      mirror: true,
                      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    ),
                  ),
                ),
              ),

            // Controls
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ControlButton(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    color: _isMuted ? Colors.red : Colors.white24,
                    onPressed: () {
                      setState(() {
                        _isMuted = !_isMuted;
                      });
                      widget.webrtcService.toggleAudio(_isMuted);
                    },
                  ),
                  _ControlButton(
                    icon: Icons.call_end,
                    color: Colors.red,
                    iconSize: 36,
                    padding: 20,
                    onPressed: () async {
                      await widget.webrtcService.endCall();
                      widget.onEndCall();
                    },
                  ),
                  if (widget.isVideo)
                    _ControlButton(
                      icon: _isVideoOff ? Icons.videocam_off : Icons.videocam,
                      color: _isVideoOff ? Colors.red : Colors.white24,
                      onPressed: () {
                        setState(() {
                          _isVideoOff = !_isVideoOff;
                        });
                        widget.webrtcService.toggleVideo(_isVideoOff);
                      },
                    )
                  else
                    const SizedBox(width: 56), // spacer placeholder
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double iconSize;
  final double padding;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.color,
    this.iconSize = 28,
    this.padding = 16,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }
}
