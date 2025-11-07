import 'package:clipboard_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/clipboard_provider.dart';
import '../services/websocket_service.dart';
import '../services/clipboard_monitor_service.dart';
import '../models/clipboard_item.dart';
import 'package:clipboard/clipboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  final String deviceId;
  HomeScreen({required this.userId, required this.deviceId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late WebSocketService wsService;
  late ClipboardMonitorService clipboardMonitor;
  String? _currentDeviceId;
  String?
  _lastReceivedContent; // Track last content received from server to avoid loops

  @override
  void initState() {
    super.initState();
    initializeDevice();
  }

  Future<void> initializeDevice() async {
    // 1️⃣ Generate or load deviceId
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('deviceId');

    if (deviceId == null) {
      deviceId = "device-${DateTime.now().millisecondsSinceEpoch}";
      await prefs.setString('deviceId', deviceId);
    }

    _currentDeviceId = deviceId;

    // 2️⃣ Register device with backend BEFORE WS
    final api = ApiService(baseUrl: "http://localhost:3000"); // your backend IP
    await api.post("devices/register", {
      "deviceId": deviceId,
      "userId": int.parse(widget.userId),
      "deviceName": "Flutter Device",
    });

    // 3️⃣ Now connect WebSocket safely
    wsService = WebSocketService(
      url: "ws://localhost:3000?userId=${widget.userId}&deviceId=$deviceId",
    );

    wsService.onReceive = (data) {
      final content = data is String
          ? data
          : (data["content"] ?? data["data"]?["content"]);
      if (content != null && content is String) {
        // Update last received content to prevent loop
        _lastReceivedContent = content;
        FlutterClipboard.copy(content);
        Provider.of<ClipboardProvider>(
          context,
          listen: false,
        ).addItem(ClipboardItem(content: content, createdAt: DateTime.now()));
      }
    };

    wsService.connect();

    // 4️⃣ Start monitoring OS clipboard
    clipboardMonitor = ClipboardMonitorService();
    clipboardMonitor.onClipboardChanged = (content) {
      // Only send if it's different from what we just received (avoid loop)
      if (content != _lastReceivedContent && _currentDeviceId != null) {
        sendClipboardToServer(content);
        // Update last received to prevent immediate re-send
        _lastReceivedContent = content;
        // Reset after a delay to allow new changes
        Future.delayed(Duration(milliseconds: 500), () {
          if (_lastReceivedContent == content) {
            _lastReceivedContent = null;
          }
        });
      }
    };
    clipboardMonitor.startMonitoring();
  }

  @override
  void dispose() {
    clipboardMonitor.stopMonitoring();
    wsService.disconnect();
    super.dispose();
  }

  void sendClipboardToServer(String text) {
    if (_currentDeviceId != null) {
      wsService.sendClipboard(widget.userId, _currentDeviceId!, text);
      Provider.of<ClipboardProvider>(
        context,
        listen: false,
      ).addItem(ClipboardItem(content: text, createdAt: DateTime.now()));
    }
  }

  void sendClipboard(String text) {
    sendClipboardToServer(text);
  }

  @override
  Widget build(BuildContext context) {
    final clipboardItems = Provider.of<ClipboardProvider>(context).items;

    return Scaffold(
      appBar: AppBar(title: Text('Clipboard Sync')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(labelText: 'Type something'),
              onSubmitted: sendClipboard,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: clipboardItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(clipboardItems[index].content),
                  subtitle: Text(clipboardItems[index].createdAt.toString()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
