import 'package:flutter/material.dart';

import '../l10n/nm_localizations.dart';
import '../models/network_monitor_change.dart';
import '../network_monitoring_registry.dart';
import 'network_monitor_overlay.dart';
import 'network_monitoring_builder.dart';

/// Wraps the app content and syncs the floating network monitor overlay
/// visibility with [NetworkMonitorController.isOverlayVisible].
class NetworkMonitorOverlayWrapper extends StatefulWidget {
  final Widget child;

  const NetworkMonitorOverlayWrapper({super.key, required this.child});

  @override
  State<NetworkMonitorOverlayWrapper> createState() =>
      _NetworkMonitorOverlayWrapperState();
}

class _NetworkMonitorOverlayWrapperState extends State<NetworkMonitorOverlayWrapper>
    with NetworkMonitorControllerListener {
  @override
  Set<NetworkMonitorChange> get networkMonitorListenTo =>
      NetworkMonitorChanges.overlay;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncOverlay();
    });
  }

  @override
  void onNetworkMonitorChanged() {
    _syncOverlay();
  }

  void _syncOverlay() {
    final controller = networkMonitorController;
    if (controller.isOverlayVisible && !NetworkMonitorOverlay.isShowing) {
      NetworkMonitorOverlay.show(context);
    } else if (!controller.isOverlayVisible && NetworkMonitorOverlay.isShowing) {
      NetworkMonitorOverlay.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localized = maybeNmL10nFromContext(context);
    NetworkMonitoringRegistry.isLocalizationDelegateRegistered =
        localized != null;
    NetworkMonitoringRegistry.currentLocale = localized != null
        ? Localizations.localeOf(context)
        : defaultNmLocale;
    return widget.child;
  }
}
