import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// A tiny key-value cache of JSON documents. Version 1 shows the last loaded
/// data when the phone is offline (spec 5.1), so repositories write what they
/// loaded here and read it back when there is no connection.
abstract interface class JsonCache {
  Future<Object?> read(String key);

  Future<void> write(String key, Object value);

  Future<void> remove(String key);
}

class SharedPreferencesJsonCache implements JsonCache {
  static const String _prefix = 'cache.';

  @override
  Future<Object?> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix$key');
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null; // a damaged entry is a cache miss, not a crash
    }
  }

  @override
  Future<void> write(String key, Object value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix$key', jsonEncode(value));
  }

  @override
  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$key');
  }
}

class InMemoryJsonCache implements JsonCache {
  final Map<String, String> _data = <String, String>{};

  @override
  Future<Object?> read(String key) async {
    final raw = _data[key];
    return raw == null ? null : jsonDecode(raw);
  }

  @override
  Future<void> write(String key, Object value) async =>
      _data[key] = jsonEncode(value);

  @override
  Future<void> remove(String key) async => _data.remove(key);
}
