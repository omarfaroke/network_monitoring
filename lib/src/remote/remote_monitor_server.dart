import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../controllers/network_monitor_controller.dart';
import '../models/breakpoint_edit_result.dart';
import '../models/breakpoint_model.dart';
import '../models/http_record_model.dart';
import '../models/network_monitor_change.dart';
import '../models/network_search_scope.dart';
import 'remote_monitor_web.dart';

/// Result of starting [RemoteMonitorServer].
class RemoteMonitorStartResult {
  final int port;
  final String host;
  final String url;

  const RemoteMonitorStartResult({
    required this.port,
    required this.host,
    required this.url,
  });
}

/// Local HTTP server that serves the remote network monitor web UI and API.
class RemoteMonitorServer {
  HttpServer? _server;
  StreamSubscription<NetworkMonitorChange>? _changeSub;
  final Set<HttpResponse> _sseClients = {};
  NetworkMonitorController? _controller;
  int? _port;
  String? _host;

  bool get isRunning => _server != null;

  int? get port => _port;

  String? get host => _host;

  String? get url =>
      _port == null || _host == null ? null : 'http://$_host:$_port';

  /// Binds to [preferredPort] when free; otherwise tries the next ports.
  Future<RemoteMonitorStartResult> start({
    required NetworkMonitorController controller,
    int preferredPort = 7382,
    int maxPortAttempts = 21,
  }) async {
    if (_server != null) {
      return RemoteMonitorStartResult(port: _port!, host: _host!, url: url!);
    }

    _controller = controller;

    final bound = await _bindAvailablePort(
      preferredPort: preferredPort,
      maxAttempts: maxPortAttempts,
    );
    _server = bound.server;
    _port = bound.port;
    _host = await _resolveLanHost();

    _changeSub = controller.changes.listen((change) {
      if (change == NetworkMonitorChange.records ||
          change == NetworkMonitorChange.activeBreakpoints ||
          change == NetworkMonitorChange.globalPause ||
          change == NetworkMonitorChange.breakpoints) {
        _broadcastSse({'type': change.name});
      }
    });

    _server!.listen(_handleRequest);

    return RemoteMonitorStartResult(port: _port!, host: _host!, url: url!);
  }

  Future<void> stop() async {
    await _changeSub?.cancel();
    _changeSub = null;

    for (final client in _sseClients.toList()) {
      try {
        await client.close();
      } catch (_) {}
    }
    _sseClients.clear();

    await _server?.close(force: true);
    _server = null;
    _controller = null;
    _port = null;
    _host = null;
  }

  Future<({HttpServer server, int port})> _bindAvailablePort({
    required int preferredPort,
    required int maxAttempts,
  }) async {
    Object? lastError;
    for (var i = 0; i < maxAttempts; i++) {
      final port = preferredPort + i;
      try {
        final server = await HttpServer.bind(
          InternetAddress.anyIPv4,
          port,
          shared: true,
        );
        return (server: server, port: port);
      } catch (e) {
        lastError = e;
      }
    }
    throw StateError(
      'Could not bind remote monitor server near port $preferredPort '
      '(tried $maxAttempts ports). Last error: $lastError',
    );
  }

