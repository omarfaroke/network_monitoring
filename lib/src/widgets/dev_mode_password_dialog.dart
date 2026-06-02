import 'package:flutter/material.dart';

import '../l10n/nm_localizations.dart';
import '../network_monitoring_registry.dart';
import '../theme/nm_theme.dart';

/// Password prompt shown after the secret tap when [NetworkMonitoringConfig.validatePasswordInput] is set.
class DevModePasswordDialog extends StatefulWidget {
  const DevModePasswordDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const DevModePasswordDialog(),
    );
    return result ?? false;
  }

  @override
  State<DevModePasswordDialog> createState() => _DevModePasswordDialogState();
}

class _DevModePasswordDialogState extends State<DevModePasswordDialog> {
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _validate() async {
    if (_isLoading) return;

    setState(() {
      _errorText = null;
      _isLoading = true;
    });

    try {
      final config = NetworkMonitoringRegistry.config;
      if (!config.isPasswordRequired) {
        if (mounted) Navigator.of(context).pop(true);
        return;
      }

      final validator = config.validatePasswordInput;
      if (validator == null) {
        if (mounted) Navigator.of(context).pop(true);
        return;
      }

      final isValid = await Future.sync(() => validator(_passwordController.text));

      if (!mounted) return;

      if (isValid) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _errorText = context.nmL10n.incorrectPassword;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorText = context.nmL10n.validationFailed;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.nmL10n;

    return AlertDialog(
      backgroundColor: NmTheme.surface(context),
      title: Row(
        children: [
          Icon(
            Icons.developer_mode,
            color: NmTheme.primary(context),
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            l10n.enableDevMode,
            style: NmTextStyles.bold18(context).copyWith(
              color: NmTheme.onSurface(context),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.enterDevModePassword,
            style: NmTextStyles.regular14(context).copyWith(
              color: NmTheme.onSurfaceVariant(context),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: _obscureText,
            autofocus: true,
            enabled: !_isLoading,
            style: NmTextStyles.regular14(context).copyWith(
              color: NmTheme.onSurface(context),
            ),
            decoration: InputDecoration(
              hintText: l10n.password,
              hintStyle: NmTextStyles.regular14(context).copyWith(
                color: NmTheme.onSurfaceVariant(context),
              ),
              errorText: _errorText,
              filled: true,
              fillColor: NmTheme.fieldBackground(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: NmTheme.icon(context),
                ),
                onPressed: _isLoading
                    ? null
                    : () => setState(() => _obscureText = !_obscureText),
              ),
            ),
            onSubmitted: (_) => _validate(),
          ),
          if (_isLoading) ...[
            const SizedBox(height: 16),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: Text(
            l10n.cancel,
            style: NmTextStyles.medium14(context).copyWith(
              color: NmTheme.onSurfaceVariant(context),
            ),
          ),
        ),
        TextButton(
          onPressed: _isLoading ? null : _validate,
          child: Text(
            l10n.enable,
            style: NmTextStyles.bold14(context).copyWith(
              color: NmTheme.primary(context),
            ),
          ),
        ),
      ],
    );
  }
}
