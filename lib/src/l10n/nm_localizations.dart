import 'package:flutter/widgets.dart';

import '../../generated/l10n/network_monitoring_localizations.dart';
import '../models/breakpoint_model.dart';
import '../network_monitoring_registry.dart';

const Locale defaultNmLocale = Locale('en');

/// English strings used when [NetworkMonitoringLocalizations.delegate] is not
/// registered in [MaterialApp.localizationsDelegates].
NetworkMonitoringLocalizations lookupDefaultNmL10n() =>
    lookupNetworkMonitoringLocalizations(defaultNmLocale);

NetworkMonitoringLocalizations? maybeNmL10nFromContext(BuildContext context) {
  return Localizations.of<NetworkMonitoringLocalizations>(
    context,
    NetworkMonitoringLocalizations,
  );
}

extension NmLocalizationsContext on BuildContext {
  /// Uses [NetworkMonitoringLocalizations] from [MaterialApp] only when its
  /// delegate is registered. Otherwise returns English defaults.
  NetworkMonitoringLocalizations get nmL10n {
    final fromDelegate = maybeNmL10nFromContext(this);
    if (fromDelegate != null) return fromDelegate;
    return lookupDefaultNmL10n();
  }
}

NetworkMonitoringLocalizations get nmL10nFromRegistry {
  if (!NetworkMonitoringRegistry.isLocalizationDelegateRegistered) {
    return lookupDefaultNmL10n();
  }

  final languageCode =
      NetworkMonitoringRegistry.currentLocale.languageCode.toLowerCase();
  final match = NetworkMonitoringLocalizations.supportedLocales.firstWhere(
    (supported) => supported.languageCode == languageCode,
    orElse: () => defaultNmLocale,
  );

  return lookupNetworkMonitoringLocalizations(match);
}

extension BreakpointTypeLabel on BreakpointType {
  String label(NetworkMonitoringLocalizations l10n) {
    switch (this) {
      case BreakpointType.all:
        return l10n.breakpointTypeAll;
      case BreakpointType.request:
        return l10n.breakpointTypeRequest;
      case BreakpointType.response:
        return l10n.breakpointTypeResponse;
    }
  }
}
