import 'package:flutter/material.dart';

import '../l10n/nm_localizations.dart';
import '../theme/nm_theme.dart';

/// Confirmation dialog before clearing all captured HTTP records.
class ClearRecordsDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const ClearRecordsDialog({super.key, required this.onConfirm});

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => ClearRecordsDialog(onConfirm: onConfirm),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.nmL10n;

    return AlertDialog(
      backgroundColor: NmTheme.surface(context),
      title: Text(
        l10n.clearAllRecordsTitle,
        style: NmTextStyles.bold16(context).copyWith(
          color: NmTheme.onSurface(context),
        ),
      ),
      content: Text(
        l10n.clearAllRecordsMessage,
        style: NmTextStyles.regular14(context).copyWith(
          color: NmTheme.onSurfaceVariant(context),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            l10n.cancel,
            style: NmTextStyles.medium14(context).copyWith(
              color: NmTheme.onSurfaceVariant(context),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          child: Text(
            l10n.clear,
            style: NmTextStyles.bold14(context).copyWith(color: Colors.red),
          ),
        ),
      ],
    );
  }
}
