import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

// Sur Android Emulator: 10.0.2.2 = localhost de la machine hôte
// Sur Linux/iOS/physique: utiliser l'IP réelle ou localhost
String get kBaseUrl {
  if (!kIsWeb && Platform.isAndroid) {
    return 'http://10.0.2.2:3333/api/v1';
  }
  return 'http://192.168.1.120:3333/api/v1';
}

String get kTransmitUrl {
  if (!kIsWeb && Platform.isAndroid) {
    return 'http://10.0.2.2:3333/__transmit';
  }
  return 'http://192.168.1.120:3333/__transmit';
}

// Clé de stockage du token
const String kTokenKey = 'zapps_auth_token';
const String kUserIdKey = 'zapps_user_id';
