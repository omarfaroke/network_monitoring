import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/nm_localizations.dart';

/// Clipboard + snackbar helpers used across monitor UI.
abstract final class NmClipboard {
  NmClipboard._();

  static void copyText(
    BuildContext context,
    String text, {
    required String message,
  }) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    showMessage(context, message);
  }

  static void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showCopied(BuildContext context) {
    showMessage(context, context.nmL10n.copiedToClipboard);
  }
}
