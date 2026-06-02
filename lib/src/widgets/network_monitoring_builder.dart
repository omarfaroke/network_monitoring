import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/network_monitor_controller.dart';
import '../models/network_monitor_change.dart';
import '../network_monitoring.dart';

/// Rebuilds when selected [NetworkMonitorController] state changes.
class NetworkMonitoringBuilder extends StatefulWidget {
  /// When null, rebuilds on every controller change.
  /// Prefer [NetworkMonitorChanges] groups to limit rebuilds.
  final Set<NetworkMonitorChange>? listenTo;

  /// Receives the live controller; read flags and lists directly from it.
  final Widget Function(    BuildContext context,
    NetworkMonitorController controller,
  ) builder;

  const NetworkMonitoringBuilder({
    super.key,
    required this.builder,
    this.listenTo,
  });

  @override
  State<NetworkMonitoringBuilder> createState() =>
      _NetworkMonitoringBuilderState();
}

class _NetworkMonitoringBuilderState extends State<NetworkMonitoringBuilder> {
  late final NetworkMonitorController _controller;
  StreamSubscription<void>? _subscription;

  @override
  void initState() {
    super.initState();
    _controller = NetworkMonitoring.instance.controller;
    _subscribe();
  }

  @override
  void didUpdateWidget(covariant NetworkMonitoringBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listenTo != widget.listenTo) {
      _subscribe();
    }
  }

  void _subscribe() {
    _subscription?.cancel();
    final listenTo = widget.listenTo;
    _subscription = (listenTo == null
            ? _controller.changes.map((_) {})
            : _controller.watchChanges(listenTo))
        .listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _controller);
  }
}

/// Mixin for [State] widgets that need to rebuild on controller changes.
mixin NetworkMonitorControllerListener<T extends StatefulWidget> on State<T> {
  NetworkMonitorController get networkMonitorController =>
      NetworkMonitoring.instance.controller;

  /// Override to rebuild only when relevant controller domains change.
  Set<NetworkMonitorChange> get networkMonitorListenTo =>
      NetworkMonitorChange.values.toSet();

  StreamSubscription<void>? _networkMonitorSubscription;

  @override
  void initState() {
    super.initState();
    listenToNetworkMonitorController();
  }

  void listenToNetworkMonitorController() {
    _networkMonitorSubscription?.cancel();
    _networkMonitorSubscription = networkMonitorController
        .watchChanges(networkMonitorListenTo)
        .listen((_) => onNetworkMonitorChanged());
  }

  void onNetworkMonitorChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _networkMonitorSubscription?.cancel();
    super.dispose();
  }
}
