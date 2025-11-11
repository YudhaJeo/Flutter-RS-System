// D:\Mobile App\flutter_sistem_rs\flutter_sistem_rs\lib\utils\app_env.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  static String get baseUrl {
    final port = dotenv.env['EXPRESS_PORT'];
    final ipAddress = dotenv.env['IP_ADDRESS'];

    return 'http://${ipAddress ?? '10.0.2.2'}:${port ?? '4100'}';
  }
}
