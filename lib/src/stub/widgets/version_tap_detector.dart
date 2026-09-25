import 'package:flutter/material.dart';

/// Stub tap detector — returns [child] with no unlock behavior.
class VersionTapDetector extends StatelessWidget {
  final Widget child;

  const VersionTapDetector({super.key, required this.child});

  @override
  Widget build(BuildContext context) => child;
}
