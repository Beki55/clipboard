import 'dart:async';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_background_service_ios/flutter_background_service_ios.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'websocket_service.dart';

class BackgroundClipboardService {
  static const String notificationChannelId = 'clipboard_monitor';
  static const String notificationChannelName = 'Clipboard Monitor';
  static const String notificationTitle = 'Clipboard Sync';
  static const String notificationContent = 'Monitoring clipboard in background';

  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: notificationChannelId,
        initialNotificationTitle: notificationTitle,
        initialNotificationContent: notificationContent,
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    // Initialize variables
    String? lastClipboardContent;
    WebSocketService? wsService;
    String? userId;
    String? deviceId;
    Timer? clipboardTimer;
    
    // Cleanup function
    void cleanup() {
      clipboardTimer?.cancel();
      wsService?.disconnect();
    }
    
    service.on('stopService').listen((event) {
      cleanup();
    });

    // Load user credentials
    try {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userId');
      deviceId = prefs.getString('deviceId');
      final token = prefs.getString('token');

      if (userId == null || deviceId == null || token == null) {
        service.invoke('updateStatus', {'status': 'Not logged in'});
        return;
      }

      // Initialize WebSocket connection
      wsService = WebSocketService(
        url: 'ws://localhost:3000?userId=$userId&deviceId=$deviceId',
      );

      wsService.onReceive = (data) {
        final content = data is String ? data : (data["content"] ?? data["data"]?["content"]);
        if (content != null && content is String) {
          // Update clipboard when receiving from server
          FlutterClipboard.copy(content);
          lastClipboardContent = content; // Prevent loop
        }
      };

      wsService.connect();
      service.invoke('updateStatus', {'status': 'Connected'});

      // Start clipboard monitoring
      clipboardTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        try {
          final currentContent = await FlutterClipboard.paste();

          // Only send if content changed and is different from last received
          if (currentContent != lastClipboardContent &&
              currentContent.isNotEmpty &&
              wsService != null &&
              userId != null &&
              deviceId != null) {
            // Send to server
            wsService.sendClipboard(userId, deviceId, currentContent);
            lastClipboardContent = currentContent;

            // Reset after delay to allow new changes
            Future.delayed(const Duration(milliseconds: 500), () {
              if (lastClipboardContent == currentContent) {
                lastClipboardContent = null;
              }
            });
          }
        } catch (e) {
          // Silently handle clipboard access errors
        }
      });

    } catch (e) {
      service.invoke('updateStatus', {'status': 'Error: $e'});
    }
  }

  static Future<void> startService() async {
    final service = FlutterBackgroundService();
    await service.startService();
  }

  static Future<void> stopService() async {
    final service = FlutterBackgroundService();
    service.invoke('stopService');
  }

  static Future<bool> isServiceRunning() async {
    final service = FlutterBackgroundService();
    return await service.isRunning();
  }
}

