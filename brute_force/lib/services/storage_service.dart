import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/run.dart';

class StorageService {
  static const String _setsKey = 'sets';
  static const String _currentSetIdKey = 'current_set_id';

  final SharedPreferences _prefs;

  StorageService._(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService._(prefs);
  }

  List<Run> loadRuns() {
    final String? setsJson = _prefs.getString(_setsKey);
    if (setsJson == null) return [];

    final List<dynamic> setsList = jsonDecode(setsJson);
    return setsList.map((json) => Run.fromJson(json)).toList();
  }

  Future<void> saveRuns(List<Run> sets) async {
    final String setsJson = jsonEncode(sets.map((set) => set.toJson()).toList());
    await _prefs.setString(_setsKey, setsJson);
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