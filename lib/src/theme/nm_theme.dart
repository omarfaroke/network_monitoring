import 'package:flutter/material.dart';

import '../network_monitoring_registry.dart';

/// Theme helpers for network monitoring UI. Uses Material theme with optional
/// brand color from [NetworkMonitoringConfig].
class NmTheme {
  NmTheme._();

  static Color primary(BuildContext context) {
    return NetworkMonitoringRegistry.config.brandColor ??
        Theme.of(context).colorScheme.primary;
  }

  static Color surface(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color onSurface(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color onSurfaceVariant(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  static Color fieldBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade900
        : Colors.grey.shade100;
  }

  static Color border(BuildContext context) {
    return Theme.of(context).dividerColor;
  }

  static Color icon(BuildContext context) {
    return Theme.of(context).iconTheme.color ?? onSurface(context);
  }
}

class NmTextStyles {
  NmTextStyles._();

  static TextStyle bold18(BuildContext context) => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: NmTheme.onSurface(context),
      );

  static TextStyle bold16(BuildContext context) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: NmTheme.onSurface(context),
      );

  static TextStyle bold14(BuildContext context) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: NmTheme.onSurface(context),
      );

  static TextStyle bold12(BuildContext context) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: NmTheme.onSurface(context),
      );

  static TextStyle bold10(BuildContext context) => TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: NmTheme.onSurface(context),
      );

  static TextStyle medium16(BuildContext context) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: NmTheme.onSurface(context),
      );

  static TextStyle medium14(BuildContext context) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: NmTheme.onSurface(context),
      );

  static TextStyle medium12(BuildContext context) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: NmTheme.onSurface(context),
      );

  static TextStyle regular14(BuildContext context) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: NmTheme.onSurface(context),
      );

  static TextStyle regular12(BuildContext context) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: NmTheme.onSurface(context),
      );

  static TextStyle regular10(BuildContext context) => TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.normal,
        color: NmTheme.onSurface(context),
      );
}
