import 'package:flutter/material.dart';
import 'package:zapps/core/api/transmit_service.dart';
import 'package:zapps/core/models/call_model.dart';
import 'package:zapps/features/calls/call_service.dart';
import 'package:zapps/core/models/user_model.dart';
import 'package:zapps/core/router.dart';
import 'package:zapps/core/utils/auth_storage.dart';
import 'package:zapps/features/calls/views/active_call_screen.dart';
import 'package:zapps/features/calls/views/incoming_call_screen.dart';
import 'package:zapps/features/calls/webrtc_service.dart';

class CallManager {
  static final CallManager _instance = CallManager._internal();
  factory CallManager() => _instance;
  CallManager._internal();

  final WebRTCService _webrtcService = WebRTCService();
  int? _myId;
  String? _channel;

  Future<void> init() async {
    _myId = await AuthStorage.getUserId();
    if (_myId == null) return;

    _channel = 'users/$_myId';
    final transmit = TransmitService();
    
    // S'abonner et écouter le canal personnel
    await transmit.subscribe(_channel!);
    transmit.on(_channel!, _onTransmitEvent);
  }

  void _onTransmitEvent(String event, Map<String, dynamic> data) {
    if (event == 'calls:incoming') {
      final callJson = data['call'] as Map<String, dynamic>;
      final call = CallModel.fromJson(callJson);
      if (call.caller != null) {
        _showIncomingCallScreen(call, call.caller!);
      }
    } else if (event == 'calls:signal') {
      final signalData = data['signalData'];
      _webrtcService.handleSignalData(signalData);
    } else if (event == 'calls:status_updated') {
      final callJson = data['call'] as Map<String, dynamic>;
      final call = CallModel.fromJson(callJson);
      
      // Si l'autre personne a décroché (status 2), c'est qu'on est l'appelant
      // Si l'autre personne a raccroché ou refusé (status 3 ou 4), on ferme l'appel
      if (call.status == 3 || call.status == 4) {
        _webrtcService.endCall();
        _popCallScreen();
      } else if (call.status == 2) {
        // Le destinataire a accepté, on ouvre l'écran d'appel actif
        _showActiveCallScreen(call.receiver?.displayName ?? 'Inconnu', call.type == 2);
      }
    }
  }

  void _showIncomingCallScreen(CallModel call, UserModel caller) {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => IncomingCallScreen(
          call: call,
          caller: caller,
          onAccept: () async {
            Navigator.of(context).pop();
            await _webrtcService.acceptCall(caller.alanyaId, call.idCall, call.type == 2);
            _showActiveCallScreen(caller.displayName, call.type == 2);
          },
          onReject: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _showActiveCallScreen(String peerName, bool isVideo) {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ActiveCallScreen(
          webrtcService: _webrtcService,
          isVideo: isVideo,
          peerName: peerName,
          onEndCall: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _popCallScreen() {
    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      // Just pop if there's a dialog or screen on top.
      // Might need a more robust check to only pop the active call screen.
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> startOutgoingCall(UserModel target, bool isVideo) async {
    try {
      final callService = CallService();
      final call = await callService.initiateCall(target.alanyaId, type: isVideo ? 2 : 1);
      
      // Montrer tout de suite l'écran d'appel actif en mode sonnerie (outgoing)
      _showActiveCallScreen(target.displayName, isVideo);
      
      // Initialiser WebRTC et envoyer l'offre
      await _webrtcService.startCall(target.alanyaId, call.idCall, isVideo);
    } catch (e) {
      print("Erreur d'appel sortant: \$e");
    }
  }
}
