import 'dart:convert';

/// User choice when a breakpoint edit screen closes.
enum BreakpointAction { continueRequest, cancel }

/// Result returned from [BreakpointEditView] to the interceptor.
class BreakpointEditResult {
  final BreakpointAction action;
  final Map<String, dynamic>? editedHeaders;
  final String? editedBody;
  final String? editedUrl;

  const BreakpointEditResult({
    required this.action,
    this.editedHeaders,
    this.editedBody,
    this.editedUrl,
  });

  const BreakpointEditResult.continueUnmodified()
    : action = BreakpointAction.continueRequest,
      editedHeaders = null,
      editedBody = null,
      editedUrl = null;

  const BreakpointEditResult.cancel()
    : action = BreakpointAction.cancel,
      editedHeaders = null,
      editedBody = null,
      editedUrl = null;

  bool get isCancelled => action == BreakpointAction.cancel;
  bool get hasEdits =>
      editedHeaders != null || editedBody != null || editedUrl != null;

  /// Header map with string (or string-list) values that Dio can apply.
  Map<String, dynamic>? get normalizedHeaders {
    if (editedHeaders == null) return null;
    return {
      for (final entry in editedHeaders!.entries)
        entry.key: _normalizedHeaderValue(entry.value),
    };
  }

  static dynamic _normalizedHeaderValue(dynamic value) {
    if (value == null) return '';
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return value.toString();
  }

  /// Parsed [editedBody] as JSON when valid; otherwise the raw string.
  dynamic get parsedBody {
    if (editedBody == null || editedBody!.trim().isEmpty) return null;
    try {
      return jsonDecode(editedBody!);
    } catch (_) {
      return editedBody;
    }
  }
}
