import 'dart:convert';

import 'package:flutter/material.dart';

import '../../l10n/nm_localizations.dart';
import '../../utils/json_fold_utils.dart';
import '../../utils/nm_share.dart';
import '../../theme/nm_theme.dart';
import '../../views/detail/detail_search_match.dart';
import '../nm_clipboard.dart';
import 'nm_highlighted_text.dart';
import 'nm_json_table.dart';

/// JSON/text block with line numbers, JSON folding, table view, copy, and share.
class NmCodeBlock extends StatefulWidget {
  final String title;
  final String content;
  final bool copyable;
  final String? searchQuery;
  final String? searchBlockId;
  final DetailSearchNavigation? searchNavigation;

  const NmCodeBlock({
    super.key,
    required this.title,
    required this.content,
    this.copyable = false,
    this.searchQuery,
    this.searchBlockId,
    this.searchNavigation,
  });

  @override
  State<NmCodeBlock> createState() => _NmCodeBlockState();
}

class _NmCodeBlockState extends State<NmCodeBlock> {
  static const _fontSize = 11.0;
  static const _lineHeight = 1.5;
  static const _rowHeight = _fontSize * _lineHeight;

  bool _isTableView = false;
  final Set<int> _collapsed = {};

  dynamic get _parsedContent {
    try {
      final decoded = jsonDecode(widget.content);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is List) return decoded;
    } catch (_) {}
    return null;
  }

  bool get _canShowTable => _parsedContent != null;

  bool get _hasSearch {
    final query =
        widget.searchNavigation?.query ?? widget.searchQuery?.trim() ?? '';
    return query.isNotEmpty;
  }

  List<JsonFoldRange> get _foldRanges =>
      JsonFoldUtils.rangesFor(widget.content);

  bool get _canFold => !_hasSearch && _foldRanges.isNotEmpty;

  @override
  void didUpdateWidget(covariant NmCodeBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      _collapsed.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final showTable = _isTableView && _canShowTable && !_hasSearch;
    final navigation = widget.searchNavigation;
    final blockId = widget.searchBlockId;

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
                Expanded(
                  child: Text(
                    widget.title,
                    style: NmTextStyles.bold14(
                      context,
                    ).copyWith(color: NmTheme.onSurface(context)),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_canFold)
                      _IconAction(
                        tooltip: _allCollapsed
                            ? context.nmL10n.expandAll
                            : context.nmL10n.collapseAll,
                        icon: Icons.unfold_more,
                        onTap: _toggleFoldAll,
                      ),
                    if (_canShowTable && !_hasSearch) _buildViewToggle(context),
                    if (widget.copyable) ...[
                      const SizedBox(width: 4),
                      _IconAction(
                        icon: Icons.copy,
                        onTap: () => NmClipboard.copyText(
                          context,
                          widget.content,
                          message: context.nmL10n.copiedTitle(widget.title),
                        ),
                      ),
                      _IconAction(
                        icon: Icons.share,
                        onTap: () => nmShareContent(
                          context,
                          '${widget.title}:\n${widget.content}',
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (showTable)
              _parsedContent is Map<String, dynamic>
                  ? NmJsonKeyValueTable(
                      data: _parsedContent as Map<String, dynamic>,
                    )
                  : NmJsonListTable(data: _parsedContent as List)
            else
              _LineNumberedContent(
                content: widget.content,
                collapsed: _canFold ? _collapsed : const {},
                foldRanges: _canFold ? _foldRanges : const [],
                onToggleFold: _canFold ? _toggleFold : null,
                searchQuery: navigation?.query ?? widget.searchQuery,
                matchIndexOffset: blockId != null && navigation != null
                    ? navigation.matchIndexOffset(blockId)
                    : 0,
                activeGlobalMatchIndex: navigation?.activeGlobalIndex,
                activeMatchKey:
                    blockId != null &&
                        navigation != null &&
                        navigation.isActiveBlock(blockId)
                    ? navigation.activeMatchKey
                    : null,
                fontSize: _fontSize,
                lineHeight: _lineHeight,
                rowHeight: _rowHeight,
              ),
          ],
        ),
      ),
    );
  }

  bool get _allCollapsed =>
      _foldRanges.isNotEmpty &&
      _foldRanges.every((range) => _collapsed.contains(range.startLine));

  void _toggleFold(int startLine) {
    setState(() {
      if (_collapsed.contains(startLine)) {
        _collapsed.remove(startLine);
      } else {
        _collapsed.add(startLine);
      }
    });
  }

  void _toggleFoldAll() {
    if (_allCollapsed) {
      setState(_collapsed.clear);
    } else {
      setState(() {
        _collapsed
          ..clear()
          ..addAll(_foldRanges.map((range) => range.startLine));
      });
    }
  }

  Widget _buildViewToggle(BuildContext context) {
    return _IconAction(
      tooltip: _isTableView ? context.nmL10n.rawJson : context.nmL10n.table,
      icon: _isTableView ? Icons.code : Icons.table_rows_rounded,
      active: _isTableView,
      onTap: () => setState(() => _isTableView = !_isTableView),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final bool active;

  const _IconAction({
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: active
              ? NmTheme.primary(context).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          icon,
          size: 18,
          color: active ? NmTheme.primary(context) : NmTheme.icon(context),
        ),
      ),
    );
    if (tooltip == null) return child;
    return Tooltip(message: tooltip!, child: child);
  }
}

