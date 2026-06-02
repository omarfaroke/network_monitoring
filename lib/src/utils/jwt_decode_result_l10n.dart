import '../../generated/l10n/network_monitoring_localizations.dart';
import 'jwt_decoder.dart';

/// Localized hint text for non-success [JwtDecodeResult] states.
extension JwtDecodeResultL10n on JwtDecodeResult {
  /// User-facing explanation when JWT decode did not succeed.
  String hintMessage(NetworkMonitoringLocalizations l10n) {    return switch (status) {
      JwtDecodeStatus.notJwt => l10n.jwtNotJwtHint,
      JwtDecodeStatus.decodeFailed => l10n.jwtDecodeFailedHint,
      JwtDecodeStatus.success => '',
    };
  }

  bool get showsErrorHint => status == JwtDecodeStatus.decodeFailed;
}
