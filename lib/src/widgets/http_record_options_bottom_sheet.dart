import 'package:flutter/material.dart';

import '../controllers/network_monitor_controller.dart';
import '../l10n/nm_localizations.dart';
import '../models/http_record_model.dart';
import '../theme/nm_theme.dart';

/// Long-press actions for a row in the monitor list.
class HttpRecordOptionsBottomSheet extends StatelessWidget {
  final HttpRecordModel record;
  final NetworkMonitorController controller;
  final VoidCallback onViewDetails;
  final VoidCallback onToggleQuickBreakpoint;
  final VoidCallback onAddCustomBreakpoint;
  final VoidCallback onCopyUrl;

  const HttpRecordOptionsBottomSheet({
    super.key,
    required this.record,
    required this.controller,
    required this.onViewDetails,
    required this.onToggleQuickBreakpoint,
    required this.onAddCustomBreakpoint,
    required this.onCopyUrl,
  });

  static Future<void> show(
    BuildContext context, {
    required HttpRecordModel record,
    required NetworkMonitorController controller,
    required VoidCallback onViewDetails,
    required VoidCallback onToggleQuickBreakpoint,
    required VoidCallback onAddCustomBreakpoint,
    required VoidCallback onCopyUrl,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: NmTheme.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => HttpRecordOptionsBottomSheet(
        record: record,
        controller: controller,
        onViewDetails: onViewDetails,
        onToggleQuickBreakpoint: onToggleQuickBreakpoint,
        onAddCustomBreakpoint: onAddCustomBreakpoint,
        onCopyUrl: onCopyUrl,
      ),
    );
  }

  bool get _hasBreakpoint =>
      controller.hasBreakpointForEndpoint(record.path);

  @override
  Widget build(BuildContext context) {
    final l10n = context.nmL10n;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${record.method} ${record.path}',
              style: NmTextStyles.bold16(context).copyWith(
                color: NmTheme.onSurface(context),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              record.url,
              style: NmTextStyles.regular12(context).copyWith(
                color: NmTheme.onSurfaceVariant(context),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            _OptionTile(
              icon: Icons.open_in_new,
              label: l10n.viewDetails,
              onTap: onViewDetails,
            ),
            _OptionTile(
              icon: _hasBreakpoint
                  ? Icons.pause_circle_filled
                  : Icons.pause_circle_outline,
              label: _hasBreakpoint
                  ? l10n.removeBreakpointThisEndpoint
                  : l10n.addBreakpointThisEndpoint,
              iconColor: _hasBreakpoint ? Colors.orange : null,
              onTap: onToggleQuickBreakpoint,
            ),
            _OptionTile(
              icon: Icons.tune,
              label: l10n.addBreakpointCustom,
              onTap: onAddCustomBreakpoint,
            ),
            _OptionTile(
              icon: Icons.copy,
              label: l10n.copyUrl,
              onTap: onCopyUrl,
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? iconColor;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: iconColor ?? NmTheme.icon(context),
        size: 22,
      ),
      title: Text(
        label,
        style: NmTextStyles.medium14(context).copyWith(
          color: onTap == null
              ? NmTheme.onSurfaceVariant(context)
              : NmTheme.onSurface(context),
        ),
      ),
      onTap: onTap,
    );
  }
}
