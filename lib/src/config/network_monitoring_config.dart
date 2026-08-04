import 'dart:async';

import 'package:flutter/material.dart';

/// Validates user input from the dev mode password dialog.
///
/// Return `true` when access should be granted. Supports sync and async.
/// When `null` on [NetworkMonitoringConfig], dev mode unlocks without a dialog.
typedef DevModePasswordValidator = FutureOr<bool> Function(String password);

/// Host-provided handler for sharing text from the monitoring UI.
typedef ShareContent = void Function(BuildContext context, String content);

/// Host-provided handler for opening a URL (e.g. the remote monitor page).
///
/// When `null` on [NetworkMonitoringConfig], tapping the remote URL copies it
/// instead of launching a browser.
typedef OpenUrl = FutureOr<void> Function(String url);

/// Configuration for the [NetworkMonitoring] package.
class NetworkMonitoringConfig {
  /// Whether the package is active.
  ///
  /// When `false`, the Dio interceptor, dev mode unlock, overlay, and monitoring
  /// UI are disabled. Defaults to `true`.
  final bool enabled;

  /// Host-provided handler for sharing text from the monitoring UI.
  ///
  /// We avoid depending on third-party packages like [share_plus] or [platform_channels] to keep the package lightweight,
  /// and avoid `resolving dependencies` errors in the future.
  ///
  /// So, the host app is responsible for providing a handler for sharing text from the monitoring UI.
  ///
  /// Example:
  /// ```dart
  /// NetworkMonitoringConfig(
  ///   shareContent: (context, content) {
  ///     SharePlus.instance.share(ShareParams(text: content));
  ///   },
  ///  // ...
  /// );
  final ShareContent shareContent;

  /// Opens a URL in the system browser (optional).
  ///
  /// Used by the remote monitor URL in [DevModeOptionsView]. When `null`,
  /// tapping the URL copies it to the clipboard.
  ///
  /// Example:
  /// ```dart
  /// openUrl: (url) => launchUrl(Uri.parse(url)),
  /// ```
  final OpenUrl? openUrl;

  /// Validates the password entered in the dev mode dialog.
  ///
  /// When `null`, dev mode is enabled after the tap gesture without a prompt.
  final DevModePasswordValidator? validatePasswordInput;

  /// Number of taps on the version widget required to trigger dev mode.
  final int requiredTaps;

  /// Duration after which tap count resets if taps are not consecutive enough.
  final Duration tapResetDuration;

  /// Optional brand/accent color used across monitoring UI.
  /// Falls back to [ThemeData.colorScheme.primary] when null.
  final Color? brandColor;

  /// Preferred TCP port for the remote monitor local server.
  ///
  /// If the port is already in use, the server tries the next ports up to
  /// [remoteMonitorPort] + 20.
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

  /// Whether a password dialog is shown before unlocking.
  bool get isPasswordRequired => validatePasswordInput != null;
}
