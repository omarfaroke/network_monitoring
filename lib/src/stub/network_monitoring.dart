import 'package:dio/dio.dart';

import 'network_monitor_controller.dart';
import 'network_monitoring_config.dart';

/// No-op singleton matching the full [NetworkMonitoring] API.
class NetworkMonitoring {
  NetworkMonitoring._(this.config) : controller = NetworkMonitorController();

  static NetworkMonitoring? _instance;

  final NetworkMonitoringConfig config;
  final NetworkMonitorController controller;

  /// The singleton instance. Call [initialize] first.
  static NetworkMonitoring get instance {
    final current = _instance;
    if (current == null) {
      throw StateError(
        'NetworkMonitoring.initialize() must be called before accessing '
        'the instance.',
      );
    }
    return current;
  }

  /// Whether the package has been initialized.
  static bool get isInitialized => _instance != null;

  /// Initializes the stub singleton (no monitoring side effects).
  static NetworkMonitoring initialize({
    required NetworkMonitoringConfig config,
  }) {
    _instance = NetworkMonitoring._(config);
    return _instance!;
  }

  /// Returns a no-op Dio interceptor.
  ///
  /// Hosts that import the stub typically skip adding this interceptor.
  static Interceptor createInterceptor() => _NoOpInterceptor();
}

class _NoOpInterceptor extends Interceptor {}
