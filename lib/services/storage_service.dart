import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  Future<Map<String, dynamic>> getTodaySteps() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split("T")[0];
    final raw = prefs.getString(today);
    if (raw != null) {
      return jsonDecode(raw);
    }
    return {'steps': 0, 'lastUpdated': ''};
  }

  Future<void> saveSteps(String dateKey, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(dateKey, jsonEncode(data));
  }
}
