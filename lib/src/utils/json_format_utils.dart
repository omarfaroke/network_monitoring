import 'dart:convert';

/// JSON formatting helpers for HTTP record display.
abstract final class JsonFormatUtils {
  JsonFormatUtils._();

  static const _encoder = JsonEncoder.withIndent('  ');

  static String encode(dynamic value) => _encoder.convert(value);

  static String formatBody(dynamic body) {
    if (body == null) return '';
    try {
      if (body is Map || body is List) return encode(body);
      return encode(jsonDecode(body.toString()));
    } catch (_) {
      return body.toString();
    }
  }

  static String formatMap(Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) return '';
    return encode(map);
  }
}
