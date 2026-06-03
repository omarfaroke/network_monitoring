import 'dart:convert';

import 'json_format_utils.dart';

/// UTF-8 byte sizes for captured HTTP headers and bodies.
abstract final class HttpPayloadSizeUtils {
  HttpPayloadSizeUtils._();

  static int utf8ByteLength(String text) => utf8.encode(text).length;

  static int headersByteSize(Map<String, dynamic> headers) {
    if (headers.isEmpty) return 0;
    return utf8ByteLength(JsonFormatUtils.encode(headers));
  }

  static int headersByteSizeNullable(Map<String, dynamic>? headers) {
    if (headers == null || headers.isEmpty) return 0;
    return headersByteSize(headers);
  }

  static int bodyByteSize(dynamic body) {
    if (body == null) return 0;
    final formatted = JsonFormatUtils.formatBody(body);
    if (formatted.isEmpty) return 0;
    return utf8ByteLength(formatted);
  }
}