  Future<String> _resolveLanHost() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );
      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (!addr.isLoopback) return addr.address;
        }
      }
    } catch (_) {}
    return '127.0.0.1';
  }

  Future<void> _handleRequest(HttpRequest request) async {
    _addCors(request);

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.noContent;
      await request.response.close();
      return;
    }

    final path = request.uri.path;
    final controller = _controller;
    if (controller == null) {
      await _json(request, HttpStatus.serviceUnavailable, {
        'error': 'Remote monitor is not available',
      });
      return;
    }

    try {
      if (path == '/' || path == '/index.html') {
        await _text(request, RemoteMonitorWeb.indexHtml, ContentType.html);
        return;
      }
      if (path == '/app.css') {
        await _text(
          request,
          RemoteMonitorWeb.appCss,
          ContentType('text', 'css', charset: 'utf-8'),
        );
        return;
      }
      if (path == '/app.js') {
        await _text(
          request,
          RemoteMonitorWeb.appJs,
          ContentType('application', 'javascript', charset: 'utf-8'),
        );
        return;
      }
      if (path == '/api/records' && request.method == 'GET') {
        await _listRecords(request, controller);
        return;
      }
      if (path == '/api/records' && request.method == 'DELETE') {
        controller.clearRecords();
        await _json(request, HttpStatus.ok, {'ok': true});
        return;
      }
      if (path.startsWith('/api/records/') && request.method == 'GET') {
        final id = Uri.decodeComponent(path.substring('/api/records/'.length));
        HttpRecordModel? record;
        for (final r in controller.records) {
          if (r.id == id) {
            record = r;
            break;
          }
        }
        if (record == null) {
          await _json(request, HttpStatus.notFound, {'error': 'Not found'});
          return;
        }
        await _json(
          request,
          HttpStatus.ok,
          _detailRecordJson(record, controller),
        );
        return;
      }
      if (path.startsWith('/api/records/') && request.method == 'DELETE') {
        final id = Uri.decodeComponent(path.substring('/api/records/'.length));
        controller.removeRecord(id);
        await _json(request, HttpStatus.ok, {'ok': true});
        return;
      }
      if (path == '/api/events' && request.method == 'GET') {
        await _attachSse(request);
        return;
      }
      if (path == '/api/status' && request.method == 'GET') {
        await _json(request, HttpStatus.ok, {
          'ok': true,
          'recordCount': controller.records.length,
          'monitoringEnabled': controller.isMonitoringEnabled,
          'pausedGlobally': controller.isPausedGlobally,
          'url': url,
          ..._monitorState(controller),
        });
        return;
      }
      if (path == '/api/state' && request.method == 'GET') {
        await _json(request, HttpStatus.ok, _monitorState(controller));
        return;
      }
      if (path == '/api/pause' && request.method == 'POST') {
        final body = await _readJson(request);
        final paused = body['paused'];
        if (paused is bool) {
          if (controller.isPausedGlobally != paused) {
            controller.togglePausedGlobally();
          }
        } else {
          controller.togglePausedGlobally();
        }
        await _json(request, HttpStatus.ok, _monitorState(controller));
        return;
      }
      if (path == '/api/breakpoints' && request.method == 'GET') {
        await _json(request, HttpStatus.ok, {
          'breakpoints': _breakpointsJson(controller),
        });
        return;
      }
      if (path == '/api/breakpoints' && request.method == 'POST') {
        final body = await _readJson(request);
        controller.addBreakpoint(_breakpointFromJson(body));
        await _json(request, HttpStatus.ok, {
          'ok': true,
          'breakpoints': _breakpointsJson(controller),
        });
        return;
      }
      if (path == '/api/breakpoints/toggle-endpoint' &&
          request.method == 'POST') {
        final body = await _readJson(request);
        final endpointPath = body['path'] as String?;
        if (endpointPath == null || endpointPath.isEmpty) {
          await _json(request, HttpStatus.badRequest, {
            'error': 'path is required',
          });
          return;
        }
        controller.toggleBreakpointForEndpoint(endpointPath);
        await _json(request, HttpStatus.ok, {'ok': true});
        return;
      }
      final breakpointIndexMatch = RegExp(
        r'^/api/breakpoints/(\d+)$',
      ).firstMatch(path);
      if (breakpointIndexMatch != null) {
        final index = int.parse(breakpointIndexMatch.group(1)!);
        if (request.method == 'PATCH') {
          final body = await _readJson(request);
          final enabled = body['isEnabled'];
          if (enabled is bool) {
            controller.toggleBreakpoint(index, enabled);
          }
          await _json(request, HttpStatus.ok, {'ok': true});
          return;
        }
        if (request.method == 'DELETE') {
          controller.removeBreakpoint(index);
          await _json(request, HttpStatus.ok, {'ok': true});
          return;
        }
      }
      if (path == '/api/active-breakpoints/continue-all' &&
          request.method == 'POST') {
        controller.continueAllBreakpoints();
        await _json(request, HttpStatus.ok, {'ok': true});
        return;
      }
      final continueMatch = RegExp(
        r'^/api/active-breakpoints/([^/]+)/continue$',
      ).firstMatch(path);
      if (continueMatch != null && request.method == 'POST') {
        final id = Uri.decodeComponent(continueMatch.group(1)!);
        final body = await _readJson(request);
        controller.continueBreakpoint(id, result: _editResultFromJson(body));
        await _json(request, HttpStatus.ok, {'ok': true});
        return;
      }
      final cancelMatch = RegExp(
        r'^/api/active-breakpoints/([^/]+)/cancel$',
      ).firstMatch(path);
      if (cancelMatch != null && request.method == 'POST') {
        final id = Uri.decodeComponent(cancelMatch.group(1)!);
        controller.cancelBreakpoint(id);
        await _json(request, HttpStatus.ok, {'ok': true});
        return;
      }

      await _json(request, HttpStatus.notFound, {'error': 'Not found'});
    } catch (e) {
      await _json(request, HttpStatus.internalServerError, {
        'error': e.toString(),
      });
    }
  }

  Future<void> _listRecords(
    HttpRequest request,
    NetworkMonitorController controller,
  ) async {
    final params = request.uri.queryParameters;
    final query = params['q'];
    final method = params['method'];
    final scopesParam = params['scopes'];
    final scopes = _parseScopes(scopesParam);

    final filtered = controller.filterRecords(
      searchQuery: query,
      methodFilter: (method == null || method.isEmpty || method == 'ALL')
          ? null
          : method,
      searchScopes: scopes,
    );

    await _json(request, HttpStatus.ok, {
      'records': [
        for (final record in filtered) _listRecordJson(record, controller),
      ],
      'total': controller.records.length,
      'filtered': filtered.length,
      ..._monitorState(controller),
    });
  }

  Map<String, dynamic> _monitorState(NetworkMonitorController controller) {
    return {
      'pausedGlobally': controller.isPausedGlobally,
      'activeBreakpointCount': controller.activeBreakpointCount,
      'hasEnabledAllEndpointsBreakpoint':
          controller.hasEnabledAllEndpointsBreakpoint,
      'monitoringEnabled': controller.isMonitoringEnabled,
      'breakpoints': _breakpointsJson(controller),
    };
  }

  List<Map<String, dynamic>> _breakpointsJson(
    NetworkMonitorController controller,
  ) {
    return [
      for (var i = 0; i < controller.breakpoints.length; i++)
        {
          ...controller.breakpoints[i].toJson(index: i),
          'typeLabel': _breakpointTypeLabel(controller.breakpoints[i].type),
        },
    ];
  }

  String _breakpointTypeLabel(BreakpointType type) {
    return switch (type) {
      BreakpointType.all => 'Both Request & Response',
      BreakpointType.request => 'Request Only',
      BreakpointType.response => 'Response Only',
    };
  }

  Map<String, dynamic> _listRecordJson(
    HttpRecordModel record,
    NetworkMonitorController controller,
  ) {
    return {
      'id': record.id,
      'method': record.method,
      'url': record.url,
      'path': record.path,
      'status': record.status.name,
      'statusCode': record.statusCode,
      'formattedDuration': record.formattedDuration,
      ..._recordBreakpointFields(record, controller),
    };
  }

  Map<String, dynamic> _detailRecordJson(
    HttpRecordModel record,
    NetworkMonitorController controller,
  ) {
    return {...record.toJson(), ..._recordBreakpointFields(record, controller)};
  }

  Map<String, dynamic> _recordBreakpointFields(
    HttpRecordModel record,
    NetworkMonitorController controller,
  ) {
    final responseId = 'res_${record.id}';
    final pausedId = controller.hasActiveBreakpoint(record.id)
        ? record.id
        : (controller.hasActiveBreakpoint(responseId) ? responseId : null);
    return {
      'hasBreakpoint': controller.hasBreakpointForEndpoint(record.path),
      'isPaused': pausedId != null,
      'pausedBreakpointId': pausedId,
      'isResponseBreakpoint': pausedId != null && pausedId.startsWith('res_'),
    };
  }

  BreakpointModel _breakpointFromJson(Map<String, dynamic> body) {
    final target =
        _enumByName(BreakpointTarget.values, body['target']) ??
        BreakpointTarget.allEndpoints;
    final type =
        _enumByName(BreakpointType.values, body['type']) ?? BreakpointType.all;
    final pattern = body['endpointPattern'] as String?;
    return BreakpointModel(
      target: target,
      type: type,
      endpointPattern: target == BreakpointTarget.specificEndpoint
          ? pattern
          : null,
    );
  }

  BreakpointEditResult _editResultFromJson(Map<String, dynamic> body) {
    final headers = _asStringKeyedMap(body['editedHeaders']);
    final editedBody = body['editedBody'] as String?;
    if (headers == null && (editedBody == null || editedBody.isEmpty)) {
      return const BreakpointEditResult.continueUnmodified();
    }
    return BreakpointEditResult(
      action: BreakpointAction.continueRequest,
      editedHeaders: headers,
      editedBody: editedBody,
    );
  }

  Map<String, dynamic>? _asStringKeyedMap(dynamic value) {
    if (value is! Map) return null;
    return value.map((key, nested) => MapEntry(key.toString(), nested));
  }

  T? _enumByName<T extends Enum>(List<T> values, Object? name) {
    if (name is! String) return null;
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }

  Future<Map<String, dynamic>> _readJson(HttpRequest request) async {
    try {
      final raw = await utf8.decoder.bind(request).join();
      if (raw.trim().isEmpty) return <String, dynamic>{};
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return <String, dynamic>{};
  }

  Set<NetworkSearchScope> _parseScopes(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return {...NetworkSearchScopes.defaults};
    }
    final scopes = <NetworkSearchScope>{};
    for (final part in raw.split(',')) {
      final name = part.trim();
      for (final scope in NetworkSearchScope.values) {
        if (scope.name == name) scopes.add(scope);
      }
    }
    return scopes.isEmpty ? {...NetworkSearchScopes.defaults} : scopes;
  }

  Future<void> _attachSse(HttpRequest request) async {
    final response = request.response;
    request.response.bufferOutput = false;
    response.statusCode = HttpStatus.ok;
    response.headers
      ..set(HttpHeaders.contentTypeHeader, 'text/event-stream; charset=utf-8')
      ..set(HttpHeaders.cacheControlHeader, 'no-cache')
      ..set(HttpHeaders.connectionHeader, 'keep-alive')
      ..set('Access-Control-Allow-Origin', '*');

    _sseClients.add(response);
    response.write('data: ${jsonEncode({'type': 'connected'})}\n\n');
    await response.flush();

    // Keep the connection open until the client disconnects or server stops.
    final done = Completer<void>();
    request.response.done.then((_) {
      _sseClients.remove(response);
      if (!done.isCompleted) done.complete();
    });
    await done.future;
  }

  void _broadcastSse(Map<String, dynamic> event) {
    final payload = 'data: ${jsonEncode(event)}\n\n';
    for (final client in _sseClients.toList()) {
      try {
        client.write(payload);
        // ignore: discarded_futures
        client.flush();
      } catch (_) {
        _sseClients.remove(client);
      }
    }
  }

  void _addCors(HttpRequest request) {
    request.response.headers
      ..set('Access-Control-Allow-Origin', '*')
      ..set('Access-Control-Allow-Methods', 'GET, POST, PATCH, DELETE, OPTIONS')
      ..set('Access-Control-Allow-Headers', 'Content-Type');
  }

  Future<void> _json(HttpRequest request, int status, Object body) async {
    request.response
      ..statusCode = status
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(body));
    await request.response.close();
  }

  Future<void> _text(HttpRequest request, String body, ContentType type) async {
    request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = type
      ..write(body);
    await request.response.close();
  }
}
