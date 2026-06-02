/// Reads common auth token headers from HTTP request headers.
abstract final class AuthTokenUtils {
  AuthTokenUtils._();

  static const _headerKeys = [
    'Authorization',
    'authorization',
    'x-auth-token',
  ];

  static String? fromHeaders(Map<String, dynamic> headers) {
    for (final key in _headerKeys) {
      final value = headers[key];
      if (value != null) return value.toString();
    }
    return null;
  }
}
