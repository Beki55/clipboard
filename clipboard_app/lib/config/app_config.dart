import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'http://localhost:3000';
  static String get wsUrl => dotenv.env['WS_URL'] ?? 'ws://localhost:3000';

  // Helper method to get WebSocket URL with query parameters
  static String getWebSocketUrl(String userId, String deviceId) {
    return '$wsUrl?userId=$userId&deviceId=$deviceId';
  }
}
