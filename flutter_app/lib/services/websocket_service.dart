import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:cid_retranslator/models/ppk_item.dart';
import 'package:cid_retranslator/models/event_item.dart';
import 'package:cid_retranslator/models/stats_data.dart';

enum WebSocketMessageType { ppkUpdate, eventUpdate, statsUpdate, unknown }

class WebSocketMessage {
  final WebSocketMessageType type;
  final dynamic data;

  WebSocketMessage({required this.type, required this.data});

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String;
    WebSocketMessageType type;

    switch (typeStr) {
      case 'ppk_update':
        type = WebSocketMessageType.ppkUpdate;
        break;
      case 'event_update':
        type = WebSocketMessageType.eventUpdate;
        break;
      case 'stats_update':
        type = WebSocketMessageType.statsUpdate;
        break;
      default:
        type = WebSocketMessageType.unknown;
    }

    return WebSocketMessage(type: type, data: json['data']);
  }
}

class WebSocketService {
  final String url;
  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  bool _isConnected = false;
  bool _shouldReconnect = true;

  // Stream controllers for different message types
  final _ppkUpdateController = StreamController<PPKItem>.broadcast();
  final _eventUpdateController = StreamController<EventItem>.broadcast();
  final _statsUpdateController = StreamController<StatsData>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  // Public streams
  Stream<PPKItem> get ppkUpdates => _ppkUpdateController.stream;
  Stream<EventItem> get eventUpdates => _eventUpdateController.stream;
  Stream<StatsData> get statsUpdates => _statsUpdateController.stream;
  Stream<bool> get connectionStatus => _connectionController.stream;

  bool get isConnected => _isConnected;

  WebSocketService({this.url = 'ws://localhost:8080/ws'});

  // Connect to WebSocket server
  void connect() {
    if (_isConnected) return;

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _isConnected = true;
      _connectionController.add(true);

      // Listen to messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
        cancelOnError: false,
      );

      print('WebSocket connected to $url');
    } catch (e) {
      print('WebSocket connection failed: $e');
      _scheduleReconnect();
    }
  }

  // Handle incoming messages
  void _handleMessage(dynamic message) {
    try {
      final json = jsonDecode(message as String);
      final wsMessage = WebSocketMessage.fromJson(json);

      switch (wsMessage.type) {
        case WebSocketMessageType.ppkUpdate:
          final ppkItem = PPKItem.fromJson(wsMessage.data);
          _ppkUpdateController.add(ppkItem);
          break;

        case WebSocketMessageType.eventUpdate:
          final eventItem = EventItem.fromJson(wsMessage.data);
          _eventUpdateController.add(eventItem);
          break;

        case WebSocketMessageType.statsUpdate:
          final statsData = StatsData.fromJson(wsMessage.data);
          _statsUpdateController.add(statsData);
          break;

        case WebSocketMessageType.unknown:
          print('Unknown WebSocket message type');
          break;
      }
    } catch (e) {
      print('Error handling WebSocket message: $e');
    }
  }

  // Handle WebSocket errors
  void _handleError(error) {
    print('WebSocket error: $error');
    _handleDisconnect();
  }

  // Handle disconnection
  void _handleDisconnect() {
    _isConnected = false;
    _connectionController.add(false);
    _channel = null;

    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }

  // Schedule reconnection attempt
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: 5), () {
      if (!_isConnected && _shouldReconnect) {
        print('Attempting to reconnect WebSocket...');
        connect();
      }
    });
  }

  // Disconnect from WebSocket
  void disconnect() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _isConnected = false;
    _connectionController.add(false);
  }

  // Dispose resources
  void dispose() {
    disconnect();
    _ppkUpdateController.close();
    _eventUpdateController.close();
    _statsUpdateController.close();
    _connectionController.close();
  }
}
