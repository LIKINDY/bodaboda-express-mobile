import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:web_socket_channel/web_socket_channel.dart';

class MockBackendService {
  static final MockBackendService instance = MockBackendService._internal();
  WebSocketChannel? _channel;
  Function(Map<String, dynamic>)? onRideRequestReceived;

  MockBackendService._internal();

  void connect() {
    try {
      final host = (!kIsWeb && Platform.isAndroid) ? '10.0.2.2' : 'localhost';
      _channel = WebSocketChannel.connect(Uri.parse('ws://$host:3000/ws'));
      _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          if (data['type'] == 'new_ride') {
            if (onRideRequestReceived != null) {
              onRideRequestReceived!(data['data']);
            }
          }
        },
        onError: (e) => print('WebSocket error: $e'),
        onDone: () => print('WebSocket disconnected'),
      );
    } catch (e) {
      print('Could not connect to mock backend: $e');
    }
  }

  void acceptRide(String rideId) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode({
        'type': 'ride_accepted',
        'rideId': rideId,
      }));
    }
  }

  void updateDriverStatus(String status) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode({
        'type': 'driver_status_update',
        'status': status,
      }));
    }
  }

  void disconnect() {
    _channel?.sink.close();
  }
}
