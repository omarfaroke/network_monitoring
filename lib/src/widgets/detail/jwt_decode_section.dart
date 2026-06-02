import 'package:flutter/material.dart';

import '../../l10n/nm_localizations.dart';
import '../../theme/nm_theme.dart';
import '../../utils/date_format_utils.dart';
import '../../utils/jwt_decoder.dart';
import '../../utils/jwt_decode_result_l10n.dart';
import 'nm_code_block.dart';
import 'nm_detail_section.dart';
import 'nm_info_card.dart';

/// JWT decode block on the request overview tab.
class JwtDecodeSection extends StatelessWidget {
  final JwtDecodeResult jwtResult;

  const JwtDecodeSection({super.key, required this.jwtResult});

  @override
  Widget build(BuildContext context) {
    final l10n = context.nmL10n;

    return NmDetailSection(
      title: l10n.jwtDecode,
      children: [
        if (jwtResult.isSuccess)
          _DecodedJwtContent(jwt: jwtResult.token!)
        else
          _JwtDecodeHint(
            message: jwtResult.hintMessage(l10n),
            isError: jwtResult.showsErrorHint,
          ),
      ],
    );
  }
}

class _DecodedJwtContent extends StatelessWidget {
  final JwtDecodedToken jwt;

  const _DecodedJwtContent({required this.jwt});

  @override
  Widget build(BuildContext context) {
    final l10n = context.nmL10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (jwt.issuedAt != null)
          NmInfoItemRow(
            item: NmInfoItem(
              label: l10n.issuedAt,
              value: NmDateFormat.dateTime(jwt.issuedAt!),
            ),
          ),
        if (jwt.expiresAt != null)
          NmInfoItemRow(
            item: NmInfoItem(
              label: l10n.expiresAt,
              value: NmDateFormat.dateTime(jwt.expiresAt!),
            ),
          ),
        if (jwt.issuedAt != null || jwt.expiresAt != null)
          const SizedBox(height: 8),
        if (jwt.headerFormatted.isNotEmpty) ...[
          NmCodeBlock(
            title: l10n.jwtHeader,
            content: jwt.headerFormatted,
            copyable: true,
          ),
          const SizedBox(height: 12),
        ],
        if (jwt.payloadFormatted.isNotEmpty)
          NmCodeBlock(
            title: l10n.jwtPayload,
            content: jwt.payloadFormatted,
            copyable: true,
          ),
      ],
    );
  }
}

class _JwtDecodeHint extends StatelessWidget {
  final String message;
  final bool isError;

  const _JwtDecodeHint({
    required this.message,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isError ? Colors.orange.shade800 : NmTheme.onSurfaceVariant(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError
            ? Colors.orange.withValues(alpha: 0.08)
            : NmTheme.surface(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isError
              ? Colors.orange.withValues(alpha: 0.35)
              : NmTheme.border(context),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.info_outline,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: NmTextStyles.regular12(context).copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
