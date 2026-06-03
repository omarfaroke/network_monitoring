import '../utils/auth_token_utils.dart';
import '../utils/byte_size_utils.dart';
import '../utils/http_payload_size_utils.dart';
import '../utils/jwt_decoder.dart';
import '../utils/json_format_utils.dart';

/// Lifecycle status of a captured HTTP call.
enum HttpRecordStatus { pending, success, error, cancelled }

/// A single captured HTTP request/response pair shown in the monitor list.
class HttpRecordModel {
  final String id;
  final DateTime startTime;
  DateTime? endTime;
  final String method;
  final String url;
  final String baseUrl;
  final String path;
  Map<String, dynamic> requestHeaders;
  final Map<String, dynamic>? queryParameters;
  dynamic requestBody;
  Map<String, dynamic>? responseHeaders;
  dynamic responseBody;
  int? statusCode;
  String? statusMessage;
  HttpRecordStatus status;
  String? errorMessage;
  Duration? duration;

  JwtDecodeResult? _jwtDecodeCache;

  HttpRecordModel({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.method,
    required this.url,
    required this.baseUrl,
    required this.path,
    required this.requestHeaders,
    this.queryParameters,
    this.requestBody,
    this.responseHeaders,
    this.responseBody,
    this.statusCode,
    this.statusMessage,
    this.status = HttpRecordStatus.pending,
    this.errorMessage,
    this.duration,
  });

  String get formattedDuration {
    if (duration == null) return '-';
    if (duration!.inMilliseconds < 1000) {
      return '${duration!.inMilliseconds}ms';
    }
    return '${(duration!.inMilliseconds / 1000).toStringAsFixed(2)}s';
  }

  int get requestHeadersByteSize =>
      HttpPayloadSizeUtils.headersByteSize(requestHeaders);

  int get requestBodyByteSize =>
      HttpPayloadSizeUtils.bodyByteSize(requestBody);

  int get responseHeadersByteSize =>
      HttpPayloadSizeUtils.headersByteSizeNullable(responseHeaders);

  int get responseBodyByteSize =>
      HttpPayloadSizeUtils.bodyByteSize(responseBody);

  int get requestPayloadByteSize =>
      requestHeadersByteSize + requestBodyByteSize;

  int get responsePayloadByteSize =>
      responseHeadersByteSize + responseBodyByteSize;

  String get formattedRequestHeadersSize =>
      ByteSizeUtils.format(requestHeadersByteSize);

  String get formattedRequestBodySize =>
      ByteSizeUtils.format(requestBodyByteSize);

  String get formattedResponseHeadersSize =>
      ByteSizeUtils.format(responseHeadersByteSize);

  String get formattedResponseBodySize =>
      ByteSizeUtils.format(responseBodyByteSize);

  String get formattedRequestPayloadSize =>
      ByteSizeUtils.format(requestPayloadByteSize);

  String get formattedResponsePayloadSize =>
      ByteSizeUtils.format(responsePayloadByteSize);

  String get requestBodyFormatted => JsonFormatUtils.formatBody(requestBody);

  String get responseBodyFormatted => JsonFormatUtils.formatBody(responseBody);

  String get queryParametersFormatted =>
      JsonFormatUtils.formatMap(queryParameters);

  String get requestHeadersFormatted =>
      JsonFormatUtils.encode(requestHeaders);

  String get responseHeadersFormatted =>
      JsonFormatUtils.formatMap(responseHeaders);

  /// Raw value from `Authorization`, `authorization`, or `x-auth-token`.
  String? get authToken => AuthTokenUtils.fromHeaders(requestHeaders);

  /// Cached JWT decode attempt for [authToken].
  JwtDecodeResult get authTokenJwtDecode =>
      _jwtDecodeCache ??= JwtDecoder.decodeFromAuthHeader(authToken);

  /// Decoded JWT when [authTokenJwtDecode] succeeded.
  JwtDecodedToken? get decodedAuthToken =>
      authTokenJwtDecode.isSuccess ? authTokenJwtDecode.token : null;

  bool get hasDecodedAuthToken => authTokenJwtDecode.isSuccess;

  bool get isSuccess =>
      statusCode != null && statusCode! >= 200 && statusCode! < 300;

  bool get isError =>
      status == HttpRecordStatus.error ||
      (statusCode != null && statusCode! >= 400);
}
