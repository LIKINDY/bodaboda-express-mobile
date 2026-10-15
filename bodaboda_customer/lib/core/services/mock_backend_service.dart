import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:web_socket_channel/web_socket_channel.dart';

class MockBackendService {
  static final MockBackendService instance = MockBackendService._internal();
  WebSocketChannel? _channel;
  Function(Map<String, dynamic>)? onMessageReceived;

  MockBackendService._internal();

  void connect() {
    try {
      final host = (!kIsWeb && Platform.isAndroid) ? '10.0.2.2' : 'localhost';
      _channel = WebSocketChannel.connect(Uri.parse('ws://$host:3000/ws'));
      _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          if (onMessageReceived != null) {
            onMessageReceived!(data);
          }
        },
        onError: (e) => print('WebSocket error: $e'),
        onDone: () => print('WebSocket disconnected'),
      );
    } catch (e) {
      print('Could not connect to mock backend: $e');
    }
  }

  void sendRideRequest(Map<String, dynamic> rideData) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode({
        'type': 'new_ride',
        'data': rideData,
      }));
    }
  }

  void disconnect() {
    _channel?.sink.close();
  }
}
