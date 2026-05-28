import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zapps/features/calls/call_service.dart';

typedef OnLocalStreamCallback = void Function(MediaStream stream);
typedef OnRemoteStreamCallback = void Function(MediaStream stream);
typedef OnCallEndedCallback = void Function();

class WebRTCService {
  final CallService _callService = CallService();
  
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  
  OnLocalStreamCallback? onLocalStream;
  OnRemoteStreamCallback? onRemoteStream;
  OnCallEndedCallback? onCallEnded;

  int? _currentCallId;
  int? _remoteUserId;
  bool _isCaller = false;

  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ]
  };

  /// Initialize the media streams and ask for permissions
  Future<void> initMedia(bool isVideo) async {
    // Request permissions
    await [Permission.camera, Permission.microphone].request();

    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': isVideo ? {
        'mandatory': {
          'minWidth': '640',
          'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      } : false,
    };

    try {
      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      if (onLocalStream != null && _localStream != null) {
        onLocalStream!(_localStream!);
      }
    } catch (e) {
      print("Error opening media: $e");
    }
  }

  /// Create RTCPeerConnection and setup event listeners
  Future<void> _createPeerConnection() async {
    _peerConnection = await createPeerConnection(_configuration);

    // Add local stream tracks to the connection
    if (_localStream != null) {
      for (var track in _localStream!.getTracks()) {
        _peerConnection!.addTrack(track, _localStream!);
      }
    }

    // Listen for remote tracks
    _peerConnection!.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams[0];
        if (onRemoteStream != null) {
          onRemoteStream!(_remoteStream!);
        }
      }
    };

    // Listen for ICE candidates to send to peer
    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      if (_remoteUserId != null) {
        _callService.sendSignal(_remoteUserId!, {
          'type': 'candidate',
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        });
      }
    };
    
    _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
      print("Peer connection state: $state");
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed || 
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        endCall();
      }
    };
  }

  /// Initiate a call
  Future<void> startCall(int remoteUserId, int callId, bool isVideo) async {
    _remoteUserId = remoteUserId;
    _currentCallId = callId;
    _isCaller = true;

    await initMedia(isVideo);
    await _createPeerConnection();

    // Create an offer
    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    // Send the offer to the other peer via the signaling server
    await _callService.sendSignal(remoteUserId, {
      'type': 'offer',
      'sdp': offer.sdp,
    });
  }

  /// Accept an incoming call
  Future<void> acceptCall(int remoteUserId, int callId, bool isVideo) async {
    _remoteUserId = remoteUserId;
    _currentCallId = callId;
    _isCaller = false;

    await initMedia(isVideo);
    await _createPeerConnection();
  }

  /// Handle incoming signaling data from Transmit
  Future<void> handleSignalData(Map<String, dynamic> data) async {
    if (_peerConnection == null) return;

    final type = data['type'];

    if (type == 'offer') {
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(data['sdp'], type)
      );

      // Create an answer
      RTCSessionDescription answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      // Send answer back
      if (_remoteUserId != null) {
        await _callService.sendSignal(_remoteUserId!, {
          'type': 'answer',
          'sdp': answer.sdp,
        });
      }
    } else if (type == 'answer') {
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(data['sdp'], type)
      );
    } else if (type == 'candidate') {
      await _peerConnection!.addCandidate(
        RTCIceCandidate(data['candidate'], data['sdpMid'], data['sdpMLineIndex'])
      );
    }
  }

  /// End the call and cleanup resources
  Future<void> endCall() async {
    if (_currentCallId != null && _isCaller) {
      try {
        await _callService.updateCallStatus(_currentCallId!, 4); // 4 = Ended
      } catch (e) {
        print("Could not update call status on server: $e");
      }
    }

    _localStream?.getTracks().forEach((track) {
      track.stop();
    });
    await _localStream?.dispose();
    _localStream = null;

    _remoteStream?.getTracks().forEach((track) {
      track.stop();
    });
    await _remoteStream?.dispose();
    _remoteStream = null;

    await _peerConnection?.close();
    _peerConnection = null;

    _currentCallId = null;
    _remoteUserId = null;

    if (onCallEnded != null) {
      onCallEnded!();
    }
  }

  void toggleAudio(bool mute) {
    if (_localStream != null) {
      final audioTracks = _localStream!.getAudioTracks();
      if (audioTracks.isNotEmpty) {
        audioTracks[0].enabled = !mute;
      }
    }
  }

  void toggleVideo(bool hide) {
    if (_localStream != null) {
      final videoTracks = _localStream!.getVideoTracks();
      if (videoTracks.isNotEmpty) {
        videoTracks[0].enabled = !hide;
      }
    }
  }
}
