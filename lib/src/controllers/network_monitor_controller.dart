import 'dart:async';

import 'package:flutter/material.dart';

import '../models/breakpoint_edit_result.dart';
import '../network_monitoring_registry.dart';
import '../widgets/dev_mode_password_dialog.dart';
import '../models/breakpoint_model.dart';
import '../models/http_record_model.dart';
import '../models/network_monitor_change.dart';

/// Central store for captured HTTP traffic, breakpoints, and dev-mode flags.
///
/// Emits [NetworkMonitorChange] events so listeners rebuild only relevant UI.
/// Host apps typically interact via [NetworkMonitoringBuilder] rather than
/// referencing this class directly.
class NetworkMonitorController {
  final _changeController = StreamController<NetworkMonitorChange>.broadcast();

  final List<HttpRecordModel> _records = [];
  final List<BreakpointModel> _breakpoints = [];
  bool _isMonitoringEnabled = false;
  bool _isDevModeEnabled = false;
  bool _isOverlayVisible = false;
  bool _isPausedGlobally = false;

  final Map<String, Completer<BreakpointEditResult>> _pendingBreakpoints = {};

  /// Emits the specific state domain that changed.
  Stream<NetworkMonitorChange> get changes => _changeController.stream;

  /// Emits only when one of [types] changes. Each event is mapped to void for
  /// convenient [StreamSubscription] usage in widgets.
  Stream<void> watchChanges(Set<NetworkMonitorChange> types) =>
      _changeController.stream.where(types.contains).map((_) {});

  /// Emits only when the dev mode state changes.
  Stream<bool> get devModeEnabledStream => _changeController.stream
      .where((change) => change == NetworkMonitorChange.devMode)
      .map((_) => isDevModeEnabled);

  /// Emits only when the monitoring state changes.
  Stream<bool> get monitoringEnabledStream => _changeController.stream
      .where((change) => change == NetworkMonitorChange.monitoring)
      .map((_) => isMonitoringEnabled);

  /// Captured HTTP requests, newest first.
  List<HttpRecordModel> get records => List.unmodifiable(_records);

  /// Configured breakpoint rules.
  List<BreakpointModel> get breakpoints => List.unmodifiable(_breakpoints);

  /// Whether the Dio interceptor is recording traffic.
  bool get isMonitoringEnabled => _isMonitoringEnabled;

  /// Whether dev mode has been unlocked.
  bool get isDevModeEnabled => _isDevModeEnabled;

  /// Whether the floating monitor button is visible.
  bool get isOverlayVisible => _isOverlayVisible;

  /// When `true`, every request/response is held until resumed.
  bool get isPausedGlobally => _isPausedGlobally;

  /// Whether an enabled breakpoint targets all endpoints.
  bool get hasEnabledAllEndpointsBreakpoint => _breakpoints.any(
    (bp) => bp.isEnabled && bp.target == BreakpointTarget.allEndpoints,
  );

  void _notify(NetworkMonitorChange change) {
    if (!_changeController.isClosed) {
      _changeController.add(change);
    }
  }

  void _notifyAll(Set<NetworkMonitorChange> changes) {
    if (_changeController.isClosed) return;
    for (final change in changes) {
      _changeController.add(change);
    }
  }

  /// Releases the change [StreamController]. Invoked when re-initializing the package.
  void dispose() {
    _changeController.close();
  }

  /// Enables dev mode without prompting. Prefer [requestEnableDevMode] when a
  /// password may be required.
  void enableDevMode() {
    if (!NetworkMonitoringRegistry.config.enabled) return;
    _isDevModeEnabled = true;
    _notify(NetworkMonitorChange.devMode);
  }

  /// Enables dev mode, showing [DevModePasswordDialog] when configured.
  ///
  /// Returns `true` if dev mode was enabled, `false` if already enabled, the
  /// user cancelled, or validation failed.
  Future<bool> requestEnableDevMode(BuildContext context) async {
    if (!NetworkMonitoringRegistry.config.enabled) return false;
    if (_isDevModeEnabled) return false;

    if (NetworkMonitoringRegistry.config.isPasswordRequired) {
      final granted = await DevModePasswordDialog.show(context);
      if (!granted) return false;
    }

    enableDevMode();
    return true;
  }

