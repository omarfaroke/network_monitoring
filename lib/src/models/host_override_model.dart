import 'breakpoint_model.dart';

/// Rewrites the host (and optional scheme/port) of matching outgoing requests.
class HostOverrideModel {
  /// Original host to match. Empty means any host.
  ///
  /// Accepts `api.example.com`, `api.example.com:8080`, or a full origin like
  /// `https://api.example.com`.
  final String fromHost;

  /// Replacement host / origin, e.g. `staging.example.com` or
  /// `http://192.168.1.10:8080`.
  final String toHost;

  final BreakpointTarget target;
  final String? urlPattern;
  bool isEnabled;

  HostOverrideModel({
    required this.fromHost,
    required this.toHost,
    this.target = BreakpointTarget.allEndpoints,
    this.urlPattern,
    this.isEnabled = true,
  });

  /// When this rule matches [uri], returns the rewritten URI; otherwise `null`.
  Uri? tryRewrite(Uri uri) {
    if (!isEnabled) return null;
    if (!_matches(uri)) return null;
    return _rewrite(uri);
  }

  bool _matches(Uri uri) {
    final from = _parseEndpoint(fromHost);
    if (from != null) {
      if (from.host.toLowerCase() != uri.host.toLowerCase()) return false;
      if (from.port != null && from.port != uri.port) return false;
    }
    if (target == BreakpointTarget.specificEndpoint) {
      final pattern = urlPattern?.trim() ?? '';
      if (pattern.isEmpty) return false;
      return uri.toString().contains(pattern);
    }
    return true;
  }

  Uri _rewrite(Uri uri) {
    final to = _parseEndpoint(toHost);
    if (to == null) return uri;

    final scheme = to.scheme ?? uri.scheme;
    // Always apply the replacement origin. An omitted port uses the scheme
    // default instead of keeping the original host's port.
    return Uri(
      scheme: scheme,
      userInfo: uri.userInfo,
      host: to.host,
      port: to.port,
      path: uri.path,
      query: uri.hasQuery ? uri.query : null,
      fragment: uri.hasFragment ? uri.fragment : null,
    );
  }

  Map<String, dynamic> toJson({int? index}) {
    return {
      'index': ?index,
      'fromHost': fromHost,
      'toHost': toHost,
      'target': target.name,
      'urlPattern': urlPattern,
      'isEnabled': isEnabled,
    };
  }

  /// Parses `host`, `host:port`, or `scheme://host[:port]`.
  static _Endpoint? _parseEndpoint(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;

    if (value.contains('://')) {
      final uri = Uri.tryParse(value);
      if (uri == null || uri.host.isEmpty) return null;
      return _Endpoint(
        scheme: uri.scheme.isEmpty ? null : uri.scheme,
        host: uri.host,
        port: uri.hasPort ? uri.port : null,
      );
    }

    if (value.startsWith('[')) {
      final close = value.indexOf(']');
      if (close <= 1) return null;
      final host = value.substring(1, close);
      int? port;
      if (close + 1 < value.length && value[close + 1] == ':') {
        port = int.tryParse(value.substring(close + 2));
      }
      return _Endpoint(host: host, port: port);
    }

    final colon = value.lastIndexOf(':');
    if (colon > 0) {
      final port = int.tryParse(value.substring(colon + 1));
      if (port != null) {
        return _Endpoint(host: value.substring(0, colon), port: port);
      }
    }
    return _Endpoint(host: value);
  }
}

class _Endpoint {
  final String? scheme;
  final String host;
  final int? port;

  const _Endpoint({this.scheme, required this.host, this.port});
}
