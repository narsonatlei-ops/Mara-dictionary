import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'app_info.dart';

class NewsItem {
  final String id;
  final String date;
  final String title;
  final String message;

  NewsItem({
    required this.id,
    required this.date,
    required this.title,
    required this.message,
  });

  factory NewsItem.fromJson(Map<String, dynamic> j) => NewsItem(
    id: j['id'].toString(),
    date: (j['date'] ?? '').toString(),
    title: (j['title'] ?? '').toString(),
    message: (j['message'] ?? '').toString(),
  );
}

class NewsData {
  final String latestVersion;
  final String updateUrl;
  final List<NewsItem> items;

  NewsData({
    required this.latestVersion,
    required this.updateUrl,
    required this.items,
  });

  bool get updateAvailable =>
      latestVersion.isNotEmpty &&
      NewsService.isNewer(latestVersion, AppInfo.version);

  // Used to remember that the update notice was already seen
  String get updateMarker => 'update_$latestVersion';
}

/// Reads news.json from the web page, keeps a copy for offline use
/// and counts the news the user has not opened yet.
class NewsService {
  static const _cacheKey = 'newsJson';
  static const _seenKey = 'seenNewsIds';
  static const _promptKey = 'promptedVersion';

  static NewsData? current;
  static final ValueNotifier<int> unread = ValueNotifier<int>(0);

  // true when version a is higher than version b (1.0.1 > 1.0.0)
  static bool isNewer(String a, String b) {
    List<int> parse(String v) => v
        .split('+')
        .first
        .split('.')
        .map((e) => int.tryParse(e.trim()) ?? 0)
        .toList();
    final x = parse(a);
    final y = parse(b);
    for (var i = 0; i < 3; i++) {
      final p = i < x.length ? x[i] : 0;
      final q = i < y.length ? y[i] : 0;
      if (p != q) return p > q;
    }
    return false;
  }

  // The saved copy is used first, then the internet is tried
  static Future<void> check() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);
    if (cached != null) _apply(cached, prefs);

    try {
      final res = await http
          .get(Uri.parse(AppInfo.newsUrl))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final body = utf8.decode(res.bodyBytes);
        json.decode(body); // stop here if the file is not valid JSON
        await prefs.setString(_cacheKey, body);
        _apply(body, prefs);
      }
    } catch (e) {
      debugPrint('News check failed: $e');
    }
  }

  static void _apply(String body, SharedPreferences prefs) {
    try {
      final map = json.decode(body) as Map<String, dynamic>;
      final items = ((map['items'] ?? []) as List)
          .map((e) => NewsItem.fromJson(e as Map<String, dynamic>))
          .toList();
      final data = NewsData(
        latestVersion: (map['latest_version'] ?? '').toString(),
        updateUrl: (map['update_url'] ?? '').toString(),
        items: items,
      );
      current = data;

      final seen = prefs.getStringList(_seenKey) ?? [];
      var count = items.where((i) => !seen.contains(i.id)).length;
      if (data.updateAvailable && !seen.contains(data.updateMarker)) count++;
      unread.value = count;
    } catch (e) {
      debugPrint('News file error: $e');
    }
  }

  // Called when the News screen is opened
  static Future<void> markAllSeen() async {
    final data = current;
    if (data == null) return;
    final prefs = await SharedPreferences.getInstance();
    final seen = <String>{
      ...(prefs.getStringList(_seenKey) ?? []),
      ...data.items.map((i) => i.id),
      data.updateMarker,
    };
    await prefs.setStringList(_seenKey, seen.toList());
    unread.value = 0;
  }

  // The update dialog is shown once for each new version
  static Future<bool> shouldPromptUpdate() async {
    final data = current;
    if (data == null || !data.updateAvailable) return false;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_promptKey) != data.latestVersion;
  }

  static Future<void> markUpdatePrompted() async {
    final data = current;
    if (data == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_promptKey, data.latestVersion);
  }
}
