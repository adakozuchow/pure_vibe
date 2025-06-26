import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/run.dart';

class StorageService {
  static const String _runsKey = 'runs';
  static const String _currentRunIdKey = 'current_run_id';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  Future<void> saveRuns(List<Run> runs) async {
    final runsJson = runs.map((run) => run.toJson()).toList();
    await _prefs.setString(_runsKey, jsonEncode(runsJson));
  }

  Future<void> saveCurrentRunId(String? runId) async {
    if (runId != null) {
      await _prefs.setString(_currentRunIdKey, runId);
    } else {
      await _prefs.remove(_currentRunIdKey);
    }
  }

  List<Run> loadRuns() {
    final runsString = _prefs.getString(_runsKey);
    if (runsString == null) return [];

    try {
      final runsJson = jsonDecode(runsString) as List;
      return runsJson.map((json) => Run.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error loading runs: $e');
      return [];
    }
  }

  String? loadCurrentRunId() {
    return _prefs.getString(_currentRunIdKey);
  }
} 