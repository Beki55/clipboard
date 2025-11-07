import 'dart:async';
import 'package:clipboard/clipboard.dart';

class ClipboardMonitorService {
  Timer? _timer;
  String? _lastClipboardContent;
  Function(String)? onClipboardChanged;

  void startMonitoring({Duration interval = const Duration(seconds: 1)}) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) async {
      await _checkClipboard();
    });
  }

  Future<void> _checkClipboard() async {
    try {
      final currentContent = await FlutterClipboard.paste();
      
      // Only trigger if content changed and is not empty
      if (currentContent != _lastClipboardContent && currentContent.isNotEmpty) {
        _lastClipboardContent = currentContent;
        if (onClipboardChanged != null) {
          onClipboardChanged!(currentContent);
        }
      }
    } catch (e) {
      // Silently handle clipboard access errors
      print('Error checking clipboard: $e');
    }
  }

  void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    stopMonitoring();
  }
}

