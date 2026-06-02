import 'package:flutter/material.dart';

import 'config/network_monitoring_config.dart';

/// Internal holder for the active [NetworkMonitoringConfig].
class NetworkMonitoringRegistry {
  NetworkMonitoringRegistry._();

  static NetworkMonitoringConfig config = const NetworkMonitoringConfig();

  /// Whether [NetworkMonitoringLocalizations.delegate] is registered in the host app.
  static bool isLocalizationDelegateRegistered = false;

  static Locale currentLocale = const Locale('en');
}