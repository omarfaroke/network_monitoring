import 'dart:convert';

/// User choice when a breakpoint edit screen closes.
enum BreakpointAction { continueRequest, cancel }

/// Result returned from [BreakpointEditView] to the interceptor.
class BreakpointEditResult {  final BreakpointAction action;
  final Map<String, dynamic>? editedHeaders;
  final String? editedBody;

  const BreakpointEditResult({
    required this.action,
    this.editedHeaders,
    this.editedBody,
  });

  const BreakpointEditResult.continueUnmodified()
      : action = BreakpointAction.continueRequest,
        editedHeaders = null,
        editedBody = null;

  const BreakpointEditResult.cancel()
      : action = BreakpointAction.cancel,
        editedHeaders = null,
        editedBody = null;

  bool get isCancelled => action == BreakpointAction.cancel;
  bool get hasEdits => editedHeaders != null || editedBody != null;

  /// Parsed [editedBody] as JSON when valid; otherwise the raw string.
  dynamic get parsedBody {    if (editedBody == null || editedBody!.trim().isEmpty) return null;
    try {
      return jsonDecode(editedBody!);
    } catch (_) {
      return editedBody;
    }
  }
}
