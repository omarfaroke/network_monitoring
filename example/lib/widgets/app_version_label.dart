import 'package:flutter/material.dart';
import 'package:network_monitoring/network_monitoring.dart';

/// Version text wrapped with [VersionTapDetector] for dev-mode unlock.
class AppVersionLabel extends StatelessWidget {
  final String version;
  final TextStyle? style;

  const AppVersionLabel({
    super.key,
    required this.version,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return VersionTapDetector(
      child: Text(
        'v$version',
        style: style ??
            Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
      ),
    );
  }
}
