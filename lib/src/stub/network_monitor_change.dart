/// Specific controller state domains that UI can subscribe to independently.
enum NetworkMonitorChange {
  /// Dev mode unlock state.
  devMode,

  /// HTTP monitoring enabled state.
  monitoring,

  /// Floating overlay visibility.
  overlay,

  /// Captured HTTP records.
  records,

  /// Breakpoint rules.
  breakpoints,

  /// Requests paused at a breakpoint.
  activeBreakpoints,

  /// Global pause state.
  globalPause,

  /// Remote monitor state / URL.
  remoteMonitor,

  /// Host rewrite rules.
  hostOverrides,
}

/// Common subscription groups used by package widgets and host apps.
abstract final class NetworkMonitorChanges {
  static const Set<NetworkMonitorChange> devMode = {
    NetworkMonitorChange.devMode,
  };

  static const Set<NetworkMonitorChange> overlay = {
    NetworkMonitorChange.overlay,
  };

  static const Set<NetworkMonitorChange> breakpoints = {
    NetworkMonitorChange.breakpoints,
  };

  static const Set<NetworkMonitorChange> floatingButton = {
    NetworkMonitorChange.records,
    NetworkMonitorChange.activeBreakpoints,
  };

  static const Set<NetworkMonitorChange> monitorView = {
    NetworkMonitorChange.records,
    NetworkMonitorChange.breakpoints,
    NetworkMonitorChange.activeBreakpoints,
    NetworkMonitorChange.globalPause,
    NetworkMonitorChange.hostOverrides,
  };

  static const Set<NetworkMonitorChange> devModeOptions = {
    NetworkMonitorChange.devMode,
    NetworkMonitorChange.monitoring,
    NetworkMonitorChange.overlay,
    NetworkMonitorChange.breakpoints,
    NetworkMonitorChange.hostOverrides,
    NetworkMonitorChange.remoteMonitor,
  };
}
