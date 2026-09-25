import 'package:flutter/material.dart';

import '../network_monitor_change.dart';
import '../network_monitor_controller.dart';

/// Stub builder — never rebuilds and renders nothing.
class NetworkMonitoringBuilder extends StatelessWidget {
  /// Ignored in the stub; kept for API compatibility with the full library.
  final Set<NetworkMonitorChange>? listenTo;

  /// Ignored in the stub; kept for API compatibility with the full library.
  final Widget Function(
    BuildContext context,
    NetworkMonitorController controller,
  ) builder;

  const NetworkMonitoringBuilder({
    super.key,
    required this.builder,
    this.listenTo,
  });

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
