import 'package:dio/dio.dart';

import 'config/network_monitoring_config.dart';
import 'controllers/network_monitor_controller.dart';
import 'interceptor/network_monitor_interceptor.dart';
import 'network_monitoring_registry.dart';

/// Singleton entry point for the package.
///
/// Call [initialize] once at startup, add [createInterceptor] to Dio **last** in
/// the interceptor list, then wire
/// [NetworkMonitorOverlayWrapper], [VersionTapDetector], and optionally
/// [NetworkMonitoringBuilder] in the host app.
class NetworkMonitoring {
  NetworkMonitoring._(this.config) {
    NetworkMonitoringRegistry.config = config;
    _controller = NetworkMonitorController();
  }

  static NetworkMonitoring? _instance;

  final NetworkMonitoringConfig config;
  late final NetworkMonitorController _controller;

  /// The singleton instance. Call [initialize] first.
  static NetworkMonitoring get instance {
    final instance = _instance;
    if (instance == null) {
      throw StateError(
        'NetworkMonitoring.initialize() must be called before accessing the instance.',
      );
    }
    return instance;
  }

  /// Whether the package has been initialized.
  static bool get isInitialized => _instance != null;

  /// Internal controller used by package widgets and the Dio interceptor.
  NetworkMonitorController get controller => _controller;

  /// Initialize the package with the given [config].
  static NetworkMonitoring initialize({
    NetworkMonitoringConfig config = const NetworkMonitoringConfig(),
  }) {
    _instance?.controller.dispose();
    _instance = NetworkMonitoring._(config);
    return _instance!;
  }

  /// Creates a Dio interceptor wired to the package controller.
  ///
  /// Add this **last** on [Dio.interceptors] so captured requests include
  /// headers and body applied by earlier interceptors (e.g. auth tokens).
  static Interceptor createInterceptor() {
    return NetworkMonitorInterceptor(instance.controller);
  }
}
