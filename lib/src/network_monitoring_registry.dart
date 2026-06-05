import 'package:flutter/material.dart';

import 'config/network_monitoring_config.dart';

/// Internal holder for the active [NetworkMonitoringConfig].
class NetworkMonitoringRegistry {
  NetworkMonitoringRegistry._();

  static NetworkMonitoringConfig? _config;

  static NetworkMonitoringConfig get config {
    final config = _config;
    if (config == null) {
      throw StateError(
        'NetworkMonitoring.initialize() must be called before accessing config.',
      );
    }
    return config;
  }

  static set config(NetworkMonitoringConfig value) => _config = value;

  /// Whether [NetworkMonitoringLocalizations.delegate] is registered in the host app.
  static bool isLocalizationDelegateRegistered = false;

  static Locale currentLocale = const Locale('en');
}