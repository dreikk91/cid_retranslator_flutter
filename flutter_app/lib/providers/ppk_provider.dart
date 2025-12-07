import 'package:flutter/foundation.dart';
import 'package:cid_retranslator/models/ppk_item.dart';
import 'package:cid_retranslator/services/api_service.dart';
import 'package:cid_retranslator/services/websocket_service.dart';

class PPKProvider with ChangeNotifier {
  final ApiService _apiService;
  final WebSocketService _wsService;

  List<PPKItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<PPKItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  PPKProvider({
    required ApiService apiService,
    required WebSocketService wsService,
  }) : _apiService = apiService,
       _wsService = wsService {
    // Listen to WebSocket updates
    _wsService.ppkUpdates.listen(_handlePPKUpdate);

    // Load initial data
    loadPPKList();
  }

  // Load PPK list from API
  Future<void> loadPPKList() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _apiService.getPPKList();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Handle PPK update from WebSocket
  void _handlePPKUpdate(PPKItem updatedItem) {
    final index = _items.indexWhere(
      (item) => item.number == updatedItem.number,
    );

    if (index != -1) {
      // Update existing item
      _items[index] = updatedItem;
    } else {
      // Add new item
      _items.add(updatedItem);
    }

    notifyListeners();
  }

  // Get PPK item by number
  PPKItem? getPPKByNumber(int number) {
    try {
      return _items.firstWhere((item) => item.number == number);
    } catch (e) {
      return null;
    }
  }

  // Sort items with null-safe comparison
  void sortItems(String column, bool ascending) {
    _items.sort((a, b) {
      int comparison = 0;
      switch (column) {
        case 'number':
          comparison = a.number.compareTo(b.number);
          break;
        case 'name':
          comparison = (a.name ?? '').compareTo(b.name ?? '');
          break;
        case 'event':
          comparison = (a.event ?? '').compareTo(b.event ?? '');
          break;
        case 'date':
          final aDate = a.date ?? DateTime(1970);
          final bDate = b.date ?? DateTime(1970);
          comparison = aDate.compareTo(bDate);
          break;
      }
      return ascending ? comparison : -comparison;
    });
    notifyListeners();
  }
}
