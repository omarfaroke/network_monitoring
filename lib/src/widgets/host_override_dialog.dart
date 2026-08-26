import 'package:flutter/material.dart';

import '../l10n/nm_localizations.dart';
import '../models/breakpoint_model.dart';
import '../models/host_override_model.dart';
import '../theme/nm_theme.dart';

/// Dialog for creating a host rewrite rule.
class HostOverrideDialog extends StatefulWidget {
  final void Function(HostOverrideModel) onAdd;
  final String? initialFromHost;
  final String? initialUrlPattern;

  const HostOverrideDialog({
    super.key,
    required this.onAdd,
    this.initialFromHost,
    this.initialUrlPattern,
  });

  static Future<void> show(
    BuildContext context, {
    required void Function(HostOverrideModel) onAdd,
    String? initialFromHost,
    String? initialUrlPattern,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => HostOverrideDialog(
        onAdd: onAdd,
        initialFromHost: initialFromHost,
        initialUrlPattern: initialUrlPattern,
      ),
    );
  }

  @override
  State<HostOverrideDialog> createState() => _HostOverrideDialogState();
}

class _HostOverrideDialogState extends State<HostOverrideDialog> {
  late BreakpointTarget _target;
  late final TextEditingController _fromHostController;
  late final TextEditingController _toHostController;
  late final TextEditingController _patternController;

  @override
  void initState() {
    super.initState();
    final pattern = widget.initialUrlPattern;
    _target = pattern != null && pattern.isNotEmpty
        ? BreakpointTarget.specificEndpoint
        : BreakpointTarget.allEndpoints;
    _fromHostController = TextEditingController(
      text: widget.initialFromHost ?? '',
    );
    _toHostController = TextEditingController();
    _patternController = TextEditingController(text: pattern ?? '');
  }

  @override
  void dispose() {
    _fromHostController.dispose();
    _toHostController.dispose();
    _patternController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.nmL10n;

    return AlertDialog(
      backgroundColor: NmTheme.surface(context),
      title: Text(
        l10n.addHostOverride,
        style: NmTextStyles.bold18(
          context,
        ).copyWith(color: NmTheme.onSurface(context)),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.fromHost,
              style: NmTextStyles.bold14(
                context,
              ).copyWith(color: NmTheme.onSurface(context)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _fromHostController,
              style: NmTextStyles.regular14(
                context,
              ).copyWith(color: NmTheme.onSurface(context)),
              decoration: InputDecoration(
                hintText: l10n.fromHostHint,
                hintStyle: NmTextStyles.regular14(
                  context,
                ).copyWith(color: NmTheme.onSurfaceVariant(context)),
                filled: true,
                fillColor: NmTheme.fieldBackground(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.toHost,
              style: NmTextStyles.bold14(
                context,
              ).copyWith(color: NmTheme.onSurface(context)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _toHostController,
              style: NmTextStyles.regular14(
                context,
              ).copyWith(color: NmTheme.onSurface(context)),
              decoration: InputDecoration(
                hintText: l10n.toHostHint,
                hintStyle: NmTextStyles.regular14(
                  context,
                ).copyWith(color: NmTheme.onSurfaceVariant(context)),
                filled: true,
                fillColor: NmTheme.fieldBackground(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.target,
              style: NmTextStyles.bold14(
                context,
              ).copyWith(color: NmTheme.onSurface(context)),
            ),
            const SizedBox(height: 8),
            RadioGroup<BreakpointTarget>(
              groupValue: _target,
              onChanged: (v) => setState(() => _target = v!),
              child: Column(
                children: [
                  RadioListTile<BreakpointTarget>(
                    value: BreakpointTarget.allEndpoints,
                    title: Text(
                      l10n.hostOverrideForAll,
                      style: NmTextStyles.medium14(
                        context,
                      ).copyWith(color: NmTheme.onSurface(context)),
                    ),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                  RadioListTile<BreakpointTarget>(
                    value: BreakpointTarget.specificEndpoint,
                    title: Text(
                      l10n.hostOverrideForSpecific,
                      style: NmTextStyles.medium14(
                        context,
                      ).copyWith(color: NmTheme.onSurface(context)),
                    ),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ],
              ),
            ),
            if (_target == BreakpointTarget.specificEndpoint) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _patternController,
                style: NmTextStyles.regular14(
                  context,
                ).copyWith(color: NmTheme.onSurface(context)),
                decoration: InputDecoration(
                  hintText: l10n.endpointPatternHint,
                  hintStyle: NmTextStyles.regular14(
                    context,
                  ).copyWith(color: NmTheme.onSurfaceVariant(context)),
                  filled: true,
                  fillColor: NmTheme.fieldBackground(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            l10n.cancel,
            style: NmTextStyles.medium14(
              context,
            ).copyWith(color: NmTheme.onSurfaceVariant(context)),
          ),
        ),
        TextButton(
          onPressed: () {
            final toHost = _toHostController.text.trim();
            if (toHost.isEmpty) return;
            widget.onAdd(
              HostOverrideModel(
                fromHost: _fromHostController.text.trim(),
                toHost: toHost,
                target: _target,
                urlPattern: _target == BreakpointTarget.specificEndpoint
                    ? _patternController.text.trim()
                    : null,
              ),
            );
            Navigator.of(context).pop();
          },
          child: Text(
            l10n.addAction,
            style: NmTextStyles.bold14(
              context,
            ).copyWith(color: NmTheme.primary(context)),
          ),
        ),
      ],
    );
  }
}
