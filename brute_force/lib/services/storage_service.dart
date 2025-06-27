import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/run.dart';

class StorageException implements Exception {
  final String message;
  StorageException(this.message);

  @override
  String toString() => message;
}

class StorageService {
  static const String _setsKey = 'sets';
  static const String _currentSetIdKey = 'current_set_id';
  // Most browsers limit localStorage to 5-10MB, we'll be conservative
  static const int _maxStorageBytes = 4 * 1024 * 1024; // 4MB limit

  final SharedPreferences _prefs;

  StorageService._(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService._(prefs);
  }

  // Estimate the storage size needed for a run
  int _estimateRunSize(Run run) {
    // Convert to JSON to get actual storage size
    final jsonData = run.toJson();
    final jsonString = json.encode(jsonData);
    // Return size in bytes (2 bytes per character for UTF-16)
    return jsonString.length * 2;
  }

  // Check if we have enough storage space
  Future<bool> hasEnoughSpaceForRun(Run newRun) async {
    try {
      final estimatedSize = _estimateRunSize(newRun);
      
      // Get current storage size
      final currentSets = loadRuns();
      int currentSize = 0;
      for (final set in currentSets) {
        currentSize += _estimateRunSize(set);
      }

      // Check if adding new run would exceed limit
      return (currentSize + estimatedSize) < _maxStorageBytes;
    } catch (e) {
      return false;
    }
  }

  List<Run> loadRuns() {
    try {
      final String? setsJson = _prefs.getString(_setsKey);
      if (setsJson == null) return [];

      final List<dynamic> setsList = jsonDecode(setsJson);
      return setsList.map((json) => Run.fromJson(json)).toList();
    } catch (e) {
      print('Error loading runs: $e');
      return [];
    }
  }

  Future<void> saveRuns(List<Run> sets) async {
    try {
      final String setsJson = jsonEncode(sets.map((set) => set.toJson()).toList());
      final success = await _prefs.setString(_setsKey, setsJson);
      
      if (!success) {
        throw StorageException('Failed to save sets due to storage quota exceeded');
      }
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException('Failed to save sets: ${e.toString()}');
    }
  }

  String? loadCurrentRunId() {
    return _prefs.getString(_currentSetIdKey);
  }

  Future<void> saveCurrentRunId(String? setId) async {
    if (setId != null) {
      await _prefs.setString(_currentSetIdKey, setId);
    } else {
      await _prefs.remove(_currentSetIdKey);
    }
  }
} 