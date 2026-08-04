/// Fields that list and detail search can match against.
enum NetworkSearchScope {
  /// Full URL and path.
  url,

  /// HTTP status code and status message.
  status,

  /// Request and response headers.
  headers,

  /// Query parameters.
  query,

  /// Request body.
  requestBody,

  /// Response body.
  responseBody,
}

/// Default and convenience sets for [NetworkSearchScope].
abstract final class NetworkSearchScopes {
  NetworkSearchScopes._();

  /// Default list search: URL/path and status code (legacy behavior).
  static const Set<NetworkSearchScope> defaults = {
    NetworkSearchScope.url,
    NetworkSearchScope.status,
  };

  /// Every searchable field.
  static const Set<NetworkSearchScope> all = {
    NetworkSearchScope.url,
    NetworkSearchScope.status,
    NetworkSearchScope.headers,
    NetworkSearchScope.query,
    NetworkSearchScope.requestBody,
    NetworkSearchScope.responseBody,
  };
}