  /// Turns off dev mode and resets monitoring and overlay visibility.
  void disableDevMode() {
    _isDevModeEnabled = false;
    _isMonitoringEnabled = false;
    _isOverlayVisible = false;
    _notifyAll(NetworkMonitorChanges.devModeOptions);
  }

  /// Starts or stops HTTP capture. When `true`, also shows the overlay.
  void toggleMonitoring(bool value) {
    if (!NetworkMonitoringRegistry.config.enabled) return;
    _isMonitoringEnabled = value;
    _isOverlayVisible = value;
    _notifyAll({NetworkMonitorChange.monitoring, NetworkMonitorChange.overlay});
  }

  /// Shows or hides the floating button without changing monitoring state.
  void setOverlayVisible(bool value) {
    if (!NetworkMonitoringRegistry.config.enabled) return;
    if (_isOverlayVisible == value) return;
    _isOverlayVisible = value;
    _notify(NetworkMonitorChange.overlay);
  }

  /// Toggles global pause so all traffic waits at breakpoints.
  void togglePausedGlobally() {
    _isPausedGlobally = !_isPausedGlobally;
    _notify(NetworkMonitorChange.globalPause);
  }

  /// Inserts a new record at the top of [records].
  void addRecord(HttpRecordModel record) {
    _records.insert(0, record);
    _notify(NetworkMonitorChange.records);
  }

  /// Replaces the record with [id], if it exists.
  void updateRecord(String id, HttpRecordModel updatedRecord) {
    final index = _records.indexWhere((r) => r.id == id);
    if (index != -1) {
      _records[index] = updatedRecord;
      _notify(NetworkMonitorChange.records);
    }
  }

  /// Removes all captured records.
  void clearRecords() {
    if (_records.isEmpty) return;
    _records.clear();
    _notify(NetworkMonitorChange.records);
  }

  /// Removes a single record by [id].
  void removeRecord(String id) {
    final before = _records.length;
    _records.removeWhere((r) => r.id == id);
    if (_records.length != before) {
      _notify(NetworkMonitorChange.records);
    }
  }

  /// Appends a breakpoint rule.
  void addBreakpoint(BreakpointModel breakpoint) {
    _breakpoints.add(breakpoint);
    _notify(NetworkMonitorChange.breakpoints);
  }

  /// Whether a specific-endpoint breakpoint exists for [path].
  bool hasBreakpointForEndpoint(String path) {
    return _breakpoints.any(
      (bp) =>
          bp.target == BreakpointTarget.specificEndpoint &&
          bp.endpointPattern == path,
    );
  }

  /// Adds or removes a specific-endpoint breakpoint for [path].
  void toggleBreakpointForEndpoint(String path) {
    final index = _breakpoints.indexWhere(
      (bp) =>
          bp.target == BreakpointTarget.specificEndpoint &&
          bp.endpointPattern == path,
    );
    if (index != -1) {
      removeBreakpoint(index);
      return;
    }
    addBreakpoint(
      BreakpointModel(
        target: BreakpointTarget.specificEndpoint,
        endpointPattern: path,
      ),
    );
  }

  /// Removes the breakpoint at [index] in [breakpoints].
  void removeBreakpoint(int index) {
    if (index >= 0 && index < _breakpoints.length) {
      _breakpoints.removeAt(index);
      _notify(NetworkMonitorChange.breakpoints);
    }
  }

  /// Enables or disables the breakpoint at [index].
  void toggleBreakpoint(int index, bool value) {
    if (index >= 0 &&
        index < _breakpoints.length &&
        _breakpoints[index].isEnabled != value) {
      _breakpoints[index].isEnabled = value;
      _notify(NetworkMonitorChange.breakpoints);
    }
  }

