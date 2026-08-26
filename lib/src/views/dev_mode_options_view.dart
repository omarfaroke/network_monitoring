import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/nm_localizations.dart';
import '../models/breakpoint_model.dart';
import '../models/network_monitor_change.dart';
import '../network_monitoring_registry.dart';
import '../theme/nm_theme.dart';
import '../widgets/network_monitor_overlay.dart';
import '../widgets/network_monitoring_builder.dart';
import '../widgets/nm_clipboard.dart';

/// Dev mode settings: HTTP monitoring toggle, overlay, remote monitor, and breakpoints.
class DevModeOptionsView extends StatefulWidget {
  const DevModeOptionsView({super.key});

  /// Pushes the dev mode settings route onto [context].
  static void push(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const DevModeOptionsView()));
  }

  @override
  State<DevModeOptionsView> createState() => _DevModeOptionsViewState();
}

class _DevModeOptionsViewState extends State<DevModeOptionsView>
    with NetworkMonitorControllerListener {
  bool _remoteToggleBusy = false;

  @override
  Set<NetworkMonitorChange> get networkMonitorListenTo =>
      NetworkMonitorChanges.devModeOptions;

  Future<void> _onRemoteMonitorChanged(bool value) async {
    if (_remoteToggleBusy) return;
    if (value && !networkMonitorController.isMonitoringEnabled) return;
    setState(() => _remoteToggleBusy = true);
    try {
      await networkMonitorController.toggleRemoteMonitor(value);
    } finally {
      if (mounted) setState(() => _remoteToggleBusy = false);
    }
  }

  Future<void> _openOrCopyRemoteUrl(String url) async {
    final openUrl = NetworkMonitoringRegistry.config.openUrl;
    if (openUrl != null) {
      await openUrl(url);
      return;
    }
    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) return;
    NmClipboard.showMessage(context, context.nmL10n.remoteMonitorUrlCopied);
  }

  void _copyRemoteUrl(String url) {
    NmClipboard.copyText(
      context,
      url,
      message: context.nmL10n.remoteMonitorUrlCopied,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.nmL10n;
    final controller = networkMonitorController;

    return Scaffold(
      backgroundColor: NmTheme.surface(context),
      appBar: AppBar(
        title: Text(
          l10n.devModeOptions,
          style: NmTextStyles.bold18(
            context,
          ).copyWith(color: NmTheme.onSurface(context)),
        ),
        backgroundColor: NmTheme.surface(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: NmTheme.icon(context)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: NmTheme.fieldBackground(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: NmTheme.border(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.httpMonitoring,
                  style: NmTextStyles.bold16(
                    context,
                  ).copyWith(color: NmTheme.onSurface(context)),
                ),
                SizedBox(height: 4),
                Text(
                  l10n.httpMonitoringDescription,
                  style: NmTextStyles.regular12(
                    context,
                  ).copyWith(color: NmTheme.onSurfaceVariant(context)),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.monitoringHttp,
                      style: NmTextStyles.medium14(
                        context,
                      ).copyWith(color: NmTheme.onSurface(context)),
                    ),
                    Switch(
                      value: controller.isMonitoringEnabled,
                      onChanged: (value) {
                        controller.toggleMonitoring(value);
                        if (value) {
                          NetworkMonitorOverlay.show(context);
                        } else {
                          NetworkMonitorOverlay.hide();
                        }
                      },
                      activeTrackColor: NmTheme.primary(
                        context,
                      ).withValues(alpha: 0.5),
                      activeThumbColor: NmTheme.primary(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (controller.isMonitoringEnabled &&
              !controller.isOverlayVisible) ...[
            SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                controller.setOverlayVisible(true);
                NetworkMonitorOverlay.show(context);
              },
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NmTheme.fieldBackground(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NmTheme.border(context)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.visibility,
                      color: NmTheme.primary(context),
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.showFloatingButton,
                        style: NmTextStyles.medium14(
                          context,
                        ).copyWith(color: NmTheme.onSurface(context)),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: NmTheme.icon(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: NmTheme.fieldBackground(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: NmTheme.border(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.remoteMonitor,
                  style: NmTextStyles.bold16(
                    context,
                  ).copyWith(color: NmTheme.onSurface(context)),
                ),
                SizedBox(height: 4),
                Text(
                  l10n.remoteMonitorDescription,
                  style: NmTextStyles.regular12(
                    context,
                  ).copyWith(color: NmTheme.onSurfaceVariant(context)),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        l10n.remoteMonitorEnabled,
                        style: NmTextStyles.medium14(context).copyWith(
                          color: controller.isMonitoringEnabled
                              ? NmTheme.onSurface(context)
                              : NmTheme.onSurfaceVariant(context),
                        ),
                      ),
                    ),
                    if (_remoteToggleBusy)
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: NmTheme.primary(context),
                        ),
                      )
                    else
                      Switch(
                        value:
                            controller.isMonitoringEnabled &&
                            controller.isRemoteMonitorEnabled,
                        onChanged: controller.isMonitoringEnabled
                            ? _onRemoteMonitorChanged
                            : null,
                        activeTrackColor: NmTheme.primary(
                          context,
                        ).withValues(alpha: 0.5),
                        activeThumbColor: NmTheme.primary(context),
                      ),
                  ],
                ),
                if (controller.remoteMonitorError != null) ...[
                  SizedBox(height: 8),
                  Text(
                    '${l10n.remoteMonitorFailed}: ${controller.remoteMonitorError}',
                    style: NmTextStyles.regular12(
                      context,
                    ).copyWith(color: Colors.red),
                  ),
                ],
                if (controller.isRemoteMonitorEnabled &&
                    controller.remoteMonitorUrl != null) ...[
                  SizedBox(height: 12),
                  Text(
                    l10n.remoteMonitorUrl,
                    style: NmTextStyles.medium12(
                      context,
                    ).copyWith(color: NmTheme.onSurfaceVariant(context)),
                  ),
                  SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _openOrCopyRemoteUrl(
                            controller.remoteMonitorUrl!,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              controller.remoteMonitorUrl!,
                              style: NmTextStyles.medium14(context).copyWith(
                                color: NmTheme.primary(context),
                                decoration: TextDecoration.underline,
                                decorationColor: NmTheme.primary(context),
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.copyUrl,
                        onPressed: () =>
                            _copyRemoteUrl(controller.remoteMonitorUrl!),
                        icon: Icon(
                          Icons.copy_rounded,
                          size: 20,
                          color: NmTheme.icon(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 16),
          if (controller.isMonitoringEnabled) ...[
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NmTheme.fieldBackground(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: NmTheme.border(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.breakpoints,
                    style: NmTextStyles.bold16(
                      context,
                    ).copyWith(color: NmTheme.onSurface(context)),
                  ),
                  SizedBox(height: 8),
                  if (controller.breakpoints.isEmpty)
                    Text(
                      l10n.noBreakpointsConfiguredDevMode,
                      style: NmTextStyles.regular12(
                        context,
                      ).copyWith(color: NmTheme.onSurfaceVariant(context)),
                    )
                  else
                    ...controller.breakpoints.asMap().entries.map((entry) {
                      final index = entry.key;
                      final bp = entry.value;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          bp.target == BreakpointTarget.allEndpoints
                              ? l10n.allEndpoints
                              : bp.endpointPattern ?? l10n.unknown,
                          style: NmTextStyles.medium14(
                            context,
                          ).copyWith(color: NmTheme.onSurface(context)),
                        ),
                        subtitle: Text(
                          bp.type.label(l10n),
                          style: NmTextStyles.regular12(
                            context,
                          ).copyWith(color: NmTheme.onSurfaceVariant(context)),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: bp.isEnabled,
                              onChanged: (v) =>
                                  controller.toggleBreakpoint(index, v),
                              activeTrackColor: NmTheme.primary(
                                context,
                              ).withValues(alpha: 0.5),
                              activeThumbColor: NmTheme.primary(context),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () =>
                                  controller.removeBreakpoint(index),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NmTheme.fieldBackground(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: NmTheme.border(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appliedHostOverrides,
                    style: NmTextStyles.bold16(
                      context,
                    ).copyWith(color: NmTheme.onSurface(context)),
                  ),
                  SizedBox(height: 8),
                  if (controller.hostOverrides.isEmpty)
                    Text(
                      l10n.noHostOverridesConfiguredDevMode,
                      style: NmTextStyles.regular12(
                        context,
                      ).copyWith(color: NmTheme.onSurfaceVariant(context)),
                    )
                  else
                    ...controller.hostOverrides.asMap().entries.map((entry) {
                      final index = entry.key;
                      final rule = entry.value;
                      final from = rule.fromHost.isEmpty
                          ? l10n.anyHost
                          : rule.fromHost;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '$from → ${rule.toHost}',
                          style: NmTextStyles.medium14(
                            context,
                          ).copyWith(color: NmTheme.onSurface(context)),
                        ),
                        subtitle: Text(
                          rule.target == BreakpointTarget.allEndpoints
                              ? l10n.hostOverrideForAll
                              : (rule.urlPattern ?? l10n.unknown),
                          style: NmTextStyles.regular12(
                            context,
                          ).copyWith(color: NmTheme.onSurfaceVariant(context)),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
                              icon: Icon(
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
                    }),
                ],
              ),
            ),
          ],
          SizedBox(height: 24),
          TextButton(
            onPressed: () {
              controller.disableDevMode();
              NetworkMonitorOverlay.hide();
              Navigator.of(context).pop();
            },
            child: Text(
              l10n.disableDevMode,
              style: NmTextStyles.bold14(context).copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
