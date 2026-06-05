import 'dart:async';

import 'package:flutter/material.dart';

import '../network_monitoring.dart';
import '../network_monitoring_registry.dart';

/// Wraps [child] and counts taps to unlock dev mode via [NetworkMonitoringConfig].
class VersionTapDetector extends StatefulWidget {
  final Widget child;

  const VersionTapDetector({super.key, required this.child});

  @override
  State<VersionTapDetector> createState() => _VersionTapDetectorState();
}

class _VersionTapDetectorState extends State<VersionTapDetector> {
  int _tapCount = 0;
  Timer? _resetTimer;

  int get _requiredTaps => NetworkMonitoringRegistry.config.requiredTaps;

  Duration get _resetDuration =>
      NetworkMonitoringRegistry.config.tapResetDuration;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (!NetworkMonitoringRegistry.config.enabled) return;

    _tapCount++;
    _resetTimer?.cancel();
    _resetTimer = Timer(_resetDuration, () {
      _tapCount = 0;
    });

    if (_tapCount >= _requiredTaps) {
      _tapCount = 0;
      _resetTimer?.cancel();

      if (!mounted) return;
      await NetworkMonitoring.instance.controller.requestEnableDevMode(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: widget.child,
    );
  }
}
