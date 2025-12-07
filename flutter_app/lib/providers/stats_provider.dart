import 'package:flutter/foundation.dart';
import 'package:cid_retranslator/models/stats_data.dart';
import 'package:cid_retranslator/services/api_service.dart';
import 'package:cid_retranslator/services/websocket_service.dart';

class StatsProvider with ChangeNotifier {
  final ApiService _apiService;
  final WebSocketService _wsService;

  StatsData _stats = StatsData.initial();
  bool _isLoading = false;
  String? _error;

  StatsData get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  StatsProvider({
    required ApiService apiService,
    required WebSocketService wsService,
  }) : _apiService = apiService,
       _wsService = wsService {
    // Listen to WebSocket updates
    _wsService.statsUpdates.listen(_handleStatsUpdate);

    // Listen to connection status
    _wsService.connectionStatus.listen((connected) {
      // Update connection status in stats if needed
      notifyListeners();
    });

    // Load initial data
    loadStats();
  }

  // Load stats from API
  Future<void> loadStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stats = await _apiService.getStats();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _stats = StatsData.initial();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Handle stats update from WebSocket
  void _handleStatsUpdate(StatsData newStats) {
    _stats = newStats;
    notifyListeners();
  }
}
