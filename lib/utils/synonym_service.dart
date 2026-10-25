import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Gets synonyms and antonyms of an English word from the Datamuse API.
/// Returns null when the request fails (offline, slow, server error)
/// or when the user turned the online lookup off in Settings.
class SynonymService {
  // Set from Settings through ThemeProvider
  static bool enabled = true;

  static Future<({String synonyms, String antonyms})?> fetch(
    String word,
  ) async {
    if (!enabled) return null;
    try {
      final clean = word.trim();
      final res = await Future.wait([
        http.get(
          Uri.https('api.datamuse.com', '/words', {
            'rel_syn': clean,
            'max': '5',
          }),
        ),
        http.get(
          Uri.https('api.datamuse.com', '/words', {
            'rel_ant': clean,
            'max': '5',
          }),
        ),
      ]).timeout(const Duration(seconds: 8));

      if (res[0].statusCode != 200 || res[1].statusCode != 200) return null;

      String join(String body) => (json.decode(body) as List)
          .map((e) => e['word'].toString())
          .take(5)
          .join(', ');

      return (synonyms: join(res[0].body), antonyms: join(res[1].body));
    } catch (e) {
      debugPrint('Datamuse API error: $e');
      return null;
    }
  }
}
