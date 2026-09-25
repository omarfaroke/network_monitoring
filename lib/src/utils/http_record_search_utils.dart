import '../models/http_record_model.dart';
import '../models/network_search_scope.dart';

/// Options for find-in-page style matching.
class DetailSearchOptions {
  /// When `true`, matching is case-sensitive.
  final bool matchCase;

  /// When `true`, only whole-word matches are counted.
  final bool matchWholeWord;

  const DetailSearchOptions({
    this.matchCase = false,
    this.matchWholeWord = false,
  });

  static const defaults = DetailSearchOptions();

  DetailSearchOptions copyWith({bool? matchCase, bool? matchWholeWord}) {
    return DetailSearchOptions(
      matchCase: matchCase ?? this.matchCase,
      matchWholeWord: matchWholeWord ?? this.matchWholeWord,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetailSearchOptions &&
          matchCase == other.matchCase &&
          matchWholeWord == other.matchWholeWord;

  @override
  int get hashCode => Object.hash(matchCase, matchWholeWord);
}

/// Search helpers for [HttpRecordModel] against [NetworkSearchScope]s.
abstract final class HttpRecordSearchUtils {
  HttpRecordSearchUtils._();

  /// Whether [record] matches [query] within any of [scopes].
  ///
  /// Empty [query] always matches. Empty [scopes] never matches a non-empty
  /// query.
  static bool matches(
    HttpRecordModel record,
    String query, {
    Set<NetworkSearchScope> scopes = NetworkSearchScopes.defaults,
  }) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;
    if (scopes.isEmpty) return false;

    for (final scope in scopes) {
      if (_matchesScope(record, normalized, scope)) return true;
    }
    return false;
  }

  /// Start indexes of each occurrence of [query] in [text].
  static List<int> findMatchStarts(
    String text,
    String query, {
    DetailSearchOptions options = DetailSearchOptions.defaults,
  }) {
    final needle = query.trim();
    if (needle.isEmpty || text.isEmpty) return const [];

    final haystack = options.matchCase ? text : text.toLowerCase();
    final pattern = options.matchCase ? needle : needle.toLowerCase();
    final starts = <int>[];
    var start = 0;
    while (true) {
      final index = haystack.indexOf(pattern, start);
      if (index < 0) break;
      if (!options.matchWholeWord ||
          _isWholeWordAt(text, index, needle.length)) {
        starts.add(index);
      }
      start = index + pattern.length;
    }
    return starts;
  }

  /// Count of substring occurrences of [query] in [text].
  static int countMatches(
    String text,
    String query, {
    DetailSearchOptions options = DetailSearchOptions.defaults,
  }) {
    return findMatchStarts(text, query, options: options).length;
  }

  /// Whether [text] contains [query] (case-insensitive).
  static bool textContains(String text, String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return false;
    return text.toLowerCase().contains(normalizedQuery);
  }

  /// Collects searchable text for [record] limited to [scopes].
  static String searchableText(
    HttpRecordModel record, {
    Set<NetworkSearchScope> scopes = NetworkSearchScopes.all,
  }) {
    final buffer = StringBuffer();
    for (final scope in scopes) {
      final chunk = _scopeText(record, scope);
      if (chunk.isEmpty) continue;
      if (buffer.isNotEmpty) buffer.writeln();
      buffer.write(chunk);
    }
    return buffer.toString();
  }

  static final RegExp _wordCharPattern = RegExp(
    r'[\p{L}\p{N}\p{M}_]',
    unicode: true,
  );

  static bool _isWordChar(int unit) {
    return _wordCharPattern.hasMatch(String.fromCharCode(unit));
  }

  static bool _isWholeWordAt(String text, int start, int length) {
    if (start > 0 && _isWordChar(text.codeUnitAt(start - 1))) return false;
    final end = start + length;
    if (end < text.length && _isWordChar(text.codeUnitAt(end))) return false;
    return true;
  }

  static bool _matchesScope(
    HttpRecordModel record,
    String query,
    NetworkSearchScope scope,
  ) {
    return _scopeText(record, scope).toLowerCase().contains(query);
  }

  static String _scopeText(HttpRecordModel record, NetworkSearchScope scope) {
    switch (scope) {
      case NetworkSearchScope.url:
        return '${record.url}\n${record.path}\n${record.baseUrl}';
      case NetworkSearchScope.status:
        final parts = <String>[
          if (record.statusCode != null) '${record.statusCode}',
          if (record.statusMessage != null) record.statusMessage!,
          if (record.errorMessage != null) record.errorMessage!,
        ];
        return parts.join('\n');
      case NetworkSearchScope.headers:
        return '${record.requestHeadersFormatted}\n'
            '${record.responseHeadersFormatted}';
      case NetworkSearchScope.query:
        return record.queryParametersFormatted;
      case NetworkSearchScope.requestBody:
        return record.requestBodyFormatted;
      case NetworkSearchScope.responseBody:
        return record.responseBodyFormatted;
    }
  }
}
