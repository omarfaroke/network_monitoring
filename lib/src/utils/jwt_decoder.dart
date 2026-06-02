import 'dart:convert';

/// Result of attempting to decode an auth token as JWT.
enum JwtDecodeStatus {
  /// Header and payload were decoded successfully.
  success,

  /// Value is not in JWT format (not Bearer + 3 parts).
  notJwt,

  /// Value looks like JWT but header/payload could not be parsed.
  decodeFailed,
}

/// Outcome of [JwtDecoder.decodeFromAuthHeader].
class JwtDecodeResult {
  final JwtDecodeStatus status;
  final JwtDecodedToken? token;

  const JwtDecodeResult({
    required this.status,
    this.token,
  });

  bool get isSuccess => status == JwtDecodeStatus.success && token?.isValid == true;
}

/// Decoded JWT header and payload for display in the network monitor.
class JwtDecodedToken {
  final String rawToken;
  final Map<String, dynamic>? header;
  final Map<String, dynamic>? payload;

  const JwtDecodedToken({
    required this.rawToken,
    required this.header,
    required this.payload,
  });

  bool get isValid => header != null && payload != null;

  String get headerFormatted => _formatJson(header);

  String get payloadFormatted => _formatJson(payload);

  DateTime? get expiresAt => _readTimestamp(payload?['exp']);

  DateTime? get issuedAt => _readTimestamp(payload?['iat']);

  static String _formatJson(Map<String, dynamic>? value) {
    if (value == null) return '';
    return const JsonEncoder.withIndent('  ').convert(value);
  }

  static DateTime? _readTimestamp(dynamic value) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value * 1000, isUtc: true)
          .toLocal();
    }
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) {
        return DateTime.fromMillisecondsSinceEpoch(parsed * 1000, isUtc: true)
            .toLocal();
      }
    }
    return null;
  }
}

/// Decodes JWT bearer tokens without verifying signatures.
abstract final class JwtDecoder {
  JwtDecoder._();

  static JwtDecodeResult decodeFromAuthHeader(String? authHeader) {
    if (authHeader == null || authHeader.trim().isEmpty) {
      return const JwtDecodeResult(status: JwtDecodeStatus.notJwt);
    }

    final token = extractToken(authHeader);
    if (token == null) {
      return const JwtDecodeResult(status: JwtDecodeStatus.notJwt);
    }

    final decoded = tryDecode(token);
    if (decoded == null || !decoded.isValid) {
      return JwtDecodeResult(
        status: JwtDecodeStatus.decodeFailed,
        token: decoded,
      );
    }

    return JwtDecodeResult(status: JwtDecodeStatus.success, token: decoded);
  }

  static JwtDecodedToken? tryDecodeFromAuthHeader(String? authHeader) {
    final result = decodeFromAuthHeader(authHeader);
    return result.isSuccess ? result.token : null;
  }

  static String? extractToken(String? authHeader) {
    if (authHeader == null) return null;

    final trimmed = authHeader.trim();
    if (trimmed.isEmpty) return null;

    final bearerPrefix = RegExp(r'^Bearer\s+', caseSensitive: false);
    if (bearerPrefix.hasMatch(trimmed)) {
      final token = trimmed.replaceFirst(bearerPrefix, '').trim();
      return _looksLikeJwt(token) ? token : null;
    }

    return _looksLikeJwt(trimmed) ? trimmed : null;
  }

  static JwtDecodedToken? tryDecode(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;

    final header = _decodePart(parts[0]);
    final payload = _decodePart(parts[1]);
    if (header == null && payload == null) return null;

    return JwtDecodedToken(
      rawToken: token,
      header: header,
      payload: payload,
    );
  }

  static bool _looksLikeJwt(String value) {
    final parts = value.split('.');
    return parts.length == 3 && parts.every((part) => part.isNotEmpty);
  }

  static Map<String, dynamic>? _decodePart(String part) {
    try {
      final normalized = base64Url.normalize(part);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(decoded);
      if (json is Map<String, dynamic>) return json;
      if (json is Map) return Map<String, dynamic>.from(json);
    } catch (_) {}
    return null;
  }
}
