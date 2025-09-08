import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceTokenHelper {
  static Future<String?> getFCMToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      print('📲 FCM Token: $token');
      return token;
    } catch (e) {
      print('🔥 Error getting FCM token: $e');
      return null;
    }
  }

  static Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id ;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? "unknown";
    } else {
      return "unsupported-platform";
    }
  }

}
