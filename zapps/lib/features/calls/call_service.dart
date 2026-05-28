import 'package:zapps/core/api/api_client.dart';
import 'package:zapps/core/models/call_model.dart';

class CallService {
  final _api = ApiClient();

  Future<List<CallModel>> getCalls() async {
    final res = await _api.get('/calls');
    final list = res.data as List<dynamic>;
    return list.map((e) => CallModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CallModel> initiateCall(int receiverId, {int type = 1}) async {
    final res = await _api.post('/calls', data: {'idReceiver': receiverId, 'type': type});
    return CallModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<CallModel> updateCallStatus(int callId, int status, {int? duree}) async {
    final res = await _api.put('/calls/$callId', data: {
      'status': status,
      if (duree != null) 'duree': duree,
    });
    return CallModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> sendSignal(int targetUserId, dynamic signalData) async {
    await _api.post('/calls/signal', data: {
      'targetUserId': targetUserId,
      'signalData': signalData,
    });
  }
}
