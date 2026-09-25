import 'package:flutter/material.dart';

/// Stub overlay wrapper — returns [child] unchanged.
class NetworkMonitorOverlayWrapper extends StatelessWidget {
  final Widget child;

  const NetworkMonitorOverlayWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) => child;
}
