import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/payload.dart';

class HistoryRepository {
  static const _key = 'payloadlab.history.v1';
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  Future<List<HistoryEntry>> load() async {
    final raw = await _prefs.getStringList(_key) ?? const [];
    return [
      for (final item in raw)
        HistoryEntry.fromJson(jsonDecode(item) as Map<String, Object?>),
    ];
  }

  Future<void> save(List<HistoryEntry> entries) async {
    final raw = entries.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList(_key, raw);
  }

  Future<void> clear() => _prefs.remove(_key);
}
