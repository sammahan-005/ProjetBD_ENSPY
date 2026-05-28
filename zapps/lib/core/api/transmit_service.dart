import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zapps/core/api/api_constants.dart';
import 'package:zapps/core/utils/auth_storage.dart';

typedef SseEventCallback = void Function(String event, Map<String, dynamic> data);

class TransmitService {
  static final TransmitService _instance = TransmitService._internal();
  factory TransmitService() => _instance;
  TransmitService._internal();

  final Map<String, List<SseEventCallback>> _listeners = {};
  http.Client? _client;
  StreamSubscription? _subscription;
  bool _connected = false;

  bool get isConnected => _connected;

  /// Se connecter au flux SSE global de Transmit
  Future<void> connect() async {
    if (_connected) return;
    final token = await AuthStorage.getToken();
    if (token == null) return;

    _client = http.Client();
    final request = http.Request('GET', Uri.parse('$kTransmitUrl/events'));
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'text/event-stream';
    request.headers['Cache-Control'] = 'no-cache';

    try {
      final response = await _client!.send(request);
      _connected = true;

      String buffer = '';
      _subscription = response.stream
          .transform(utf8.decoder)
          .listen(
        (chunk) {
          buffer += chunk;
          final lines = buffer.split('\n');
          buffer = lines.removeLast(); // ligne incomplète

          String? event;
          String? dataLine;

          for (final line in lines) {
            if (line.startsWith('event:')) {
              event = line.substring(6).trim();
            } else if (line.startsWith('data:')) {
              dataLine = line.substring(5).trim();
            } else if (line.isEmpty && event != null && dataLine != null) {
              _dispatch(event, dataLine);
              event = null;
              dataLine = null;
            }
          }
        },
        onDone: () {
          _connected = false;
          _reconnect();
        },
        onError: (_) {
          _connected = false;
          _reconnect();
        },
      );
    } catch (_) {
      _connected = false;
    }
  }

  /// S'abonner à un canal Transmit
  Future<void> subscribe(String channel) async {
    final token = await AuthStorage.getToken();
    if (token == null) return;

    await http.post(
      Uri.parse('$kTransmitUrl/subscribe'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'channel': channel}),
    );
  }

  /// Se désabonner d'un canal
  Future<void> unsubscribe(String channel) async {
    final token = await AuthStorage.getToken();
    if (token == null) return;

    await http.post(
      Uri.parse('$kTransmitUrl/unsubscribe'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'channel': channel}),
    );
  }

  /// Écouter les événements d'un canal
  void on(String channel, SseEventCallback callback) {
    _listeners.putIfAbsent(channel, () => []).add(callback);
  }

  /// Arrêter d'écouter un canal
  void off(String channel) {
    _listeners.remove(channel);
  }

  void _dispatch(String channel, String rawData) {
    try {
      final data = jsonDecode(rawData) as Map<String, dynamic>;
      final callbacks = _listeners[channel] ?? [];
      final event = data['event'] as String? ?? '';
      for (final cb in callbacks) {
        cb(event, data);
      }
    } catch (_) {}
  }

  Future<void> _reconnect() async {
    await Future.delayed(const Duration(seconds: 3));
    await connect();
  }

  void disconnect() {
    _subscription?.cancel();
    _client?.close();
    _connected = false;
    _listeners.clear();
  }
}
