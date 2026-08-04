import '../models/http_record_model.dart';
import '../models/network_search_scope.dart';

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

  /// Count of case-insensitive substring occurrences of [query] in [text].
  static int countMatches(String text, String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return 0;

    final haystack = text.toLowerCase();
    var count = 0;
    var start = 0;
    while (true) {
      final index = haystack.indexOf(normalizedQuery, start);
      if (index < 0) break;
      count++;
      start = index + normalizedQuery.length;
    }
    return count;
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
