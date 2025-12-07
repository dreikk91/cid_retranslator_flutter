import 'package:flutter/foundation.dart';
import 'package:cid_retranslator/models/event_item.dart';
import 'package:cid_retranslator/services/api_service.dart';
import 'package:cid_retranslator/services/websocket_service.dart';

class EventProvider with ChangeNotifier {
  final ApiService _apiService;
  final WebSocketService _wsService;

  List<EventItem> _events = [];
  bool _isLoading = false;
  String? _error;

  List<EventItem> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;

  EventProvider({
    required ApiService apiService,
    required WebSocketService wsService,
  }) : _apiService = apiService,
       _wsService = wsService {
    // Listen to WebSocket updates
    _wsService.eventUpdates.listen(_handleEventUpdate);

    // Load initial data
    loadEvents();
  }

  // Load events from API
  Future<void> loadEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await _apiService.getEvents();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _events = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Handle event update from WebSocket
  void _handleEventUpdate(EventItem newEvent) {
    // Add new event to list (prepend to show newest first)
    _events.insert(0, newEvent);

    // Limit to max 500 events
    if (_events.length > 500) {
      _events = _events.sublist(0, 500);
    }

    notifyListeners();
  }

  // Sort events with null-safe comparison
  void sortEvents(String column, bool ascending) {
    _events.sort((a, b) {
      int comparison = 0;
      switch (column) {
        case 'time':
          final aTime = a.time ?? DateTime(1970);
          final bTime = b.time ?? DateTime(1970);
          comparison = aTime.compareTo(bTime);
          break;
        case 'device':
          comparison = (a.device ?? '').compareTo(b.device ?? '');
          break;
        case 'code':
          comparison = (a.code ?? '').compareTo(b.code ?? '');
          break;
        case 'type':
          comparison = (a.type ?? '').compareTo(b.type ?? '');
          break;
        case 'desc':
          comparison = (a.desc ?? '').compareTo(b.desc ?? '');
          break;
        case 'zone':
          comparison = (a.zone ?? '').compareTo(b.zone ?? '');
          break;
        case 'priority':
          comparison = a.priority.compareTo(b.priority);
          break;
      }
      return ascending ? comparison : -comparison;
    });
    notifyListeners();
  }
}
