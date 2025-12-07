import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cid_retranslator/models/ppk_item.dart';
import 'package:cid_retranslator/models/event_item.dart';
import 'package:cid_retranslator/models/stats_data.dart';

class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = 'http://localhost:8080'});

  // Get all PPK devices
  Future<List<PPKItem>> getPPKList() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/ppk'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => PPKItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load PPK list: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load PPK list: $e');
    }
  }

  // Get events for specific PPK device
  Future<List<EventItem>> getPPKEvents(int deviceId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/ppk/$deviceId/events'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => EventItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load PPK events: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load PPK events: $e');
    }
  }

  // Get all recent events
  Future<List<EventItem>> getEvents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/events'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => EventItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load events: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load events: $e');
    }
  }

  // Get current statistics
  Future<StatsData> getStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/stats'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return StatsData.fromJson(data);
      } else {
        throw Exception('Failed to load stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load stats: $e');
    }
  }

  // Get configuration
  Future<Map<String, dynamic>> getConfig() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/config'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load config: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load config: $e');
    }
  }

  // Update configuration
  Future<void> updateConfig(Map<String, dynamic> config) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/config'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(config),
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(
          'Failed to update config: ${error['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to update config: $e');
    }
  }
}
