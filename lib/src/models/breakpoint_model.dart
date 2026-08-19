/// When a breakpoint pauses traffic: before request, on response, or both.
enum BreakpointType { all, request, response }

/// Whether a breakpoint applies to every URL or a specific pattern.
enum BreakpointTarget { allEndpoints, specificEndpoint }

/// A breakpoint rule that can pause matching HTTP traffic for editing.
class BreakpointModel {
  final String? endpointPattern;
  final BreakpointType type;
  final BreakpointTarget target;
  bool isEnabled;

  BreakpointModel({
    this.endpointPattern,
    this.type = BreakpointType.all,
    this.target = BreakpointTarget.allEndpoints,
    this.isEnabled = true,
  });

  /// Returns true when this rule should pause the given [url].
  bool matchesUrl(String url) {
    if (target == BreakpointTarget.allEndpoints) return true;
    if (endpointPattern == null || endpointPattern!.isEmpty) return false;
    return url.contains(endpointPattern!);
  }

  /// JSON representation for the remote monitor API / web UI.
  Map<String, dynamic> toJson({int? index}) {
    return {
      'index': ?index,
      'endpointPattern': endpointPattern,
      'type': type.name,
      'target': target.name,
      'isEnabled': isEnabled,
    };
  }
}
