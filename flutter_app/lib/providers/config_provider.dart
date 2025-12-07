import 'package:flutter/foundation.dart';
import 'package:cid_retranslator/models/app_config.dart';
import 'package:cid_retranslator/services/api_service.dart';

class ConfigProvider with ChangeNotifier {
  final ApiService _apiService;

  AppConfig? _config;
  AppConfig? _originalConfig;
  bool _isLoading = false;
  String? _error;
  bool _hasChanges = false;

  AppConfig? get config => _config;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasChanges => _hasChanges;

  ConfigProvider({required ApiService apiService}) : _apiService = apiService {
    loadConfig();
  }

  // Load config from API
  Future<void> loadConfig() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.getConfig();
      _config = AppConfig.fromJson(data);
      _originalConfig = AppConfig.fromJson(data); // Keep original for reset
      _hasChanges = false;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save config to API
  Future<bool> saveConfig() async {
    if (_config == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.updateConfig(_config!.toJson());
      _originalConfig = AppConfig.fromJson(_config!.toJson());
      _hasChanges = false;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Reset to original config
  void resetConfig() {
    if (_originalConfig != null) {
      _config = AppConfig.fromJson(_originalConfig!.toJson());
      _hasChanges = false;
      notifyListeners();
    }
  }

  // Mark as changed
  void markChanged() {
    _hasChanges = true;
    notifyListeners();
  }

  // Update specific config section
  void updateServer(ServerConfig server) {
    if (_config != null) {
      _config!.server = server;
      markChanged();
    }
  }

  void updateClient(ClientConfig client) {
    if (_config != null) {
      _config!.client = client;
      markChanged();
    }
  }

  void updateQueue(QueueConfig queue) {
    if (_config != null) {
      _config!.queue = queue;
      markChanged();
    }
  }

  void updateLogging(LoggingConfig logging) {
    if (_config != null) {
      _config!.logging = logging;
      markChanged();
    }
  }

  void updateCIDRules(CIDRulesConfig cidRules) {
    if (_config != null) {
      _config!.cidRules = cidRules;
      markChanged();
    }
  }

  void updateMonitoring(MonitoringConfig monitoring) {
    if (_config != null) {
      _config!.monitoring = monitoring;
      markChanged();
    }
  }

  void updateUI(UIConfig ui) {
    if (_config != null) {
      _config!.ui = ui;
      markChanged();
    }
  }

  void updateHTTP(HTTPConfig http) {
    if (_config != null) {
      _config!.http = http;
      markChanged();
    }
  }
}
