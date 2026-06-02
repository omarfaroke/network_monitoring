/// Public API for the [network_monitoring] package.
///
/// Host apps typically need:
/// - [NetworkMonitoring.initialize] and [NetworkMonitoring.createInterceptor]
///   (add the Dio interceptor last in the chain)
/// - [NetworkMonitorOverlayWrapper] inside `MaterialApp.builder`
/// - [VersionTapDetector] on a version label to unlock dev mode (optional;
///   or call `NetworkMonitoring.instance.controller.requestEnableDevMode(context)`)
/// - [NetworkMonitoringBuilder] with [NetworkMonitorChanges] for reactive UI
/// - [DevModeOptionsView] for the dev settings screen
///
/// Optional: register [NetworkMonitoringLocalizations.delegate] for Arabic UI.
library network_monitoring;

export 'generated/l10n/network_monitoring_localizations.dart';
export 'src/config/network_monitoring_config.dart';
export 'src/models/network_monitor_change.dart';
export 'src/network_monitoring.dart';
export 'src/views/dev_mode_options_view.dart';
export 'src/widgets/network_monitor_overlay_wrapper.dart';
export 'src/widgets/network_monitoring_builder.dart';
export 'src/widgets/version_tap_detector.dart';
