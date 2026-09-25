import 'dart:async';

import 'package:flutter/material.dart';

/// Validates user input from the dev mode password dialog.
typedef DevModePasswordValidator = FutureOr<bool> Function(String password);

/// Host-provided handler for sharing text from the monitoring UI.
typedef ShareContent = void Function(BuildContext context, String content);

/// Host-provided handler for opening a URL.
typedef OpenUrl = FutureOr<void> Function(String url);

/// Stub configuration matching the full [NetworkMonitoringConfig] API.
class NetworkMonitoringConfig {
  /// Compile-time flag hosts may pass as [enabled].
  ///
  /// This only controls runtime behavior when using the full library.
  /// To exclude monitoring code from a binary, import `stub.dart` instead.
  static const bool enableFromEnvironment = bool.fromEnvironment(
    'ENABLE_NETWORK_MONITORING',
    defaultValue: false,
  );

  final bool enabled;
  final ShareContent shareContent;
  final OpenUrl? openUrl;
  final DevModePasswordValidator? validatePasswordInput;
  final int requiredTaps;
  final Duration tapResetDuration;
  final Color? brandColor;
  final int remoteMonitorPort;

  const NetworkMonitoringConfig({
    required this.shareContent,
    this.enabled = true,
    this.openUrl,
    this.validatePasswordInput,
    this.requiredTaps = 6,
    this.tapResetDuration = const Duration(seconds: 3),
    this.brandColor,
    this.remoteMonitorPort = 7382,
  });

  bool get isPasswordRequired => validatePasswordInput != null;
}
