import 'package:flutter/material.dart';

import '../controllers/network_monitor_controller.dart';
import '../l10n/nm_localizations.dart';
import '../models/breakpoint_model.dart';
import '../models/network_monitor_change.dart';
import '../theme/nm_theme.dart';
import 'network_monitoring_builder.dart';

/// Bottom sheet listing host rewrite rules with enable/disable toggles.
class AppliedHostOverridesBottomSheet extends StatefulWidget {
  final NetworkMonitorController controller;

  const AppliedHostOverridesBottomSheet({super.key, required this.controller});

  static Future<void> show(
    BuildContext context, {
    required NetworkMonitorController controller,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: NmTheme.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AppliedHostOverridesBottomSheet(controller: controller),
    );
  }

  @override
  State<AppliedHostOverridesBottomSheet> createState() =>
      _AppliedHostOverridesBottomSheetState();
}

class _AppliedHostOverridesBottomSheetState
    extends State<AppliedHostOverridesBottomSheet>
    with NetworkMonitorControllerListener {
  @override
  Set<NetworkMonitorChange> get networkMonitorListenTo => {
    NetworkMonitorChange.hostOverrides,
  };

  NetworkMonitorController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.nmL10n;
    final rules = controller.hostOverrides;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.swap_horiz,
                  color: NmTheme.primary(context),
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.appliedHostOverrides,
                    style: NmTextStyles.bold16(
                      context,
                    ).copyWith(color: NmTheme.onSurface(context)),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: NmTheme.icon(context)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (rules.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    l10n.noHostOverridesConfigured,
                    style: NmTextStyles.regular14(
                      context,
                    ).copyWith(color: NmTheme.onSurfaceVariant(context)),
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: rules.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final rule = rules[index];
                    final from = rule.fromHost.isEmpty
                        ? l10n.anyHost
                        : rule.fromHost;
                    final targetLabel =
                        rule.target == BreakpointTarget.allEndpoints
                        ? l10n.hostOverrideForAll
                        : (rule.urlPattern ?? l10n.unknown);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: NmTheme.fieldBackground(context),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: NmTheme.border(context)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$from → ${rule.toHost}',
                                  style: NmTextStyles.medium14(
                                    context,
                                  ).copyWith(color: NmTheme.onSurface(context)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  targetLabel,
                                  style: NmTextStyles.regular12(context)
                                      .copyWith(
                                        color: NmTheme.onSurfaceVariant(
                                          context,
                                        ),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: rule.isEnabled,
                            onChanged: (v) =>
                                controller.toggleHostOverride(index, v),
                            activeTrackColor: NmTheme.primary(
                              context,
                            ).withValues(alpha: 0.5),
                            activeThumbColor: NmTheme.primary(context),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed: () =>
                                controller.removeHostOverride(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
