import 'package:flutter/material.dart';

import '../l10n/nm_localizations.dart';
import '../models/breakpoint_model.dart';
import '../theme/nm_theme.dart';

/// Modal dialog for creating a new breakpoint rule.
class BreakpointDialog extends StatefulWidget {
  final Function(BreakpointModel) onAdd;
  final String? initialEndpointPattern;

  const BreakpointDialog({
    super.key,
    required this.onAdd,
    this.initialEndpointPattern,
  });

  static Future<void> show(
    BuildContext context, {
    required void Function(BreakpointModel) onAdd,
    String? initialEndpointPattern,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => BreakpointDialog(
        onAdd: onAdd,
        initialEndpointPattern: initialEndpointPattern,
      ),
    );
  }

  @override
  State<BreakpointDialog> createState() => _BreakpointDialogState();
}

class _BreakpointDialogState extends State<BreakpointDialog> {
  late BreakpointTarget _target;
  BreakpointType _type = BreakpointType.all;
  late final TextEditingController _endpointController;

  @override
  void initState() {
    super.initState();
    final pattern = widget.initialEndpointPattern;
    _target = pattern != null && pattern.isNotEmpty
        ? BreakpointTarget.specificEndpoint
        : BreakpointTarget.allEndpoints;
    _endpointController = TextEditingController(text: pattern ?? '');
  }

  @override
  void dispose() {
    _endpointController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.nmL10n;

    return AlertDialog(
      backgroundColor: NmTheme.surface(context),
      title: Text(
        l10n.addBreakpoint,
        style: NmTextStyles.bold18(context).copyWith(
          color: NmTheme.onSurface(context),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.target,
              style: NmTextStyles.bold14(context).copyWith(
                color: NmTheme.onSurface(context),
              ),
            ),
            SizedBox(height: 8),
            RadioListTile<BreakpointTarget>(
              value: BreakpointTarget.allEndpoints,
              groupValue: _target,
              onChanged: (v) => setState(() => _target = v!),
              title: Text(
                l10n.allEndpoints,
                style: NmTextStyles.medium14(context).copyWith(
                  color: NmTheme.onSurface(context),
                ),
              ),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
            RadioListTile<BreakpointTarget>(
              value: BreakpointTarget.specificEndpoint,
              groupValue: _target,
              onChanged: (v) => setState(() => _target = v!),
              title: Text(
                l10n.specificEndpoint,
                style: NmTextStyles.medium14(context).copyWith(
                  color: NmTheme.onSurface(context),
                ),
              ),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
            if (_target == BreakpointTarget.specificEndpoint) ...[
              SizedBox(height: 8),
              TextField(
                controller: _endpointController,
                style: NmTextStyles.regular14(context).copyWith(
                  color: NmTheme.onSurface(context),
                ),
                decoration: InputDecoration(
                  hintText: l10n.endpointPatternHint,
                  hintStyle: NmTextStyles.regular14(context).copyWith(
                    color: NmTheme.onSurfaceVariant(context),
                  ),
                  filled: true,
                  fillColor: NmTheme.fieldBackground(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ],
            SizedBox(height: 16),
            Text(
              l10n.breakOn,
              style: NmTextStyles.bold14(context).copyWith(
                color: NmTheme.onSurface(context),
              ),
            ),
            SizedBox(height: 8),
            RadioListTile<BreakpointType>(
              value: BreakpointType.all,
              groupValue: _type,
              onChanged: (v) => setState(() => _type = v!),
              title: Text(
                l10n.bothRequestAndResponse,
                style: NmTextStyles.medium14(context).copyWith(
                  color: NmTheme.onSurface(context),
                ),
              ),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
            RadioListTile<BreakpointType>(
              value: BreakpointType.request,
              groupValue: _type,
              onChanged: (v) => setState(() => _type = v!),
              title: Text(
                l10n.requestOnly,
                style: NmTextStyles.medium14(context).copyWith(
                  color: NmTheme.onSurface(context),
                ),
              ),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
            RadioListTile<BreakpointType>(
              value: BreakpointType.response,
              groupValue: _type,
              onChanged: (v) => setState(() => _type = v!),
              title: Text(
                l10n.responseOnly,
                style: NmTextStyles.medium14(context).copyWith(
                  color: NmTheme.onSurface(context),
                ),
              ),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ],
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
            final breakpoint = BreakpointModel(
              target: _target,
              type: _type,
              endpointPattern: _target == BreakpointTarget.specificEndpoint
                  ? _endpointController.text
                  : null,
            );
            widget.onAdd(breakpoint);
            Navigator.of(context).pop();
          },
          child: Text(
            l10n.addAction,
            style: NmTextStyles.bold14(context).copyWith(
              color: NmTheme.primary(context),
            ),
          ),
        ),
      ],
    );
  }
}