class _LineNumberedContent extends StatelessWidget {
  final String content;
  final Set<int> collapsed;
  final List<JsonFoldRange> foldRanges;
  final ValueChanged<int>? onToggleFold;
  final String? searchQuery;
  final int matchIndexOffset;
  final int? activeGlobalMatchIndex;
  final GlobalKey? activeMatchKey;
  final double fontSize;
  final double lineHeight;
  final double rowHeight;

  const _LineNumberedContent({
    required this.content,
    required this.collapsed,
    required this.foldRanges,
    required this.onToggleFold,
    required this.fontSize,
    required this.lineHeight,
    required this.rowHeight,
    this.searchQuery,
    this.matchIndexOffset = 0,
    this.activeGlobalMatchIndex,
    this.activeMatchKey,
  });

  @override
  Widget build(BuildContext context) {
    final query = searchQuery?.trim() ?? '';
    final lines = JsonFoldUtils.visibleLines(
      content: content,
      collapsedStartLines: query.isEmpty ? collapsed : {},
    );
    final displayText = lines.map((line) => line.text).join('\n');
    final numberWidth = lines.isEmpty ? 1 : lines.last.number.toString().length;
    final style = TextStyle(
      fontFamily: 'monospace',
      fontSize: fontSize,
      height: lineHeight,
      color: NmTheme.onSurface(context),
    );
    final strut = StrutStyle(
      fontFamily: 'monospace',
      fontSize: fontSize,
      height: lineHeight,
      forceStrutHeight: true,
    );
    final gutterStyle = style.copyWith(
      color: NmTheme.onSurfaceVariant(context).withValues(alpha: 0.7),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: NmTheme.surface(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: SelectionArea(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectionContainer.disabled(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8, right: 4),
                        child: Text(
                          lines
                              .map(
                                (line) => '${line.number}'.padLeft(numberWidth),
                              )
                              .join('\n'),
                          style: gutterStyle,
                          strutStyle: strut,
                          textAlign: TextAlign.right,
                          softWrap: false,
                        ),
                      ),
                    ),
                    SelectionContainer.disabled(
                      child: _FoldGutter(
                        lines: lines,
                        rowHeight: rowHeight,
                        onToggleFold: onToggleFold,
                      ),
                    ),
                    Container(
                      width: 1,
                      color: NmTheme.border(context),
                      margin: const EdgeInsets.only(right: 8),
                    ),
                    query.isEmpty
                        ? Text(
                            displayText,
                            style: style,
                            strutStyle: strut,
                            softWrap: false,
                          )
                        : NmHighlightedText(
                            text: displayText,
                            query: query,
                            style: style,
                            matchIndexOffset: matchIndexOffset,
                            activeGlobalMatchIndex: activeGlobalMatchIndex,
                            activeMatchKey: activeMatchKey,
                          ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FoldGutter extends StatelessWidget {
  final List<JsonFoldLine> lines;
  final double rowHeight;
  final ValueChanged<int>? onToggleFold;

  const _FoldGutter({
    required this.lines,
    required this.rowHeight,
    required this.onToggleFold,
  });

  @override
  Widget build(BuildContext context) {
    final canFold =
        onToggleFold != null && lines.any((l) => l.foldRange != null);
    if (!canFold) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(right: 2),
      child: Column(
        children: [
          for (final line in lines)
            SizedBox(
              height: rowHeight,
              width: 16,
              child: line.foldRange == null
                  ? const SizedBox.shrink()
                  : GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onToggleFold!(line.foldRange!.startLine),
                      child: Icon(
                        line.isCollapsed
                            ? Icons.chevron_right
                            : Icons.expand_more,
                        size: 14,
                        color: NmTheme.onSurfaceVariant(context),
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}
