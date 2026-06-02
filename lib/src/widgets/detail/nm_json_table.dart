import 'dart:convert';

import 'package:flutter/material.dart';

import '../../l10n/nm_localizations.dart';
import '../../theme/nm_theme.dart';
import '../nm_clipboard.dart';

/// Expandable key-value table for JSON objects (nested up to 5 levels).
class NmJsonKeyValueTable extends StatelessWidget {
  final Map<String, dynamic> data;
  final int depth;

  const NmJsonKeyValueTable({super.key, required this.data, this.depth = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: NmTheme.surface(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: data.entries.map((entry) {
          return NmJsonKeyValueRow(
            entryKey: entry.key,
            value: entry.value,
            depth: depth,
          );
        }).toList(),
      ),
    );
  }
}

/// Expandable table for JSON arrays.
class NmJsonListTable extends StatelessWidget {
  final List data;
  final int depth;

  const NmJsonListTable({super.key, required this.data, this.depth = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: NmTheme.surface(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: data.asMap().entries.map((entry) {
          final index = entry.key;
          final value = entry.value;

          if (value is Map<String, dynamic>) {
            return NmJsonListItemRow(
              index: index,
              value: value,
              depth: depth,
            );
          }

          return NmJsonKeyValueRow(
            entryKey: '[$index]',
            value: value,
            depth: depth,
          );
        }).toList(),
      ),
    );
  }
}

class NmJsonListItemRow extends StatefulWidget {
  final int index;
  final Map<String, dynamic> value;
  final int depth;

  const NmJsonListItemRow({
    super.key,
    required this.index,
    required this.value,
    required this.depth,
  });

  @override
  State<NmJsonListItemRow> createState() => _NmJsonListItemRowState();
}

class _NmJsonListItemRowState extends State<NmJsonListItemRow> {
  bool _isExpanded = false;
  bool _showAsTable = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: NmTheme.border(context).withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: NmTheme.icon(context),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '[${widget.index}]',
                style: NmTextStyles.bold12(context).copyWith(
                  color: NmTheme.primary(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '{${widget.value.length} keys}',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: NmTheme.onSurfaceVariant(context),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              if (_isExpanded)
                InkWell(
                  onTap: () => setState(() => _showAsTable = !_showAsTable),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: !_showAsTable
                          ? NmTheme.primary(context).withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      _showAsTable ? Icons.code : Icons.table_rows_rounded,
                      size: 14,
                      color: !_showAsTable
                          ? NmTheme.primary(context)
                          : NmTheme.icon(context),
                    ),
                  ),
                ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () {
                  final content =
                      const JsonEncoder.withIndent('  ').convert(widget.value);
                  NmClipboard.copyText(
                    context,
                    content,
                    message: context.nmL10n.copiedItem(widget.index),
                  );
                },
                child: Icon(
                  Icons.copy,
                  size: 14,
                  color: NmTheme.icon(context),
                ),
              ),
            ],
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: NmTheme.fieldBackground(context),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: NmTheme.border(context).withValues(alpha: 0.5),
                ),
              ),
              child: _showAsTable
                  ? NmJsonKeyValueTable(
                      data: widget.value,
                      depth: widget.depth + 1,
                    )
                  : SelectableText(
                      const JsonEncoder.withIndent('  ').convert(widget.value),
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: NmTheme.onSurface(context),
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Single expandable row in [NmJsonKeyValueTable] or [NmJsonListTable].
class NmJsonKeyValueRow extends StatefulWidget {
  final String entryKey;
  final dynamic value;
  final int depth;

  const NmJsonKeyValueRow({
    super.key,
    required this.entryKey,
    required this.value,
    required this.depth,
  });

  @override
  State<NmJsonKeyValueRow> createState() => _NmJsonKeyValueRowState();
}

class _NmJsonKeyValueRowState extends State<NmJsonKeyValueRow> {
  bool _isExpanded = false;
  bool _showAsTable = true;

  static const int _maxDepth = 5;

  bool get _isNestedJson {
    return widget.value is Map<String, dynamic>;
  }

  bool get _isNestedList {
    return widget.value is List;
  }

  bool get _isExpandable {
    return (_isNestedJson || _isNestedList) && widget.depth < _maxDepth;
  }

  String get _displayValue {
    if (widget.value == null) return 'null';
    if (_isNestedJson) return '{${(widget.value as Map).length} keys}';
    if (_isNestedList) return '[${(widget.value as List).length} items]';
    return widget.value.toString();
  }

  String get _copyValue {
    if (widget.value == null) return 'null';
    if (_isNestedJson || _isNestedList) {
      return const JsonEncoder.withIndent('  ').convert(widget.value);
    }
    return widget.value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: NmTheme.border(context).withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isExpandable)
                InkWell(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 16,
                      color: NmTheme.icon(context),
                    ),
                  ),
                ),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: _isExpandable
                      ? () => setState(() => _isExpanded = !_isExpanded)
                      : null,
                  child: Text(
                    widget.entryKey,
                    style: NmTextStyles.bold12(context).copyWith(
                      color: NmTheme.primary(context),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: 4,
                child: Text(
                  _displayValue,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: (_isNestedJson || _isNestedList)
                        ? NmTheme.onSurfaceVariant(context)
                        : NmTheme.onSurface(context),
                    fontStyle: (_isNestedJson || _isNestedList)
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              if (_isExpandable && _isExpanded)
                InkWell(
                  onTap: () => setState(() => _showAsTable = !_showAsTable),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: !_showAsTable
                          ? NmTheme.primary(context).withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      _showAsTable ? Icons.code : Icons.table_rows_rounded,
                      size: 14,
                      color: !_showAsTable
                          ? NmTheme.primary(context)
                          : NmTheme.icon(context),
                    ),
                  ),
                ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () {
                  NmClipboard.copyText(
                    context,
                    _copyValue,
                    message: context.nmL10n.copiedKey(widget.entryKey),
                  );
                },
                child: Icon(
                  Icons.copy,
                  size: 14,
                  color: NmTheme.icon(context),
                ),
              ),
            ],
          ),
          if (_isExpandable && _isExpanded) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: NmTheme.fieldBackground(context),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: NmTheme.border(context).withValues(alpha: 0.5),
                ),
              ),
              child: _showAsTable
                  ? _buildTableContent()
                  : SelectableText(
                      const JsonEncoder.withIndent('  ')
                          .convert(widget.value),
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: NmTheme.onSurface(context),
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTableContent() {
    if (_isNestedJson) {
      return NmJsonKeyValueTable(
        data: widget.value as Map<String, dynamic>,
        depth: widget.depth + 1,
      );
    }
    if (_isNestedList) {
      return NmJsonListTable(
        data: widget.value as List,
        depth: widget.depth + 1,
      );
    }
    return const SizedBox.shrink();
  }
}
