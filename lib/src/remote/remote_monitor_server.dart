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
  Timer? _heartbeat;
  Timer? _liveDebounce;
  final Set<HttpResponse> _sseClients = {};
  final Set<WebSocket> _wsClients = {};
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
        _scheduleLiveBroadcast();
      }
    });

    _heartbeat = Timer.periodic(const Duration(seconds: 15), (_) {
      _broadcastLive({'type': 'ping'});
    });

    _server!.listen(
      (request) {
        unawaited(_handleRequest(request));
      },
      onError: (_) {},
      cancelOnError: false,
    );

    return RemoteMonitorStartResult(port: _port!, host: _host!, url: url!);
  }

  Future<void> stop() async {
    await _changeSub?.cancel();
    _changeSub = null;
    _heartbeat?.cancel();
    _heartbeat = null;
    _liveDebounce?.cancel();
    _liveDebounce = null;

    for (final socket in _wsClients.toList()) {
      try {
        await socket.close();
      } catch (_) {}
    }
    _wsClients.clear();

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
    try {
      await _handleRequestInner(request);
    } catch (_) {}
  }

  Future<void> _handleRequestInner(HttpRequest request) async {
    final path = request.uri.path;
    if (path == '/ws') {
      await _attachWebSocket(request);
      return;
    }

    _addCors(request);

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.noContent;
      await request.response.close();
      return;
    }

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
      if (path == '/api/active-breakpoints/continue' &&
          request.method == 'POST') {
        final body = await _readJson(request);
        final id = body['id'] as String?;
        if (id == null || id.isEmpty) {
          await _json(request, HttpStatus.badRequest, {
            'error': 'id is required',
          });
          return;
        }
        if (!controller.hasActiveBreakpoint(id)) {
          await _json(request, HttpStatus.notFound, {
            'error': 'No paused request for this id',
          });
          return;
        }
        controller.continueBreakpoint(id, result: _editResultFromJson(body));
        await _json(request, HttpStatus.ok, {'ok': true});
        return;
      }
      if (path == '/api/active-breakpoints/cancel' &&
          request.method == 'POST') {
        final body = await _readJson(request);
        final id = body['id'] as String?;
        if (id == null || id.isEmpty) {
          await _json(request, HttpStatus.badRequest, {
            'error': 'id is required',
          });
          return;
        }
        if (!controller.hasActiveBreakpoint(id)) {
          await _json(request, HttpStatus.notFound, {
            'error': 'No paused request for this id',
          });
          return;
        }
        controller.cancelBreakpoint(id);
        await _json(request, HttpStatus.ok, {'ok': true});
        return;
      }
      final continueMatch = RegExp(
        r'^/api/active-breakpoints/([^/]+)/continue$',
      ).firstMatch(path);
      if (continueMatch != null && request.method == 'POST') {
        final id = Uri.decodeComponent(continueMatch.group(1)!);
        if (!controller.hasActiveBreakpoint(id)) {
          await _json(request, HttpStatus.notFound, {
            'error': 'No paused request for this id',
          });
          return;
        }
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
        if (!controller.hasActiveBreakpoint(id)) {
          await _json(request, HttpStatus.notFound, {
            'error': 'No paused request for this id',
          });
          return;
        }
        controller.cancelBreakpoint(id);
        await _json(request, HttpStatus.ok, {'ok': true});
        return;
      }

      await _json(request, HttpStatus.notFound, {'error': 'Not found'});
    } catch (e) {
      try {
        await _json(request, HttpStatus.internalServerError, {
          'error': e.toString(),
        });
      } catch (_) {}
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
      'activeBreakpointIds': controller.activeBreakpointIds,
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
    Map<String, dynamic>? headers;
    if (body.containsKey('editedHeaders')) {
      headers = _normalizeHeaderMap(_asStringKeyedMap(body['editedHeaders']));
    }

    String? editedBody;
    if (body.containsKey('editedBody')) {
      final raw = body['editedBody'];
      if (raw == null) {
        editedBody = '';
      } else if (raw is String) {
        editedBody = raw;
      } else {
        editedBody = jsonEncode(raw);
      }
    }

    if (headers == null && editedBody == null) {
      return const BreakpointEditResult.continueUnmodified();
    }
    return BreakpointEditResult(
      action: BreakpointAction.continueRequest,
      editedHeaders: headers,
      editedBody: editedBody,
    );
  }

  Map<String, dynamic>? _normalizeHeaderMap(Map<String, dynamic>? headers) {
    if (headers == null) return null;
    return {
      for (final entry in headers.entries)
        entry.key: entry.value is List
            ? (entry.value as List).map((item) => item.toString()).toList()
            : (entry.value?.toString() ?? ''),
    };
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
      ..set(
        HttpHeaders.cacheControlHeader,
        'no-cache, no-store, must-revalidate',
      )
      ..set(HttpHeaders.connectionHeader, 'keep-alive')
      ..set('Access-Control-Allow-Origin', '*')
      ..set('X-Accel-Buffering', 'no');

    _sseClients.add(response);
    final controller = _controller;
    final hello = controller == null
        ? {'type': 'connected'}
        : _liveSnapshot('connected', controller);
    response.write('data: ${jsonEncode(hello)}\n\n');
    await response.flush();

    // Keep the connection open until the client disconnects or server stops.
    final done = Completer<void>();
    request.response.done.then((_) {
      _sseClients.remove(response);
      if (!done.isCompleted) done.complete();
    });
    await done.future;
  }

  Future<void> _attachWebSocket(HttpRequest request) async {
    WebSocket socket;
    try {
      socket = await WebSocketTransformer.upgrade(request);
    } catch (_) {
      return;
    }

    _wsClients.add(socket);
    final controller = _controller;
    if (controller != null) {
      try {
        socket.add(jsonEncode(_liveSnapshot('connected', controller)));
      } catch (_) {
        _dropWs(socket);
        return;
      }
    }

    socket.listen(
      (_) {},
      onDone: () => _wsClients.remove(socket),
      onError: (_) {
        _wsClients.remove(socket);
        try {
          socket.close();
        } catch (_) {}
      },
      cancelOnError: false,
    );
  }

  void _scheduleLiveBroadcast() {
    _liveDebounce?.cancel();
    // Event-queue timer (not a microtask) so Continue HTTP can finish
    // before we snapshot, and so WebSocket writes are never nested in
    // the interceptor / request handler.
    _liveDebounce = Timer(Duration.zero, () {
      _liveDebounce = null;
      final controller = _controller;
      if (controller == null) return;
      try {
        _broadcastLive(_liveSnapshot('records', controller));
      } catch (_) {}
    });
  }

  Map<String, dynamic> _liveSnapshot(
    String type,
    NetworkMonitorController controller,
  ) {
    final records = List<HttpRecordModel>.of(controller.records);
    return {
      'type': type,
      ..._monitorState(controller),
      'records': [
        for (final record in records) _listRecordJson(record, controller),
      ],
      'total': records.length,
      'filtered': records.length,
    };
  }

  void _dropWs(WebSocket socket) {
    _wsClients.remove(socket);
    try {
      socket.close();
    } catch (_) {}
  }

  void _broadcastLive(Map<String, dynamic> event) {
    String json;
    try {
      json = jsonEncode(event);
    } catch (_) {
      return;
    }
    final ssePayload = 'data: $json\n\n';

    for (final client in _sseClients.toList()) {
      try {
        client.write(ssePayload);
        // ignore: discarded_futures
        client.flush();
      } catch (_) {
        _sseClients.remove(client);
      }
    }

    for (final socket in _wsClients.toList()) {
      if (socket.readyState != WebSocket.open) {
        _dropWs(socket);
        continue;
      }
      try {
        socket.add(json);
      } catch (_) {
        _dropWs(socket);
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
    String encoded;
    try {
      encoded = jsonEncode(body);
    } catch (e) {
      status = HttpStatus.internalServerError;
      encoded = jsonEncode({'error': e.toString()});
    }
    request.response
      ..statusCode = status
      ..headers.contentType = ContentType.json
      ..headers.set(HttpHeaders.cacheControlHeader, 'no-store')
      ..write(encoded);
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
