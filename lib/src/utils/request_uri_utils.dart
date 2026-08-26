import 'package:dio/dio.dart';

/// Helpers for rewriting a Dio [RequestOptions] target URI.
abstract final class RequestUriUtils {
  RequestUriUtils._();

  /// Sets [options] so [RequestOptions.uri] equals [uri].
  static void applyToOptions(RequestOptions options, Uri uri) {
    options
      ..baseUrl = ''
      ..path = uri.toString()
      ..queryParameters.clear();
    _syncHostHeader(options, uri);
  }

  static void _syncHostHeader(RequestOptions options, Uri uri) {
    final host = uri.hasPort ? '${uri.host}:${uri.port}' : uri.host;
    for (final key in options.headers.keys.toList()) {
      if (key.toLowerCase() == 'host') {
        options.headers[key] = host;
      }
    }
  }
}
