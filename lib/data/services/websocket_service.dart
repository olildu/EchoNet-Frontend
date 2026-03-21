import 'dart:async'; // NEW IMPORT
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  WebSocketChannel? _channel;
  final String url = "ws://192.168.137.1:8000/ws/live-tracking";
  
  // NEW: Broadcast stream allows Chat, Tasks, and Maps to all listen to the same socket
  final _broadcastController = StreamController<dynamic>.broadcast();

  void connect() {
    if (_channel != null) return; // Prevent multiple connections
    
    _channel = WebSocketChannel.connect(Uri.parse(url));
    
    // Pipe all incoming websocket traffic into our broadcast controller
    _channel!.stream.listen(
      (message) => _broadcastController.add(message),
      onDone: () => _channel = null,
      onError: (e) => _channel = null,
    );
  }

  // Blocs will now listen to this broadcast stream instead
  Stream get stream => _broadcastController.stream;

  void sendMessage(String message) {
    _channel?.sink.add(message);
  }

  void close() {
    _channel?.sink.close(status.goingAway);
    _channel = null;
  }
}