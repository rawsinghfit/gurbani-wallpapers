/// One line of Gurbani exactly as returned by the BaniDB API.
///
/// The text fields are never modified by the app; they are only displayed.
class Verse {
  const Verse({
    required this.gurmukhi,
    this.transliteration = '',
    this.meaning = '',
    this.ang,
    this.sourceName = '',
  });

  final String gurmukhi;
  final String transliteration;
  final String meaning;
  final int? ang;
  final String sourceName;

  /// e.g. "Sri Guru Granth Sahib Ji, Ang 1"
  String get reference {
    final parts = <String>[
      if (sourceName.isNotEmpty) sourceName,
      if (ang != null) 'Ang $ang',
    ];
    return parts.join(', ');
  }

  /// Parses one item of a BaniDB v2 "verses" list.
  ///
  /// [fallbackSource] is used when the verse has no "source" of its own
  /// (the /random endpoint puts it in "shabadInfo" instead).
  /// Returns null when the item has no Gurmukhi text.
  static Verse? fromJson(dynamic json, {Map<String, dynamic>? fallbackSource}) {
    if (json is! Map) return null;

    final gurmukhi = _string(_path(json, ['verse', 'unicode']));
    if (gurmukhi.isEmpty) return null;

    final translationEn = _path(json, ['translation', 'en']);
    var meaning = '';
    for (final key in const ['bdb', 'ms', 'ssk']) {
      meaning = _string(_path(translationEn, [key]));
      if (meaning.isNotEmpty) break;
    }

    final source = json['source'] is Map ? json['source'] : fallbackSource;

    return Verse(
      gurmukhi: gurmukhi,
      transliteration: _string(_path(json, ['transliteration', 'english'])),
      meaning: meaning,
      ang: _int(json['pageNo']) ?? _int(_path(source, ['pageNo'])),
      sourceName: _string(_path(source, ['english'])),
    );
  }

  /// Parses the "verses" list of a /search or /random response.
  static List<Verse> listFromResponse(dynamic body) {
    if (body is! Map) return const [];
    final verses = body['verses'];
    if (verses is! List) return const [];

    final info = body['shabadInfo'];
    final fallbackSource = info is Map && info['source'] is Map
        ? Map<String, dynamic>.from(info['source'] as Map)
        : null;

    return verses
        .map((v) => Verse.fromJson(v, fallbackSource: fallbackSource))
        .whereType<Verse>()
        .toList();
  }
}

dynamic _path(dynamic node, List<String> keys) {
  var current = node;
  for (final key in keys) {
    if (current is! Map) return null;
    current = current[key];
  }
  return current;
}

String _string(dynamic value) => value is String ? value.trim() : '';

int? _int(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
