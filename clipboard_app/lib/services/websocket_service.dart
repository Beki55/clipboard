import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebSocketService {
  final String url;
  late IO.Socket socket;
  Function(dynamic data)? onReceive;

  WebSocketService({required this.url});

  void connect() {
    socket = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .build(),
    );

    // Server emits 'clipboard:receive' with the content
    socket.on('clipboard:receive', (data) {
      if (onReceive != null) onReceive!(data);
    });

    socket.onDisconnect((_) {
      print('Socket disconnected');
    });

    socket.onError((err) {
      print('Socket error: $err');
    });
  }

  void sendClipboard(String userId, String deviceId, String content) {
    socket.emit('clipboard:update', {
      'userId': int.tryParse(userId) ?? userId,
      'deviceId': deviceId,
      'content': content,
    });
  }

  void disconnect() {
    socket.dispose();
  }
}
