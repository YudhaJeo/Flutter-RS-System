// D:\Mobile App\flutter_sistem_rs\flutter_sistem_rs\lib\utils\app_env.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

class AppEnv {
  static String get baseUrl {
    final port = dotenv.env['EXPRESS_PORT'];
    final emulatorHost = dotenv.env['LOCAL_EMULATOR'];
    final physicalHost = dotenv.env['LOCAL_PHYSICAL'];

    // fallback default kalau env belum kebaca
    final defaultHost = '10.0.2.2';
    final defaultPort = '4100';

    final isEmulator = Platform.isAndroid &&
        (Platform.environment.containsKey('ANDROID_EMULATOR') ||
            Platform.operatingSystemVersion.contains('sdk_gphone') ||
            Platform.operatingSystemVersion.contains('emulator'));

    final host = isEmulator ? (emulatorHost ?? defaultHost) : (physicalHost ?? defaultHost);
    final usedPort = port ?? defaultPort;

    return 'http://$host:$usedPort';
  }
}
