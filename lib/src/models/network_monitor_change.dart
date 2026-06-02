/// Specific controller state domains that UI can subscribe to independently.
enum NetworkMonitorChange {
  /// [NetworkMonitorController.isDevModeEnabled]
  devMode,

  /// [NetworkMonitorController.isMonitoringEnabled]
  monitoring,

  /// [NetworkMonitorController.isOverlayVisible]
  overlay,

  /// HTTP record list and individual record updates.
  records,

  /// Configured breakpoint rules.
  breakpoints,

  /// Requests currently paused at a breakpoint.
  activeBreakpoints,

  /// [NetworkMonitorController.isPausedGlobally]
  globalPause,
}

/// Common subscription groups used by package widgets and host apps.
abstract final class NetworkMonitorChanges {
  /// Rebuild when dev mode is enabled or disabled.
  static const devMode = {NetworkMonitorChange.devMode};

  /// Rebuild when the floating overlay visibility changes.
  static const overlay = {NetworkMonitorChange.overlay};

  /// Rebuild when breakpoint rules are added, removed, or toggled.
  static const breakpoints = {NetworkMonitorChange.breakpoints};

  /// Rebuild when captured records or active breakpoint count changes
  /// (used by the floating button badge).
  static const floatingButton = {
    NetworkMonitorChange.records,
    NetworkMonitorChange.activeBreakpoints,
  };

  /// Rebuild when the monitor list screen needs fresh data.
  static const monitorView = {
    NetworkMonitorChange.records,
    NetworkMonitorChange.breakpoints,
    NetworkMonitorChange.activeBreakpoints,
    NetworkMonitorChange.globalPause,
  };

  /// Rebuild when dev mode settings toggles change.
  static const devModeOptions = {
    NetworkMonitorChange.devMode,
    NetworkMonitorChange.monitoring,
    NetworkMonitorChange.overlay,
    NetworkMonitorChange.breakpoints,
  };
}