  /// Whether outgoing traffic to [url] should pause before the request is sent.
  bool shouldBreakOnRequest(String url) {
    if (_isPausedGlobally) return true;
    for (final bp in _breakpoints) {
      if (!bp.isEnabled) continue;
      if (bp.type == BreakpointType.all || bp.type == BreakpointType.request) {
        if (bp.matchesUrl(url)) return true;
      }
    }
    return false;
  }

  /// Whether the response for [url] should pause before it is delivered.
  bool shouldBreakOnResponse(String url) {
    if (_isPausedGlobally) return true;
    for (final bp in _breakpoints) {
      if (!bp.isEnabled) continue;
      if (bp.type == BreakpointType.all || bp.type == BreakpointType.response) {
        if (bp.matchesUrl(url)) return true;
      }
    }
    return false;
  }

  /// Pauses the interceptor until [continueBreakpoint] or [cancelBreakpoint].
  ///
  /// [requestId] is the HTTP record id, or `res_<id>` for response breakpoints.
  Future<BreakpointEditResult> waitForBreakpoint(String requestId) {
    final completer = Completer<BreakpointEditResult>();
    _pendingBreakpoints[requestId] = completer;
    _notify(NetworkMonitorChange.activeBreakpoints);
    return completer.future;
  }

  /// Resumes a paused request with optional header/body edits.
  void continueBreakpoint(String requestId, {BreakpointEditResult? result}) {
    final editResult =
        result ?? const BreakpointEditResult.continueUnmodified();
    _pendingBreakpoints[requestId]?.complete(editResult);
    _pendingBreakpoints.remove(requestId);
    _notify(NetworkMonitorChange.activeBreakpoints);
  }

  /// Cancels a paused request (rejects the Dio call when on request).
  void cancelBreakpoint(String requestId) {
    _pendingBreakpoints[requestId]?.complete(
      const BreakpointEditResult.cancel(),
    );
    _pendingBreakpoints.remove(requestId);
    _notify(NetworkMonitorChange.activeBreakpoints);
  }

  /// Resumes every request currently waiting at a breakpoint.
  void continueAllBreakpoints() {
    if (_pendingBreakpoints.isEmpty) return;
    for (final entry in _pendingBreakpoints.entries) {
      entry.value.complete(const BreakpointEditResult.continueUnmodified());
    }
    _pendingBreakpoints.clear();
    _notify(NetworkMonitorChange.activeBreakpoints);
  }

  /// Whether [requestId] is currently paused.
  bool hasActiveBreakpoint(String requestId) {
    return _pendingBreakpoints.containsKey(requestId);
  }

  /// Number of requests waiting at a breakpoint.
  int get activeBreakpointCount => _pendingBreakpoints.length;

  /// The [HttpRecordModel] associated with a paused [breakpointId].
  HttpRecordModel? getPausedRecord(String breakpointId) {
    final recordId = breakpointId.startsWith('res_')
        ? breakpointId.substring(4)
        : breakpointId;
    final index = _records.indexWhere((r) => r.id == recordId);
    if (index != -1) return _records[index];
    return null;
  }

  /// Whether [breakpointId] refers to a response breakpoint (`res_` prefix).
  bool isResponseBreakpoint(String breakpointId) {
    return breakpointId.startsWith('res_');
  }

  /// Returns [records] matching optional search, method, and status filters.
  List<HttpRecordModel> filterRecords({
    String? searchQuery,
    String? methodFilter,
    int? statusCodeFilter,
  }) {
    return _records.where((record) {
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchesUrl = record.url.toLowerCase().contains(query);
        final matchesPath = record.path.toLowerCase().contains(query);
        final matchesStatus =
            record.statusCode?.toString().contains(query) ?? false;
        if (!matchesUrl && !matchesPath && !matchesStatus) return false;
      }
      if (methodFilter != null && methodFilter.isNotEmpty) {
        if (record.method.toUpperCase() != methodFilter.toUpperCase()) {
          return false;
        }
      }
      if (statusCodeFilter != null) {
        if (record.statusCode != statusCodeFilter) return false;
      }
      return true;
    }).toList();
  }
}
