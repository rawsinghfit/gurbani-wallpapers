import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/verse.dart';

enum SearchMode { firstLetters, wholeWords }

class BaniDbException implements Exception {
  const BaniDbException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Reads Gurbani live from the BaniDB API by Khalis Foundation.
class BaniDbService {
  BaniDbService({http.Client? client}) : _client = client ?? http.Client();

  static const _baseUrl = 'https://api.banidb.com/v2';
  static const _timeout = Duration(seconds: 15);
  static final _gurmukhi = RegExp(r'[਀-੿]');

  static const networkError =
      "Couldn't reach the Gurbani database. Check your internet connection and try again.";

  final http.Client _client;

  /// BaniDB search types: 1 = Gurmukhi first letters (anywhere),
  /// 7 = romanized first letters, 2 = Gurmukhi whole word,
  /// 4 = romanized whole word.
  static int searchTypeFor(String query, SearchMode mode) {
    final isGurmukhi = _gurmukhi.hasMatch(query);
    switch (mode) {
      case SearchMode.firstLetters:
        return isGurmukhi ? 1 : 7;
      case SearchMode.wholeWords:
        return isGurmukhi ? 2 : 4;
    }
  }

  Future<List<Verse>> search(String query, SearchMode mode) {
    final q = query.trim();
    final type = searchTypeFor(q, mode);
    return _get(
      '$_baseUrl/search/${Uri.encodeComponent(q)}'
      '?searchtype=$type&source=all&results=40',
    );
  }

  Future<List<Verse>> randomShabad() => _get('$_baseUrl/random/G');

  Future<List<Verse>> _get(String url) async {
    final http.Response response;
    try {
      response = await _client.get(Uri.parse(url)).timeout(_timeout);
    } catch (_) {
      throw const BaniDbException(networkError);
    }
    if (response.statusCode != 200) {
      throw const BaniDbException(networkError);
    }
    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      return Verse.listFromResponse(body);
    } catch (_) {
      throw const BaniDbException(
        'The Gurbani database sent an unexpected reply. Please try again.',
      );
    }
  }
}
