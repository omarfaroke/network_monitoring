import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/nm_localizations.dart';
import '../../theme/nm_theme.dart';
import '../nm_clipboard.dart';
import 'nm_json_table.dart';

/// JSON/text block with optional table view, copy, and share actions.
class NmCodeBlock extends StatefulWidget {
  final String title;
  final String content;
  final bool copyable;

  const NmCodeBlock({
    super.key,
    required this.title,
    required this.content,
    this.copyable = false,
  });

  @override
  State<NmCodeBlock> createState() => _NmCodeBlockState();
}

class _NmCodeBlockState extends State<NmCodeBlock> {
  bool _isTableView = false;

  dynamic get _parsedContent {
    try {
      final decoded = jsonDecode(widget.content);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is List) return decoded;
    } catch (_) {}
    return null;
  }

  bool get _canShowTable => _parsedContent != null;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: NmTheme.fieldBackground(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: NmTheme.border(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: NmTextStyles.bold14(context).copyWith(
                    color: NmTheme.onSurface(context),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_canShowTable) _buildViewToggle(context),
                    if (widget.copyable) ...[
                      const SizedBox(width: 8),
                      _CopyIcon(
                        onTap: () => NmClipboard.copyText(
                          context,
                          widget.content,
                          message: context.nmL10n.copiedTitle(widget.title),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _ShareIcon(
                        onTap: () => SharePlus.instance.share(
                          ShareParams(
                            text: '${widget.title}:\n${widget.content}',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isTableView && _parsedContent != null)
              _parsedContent is Map<String, dynamic>
                  ? NmJsonKeyValueTable(
                      data: _parsedContent as Map<String, dynamic>,
                    )
                  : NmJsonListTable(data: _parsedContent as List)
            else
              _RawContent(content: widget.content),
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggle(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _isTableView = !_isTableView),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _isTableView
              ? NmTheme.primary(context).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          _isTableView ? Icons.code : Icons.table_rows_rounded,
          size: 18,
          color: _isTableView
              ? NmTheme.primary(context)
              : NmTheme.icon(context),
        ),
      ),
    );
  }
}

class _RawContent extends StatelessWidget {
  final String content;

  const _RawContent({required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: NmTheme.surface(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SelectableText(
        content,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 11,
          color: NmTheme.onSurface(context),
        ),
      ),
    );
  }
}

class _CopyIcon extends StatelessWidget {
  final VoidCallback onTap;

  const _CopyIcon({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Icon(Icons.copy, size: 18, color: NmTheme.icon(context)),
    );
  }
}

class _ShareIcon extends StatelessWidget {
  final VoidCallback onTap;

  const _ShareIcon({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Icon(Icons.share, size: 18, color: NmTheme.icon(context)),
    );
  }
}
