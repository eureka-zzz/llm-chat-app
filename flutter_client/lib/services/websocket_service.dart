import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/message.dart';

class WebSocketService {
  static const String baseUrl = 'ws://82298cb6fbaf643872.blackbx.ai';
  WebSocketChannel? _channel;
  Function(Message)? onMessageReceived;
  
  // Connect to WebSocket
  void connect(int userId) {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('$baseUrl/ws/$userId'),
      );
      
      // Listen for incoming messages
      _channel!.stream.listen(
        (data) {
          try {
            final messageJson = jsonDecode(data);
            final message = Message.fromJson(messageJson);
            onMessageReceived?.call(message);
          } catch (e) {
            print('Error parsing message: $e');
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
        },
        onDone: () {
          print('WebSocket connection closed');
        },
      );
    } catch (e) {
      print('Error connecting to WebSocket: $e');
    }
  }
  
  // Send a message
  void sendMessage(int receiverId, String messageType, String content) {
    if (_channel != null) {
      final message = {
        'to': receiverId,
        'type': messageType,
        'content': content,
      };
      
      _channel!.sink.add(jsonEncode(message));
    }
  }
  
  // Disconnect from WebSocket
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
  
  // Check if connected
  bool get isConnected => _channel != null;
}
