import 'dart:convert';
import 'dart:math' as math;

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
  static const _heavyWorkChars = 20 * 1024;

  bool _isTableView = false;
  final Set<int> _collapsed = {};

  List<String> _rawLines = const [];
  List<JsonFoldRange> _foldRanges = const [];
  dynamic _parsedContent;

  bool get _canShowTable => _parsedContent != null;

  bool get _hasSearch {
    final query =
        widget.searchNavigation?.query ?? widget.searchQuery?.trim() ?? '';
    return query.isNotEmpty;
  }

  bool get _canFold => !_hasSearch && _foldRanges.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _indexContent();
    _scheduleHeavyIndex();
  }

  @override
  void didUpdateWidget(covariant NmCodeBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      _collapsed.clear();
      _isTableView = false;
      _indexContent();
      _scheduleHeavyIndex();
    }
  }

  void _indexContent() {
    _rawLines = widget.content.split('\n');
    _foldRanges = const [];
    _parsedContent = null;
  }

  void _scheduleHeavyIndex() {
    final content = widget.content;
    if (content.length < _heavyWorkChars) {
      _runHeavyIndex();
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.content != content) return;
      setState(_runHeavyIndex);
    });
  }

  void _runHeavyIndex() {
    _foldRanges = JsonFoldUtils.rangesFor(widget.content);
    try {
      final decoded = jsonDecode(widget.content);
      if (decoded is Map<String, dynamic> || decoded is List) {
        _parsedContent = decoded;
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final showTable = _isTableView && _canShowTable && !_hasSearch;
    final navigation = widget.searchNavigation;
    final blockId = widget.searchBlockId;
    final query = navigation?.query ?? widget.searchQuery;
    final lines = JsonFoldUtils.visibleLinesFrom(
      rawLines: _rawLines,
      ranges: _canFold ? _foldRanges : const [],
      collapsedStartLines: _canFold ? _collapsed : const {},
    );

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
              _VirtualJsonPane(
                lines: lines,
                onToggleFold: _canFold ? _toggleFold : null,
                searchQuery: query,
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

class _VirtualJsonPane extends StatefulWidget {
  static const _textHeightBehavior = TextHeightBehavior(
    applyHeightToFirstAscent: true,
    applyHeightToLastDescent: true,
    leadingDistribution: TextLeadingDistribution.even,
  );

  final List<JsonFoldLine> lines;
  final ValueChanged<int>? onToggleFold;
  final String? searchQuery;
  final int matchIndexOffset;
  final int? activeGlobalMatchIndex;
  final GlobalKey? activeMatchKey;
  final double fontSize;
  final double lineHeight;
  final double rowHeight;

  const _VirtualJsonPane({
    required this.lines,
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
  State<_VirtualJsonPane> createState() => _VirtualJsonPaneState();
}

class _VirtualJsonPaneState extends State<_VirtualJsonPane> {
  final _gutterController = ScrollController();
  final _codeController = ScrollController();
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _gutterController.addListener(_onGutterScroll);
    _codeController.addListener(_onCodeScroll);
  }

  @override
  void dispose() {
    _gutterController
      ..removeListener(_onGutterScroll)
      ..dispose();
    _codeController
      ..removeListener(_onCodeScroll)
      ..dispose();
    super.dispose();
  }

  void _onGutterScroll() => _mirror(_gutterController, _codeController);

  void _onCodeScroll() => _mirror(_codeController, _gutterController);

  void _mirror(ScrollController from, ScrollController to) {
    if (_syncing || !from.hasClients || !to.hasClients) return;
    final target = from.offset.clamp(0.0, to.position.maxScrollExtent);
    if ((to.offset - target).abs() < 0.5) return;
    _syncing = true;
    to.jumpTo(target);
    _syncing = false;
  }

  @override
  Widget build(BuildContext context) {
    final lines = widget.lines;
    final query = widget.searchQuery?.trim() ?? '';
    final numberWidth = lines.isEmpty ? 1 : lines.last.number.toString().length;
    final style = TextStyle(
      fontFamily: 'monospace',
      fontSize: widget.fontSize,
      height: widget.lineHeight,
      color: NmTheme.onSurface(context),
      leadingDistribution: TextLeadingDistribution.even,
    );
    final strut = StrutStyle(
      fontFamily: 'monospace',
      fontSize: widget.fontSize,
      height: widget.lineHeight,
      forceStrutHeight: true,
      leadingDistribution: TextLeadingDistribution.even,
    );
    final gutterStyle = style.copyWith(
      color: NmTheme.onSurfaceVariant(context).withValues(alpha: 0.7),
    );
    final showFold = query.isEmpty && widget.onToggleFold != null;
    final digitWidth = widget.fontSize * 0.62;
    final gutterWidth = 12 + numberWidth * digitWidth + (showFold ? 18 : 0);
    var maxChars = 1;
    for (final line in lines) {
      if (line.text.length > maxChars) maxChars = line.text.length;
    }
    final codeWidth = maxChars * digitWidth + 16;
    final contentHeight = lines.length * widget.rowHeight;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.65;
    final viewportHeight = math.min(
      contentHeight <= 0 ? widget.rowHeight : contentHeight,
      maxHeight,
    );
    final matchOffsets = query.isEmpty
        ? null
        : _matchOffsetsFor(lines, query, widget.matchIndexOffset);

    return Container(
      width: double.infinity,
      height: viewportHeight + 16,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: NmTheme.surface(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectionContainer.disabled(
            child: ColoredBox(
              color: NmTheme.surface(context),
              child: SizedBox(
                width: gutterWidth,
                height: viewportHeight,
                child: ListView.builder(
                  controller: _gutterController,
                  primary: false,
                  padding: EdgeInsets.zero,
                  physics: const ClampingScrollPhysics(),
                  itemExtent: widget.rowHeight,
                  itemCount: lines.length,
                  itemBuilder: (context, index) {
                    final line = lines[index];
                    return Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8, right: 4),
                            child: Text(
                              '${line.number}'.padLeft(numberWidth),
                              style: gutterStyle,
                              strutStyle: strut,
                              textHeightBehavior:
                                  _VirtualJsonPane._textHeightBehavior,
                              textAlign: TextAlign.right,
                              softWrap: false,
                              maxLines: 1,
                            ),
                          ),
                        ),
                        if (showFold) _foldControl(context, line),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = math.max(codeWidth, constraints.maxWidth);
                return SizedBox(
                  height: viewportHeight,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: width,
                      height: viewportHeight,
                      child: SelectionArea(
                        child: ListView.builder(
                          controller: _codeController,
                          primary: false,
                          padding: EdgeInsets.zero,
                          physics: const ClampingScrollPhysics(),
                          itemExtent: widget.rowHeight,
                          itemCount: lines.length,
                          itemBuilder: (context, index) {
                            final line = lines[index];
                            final text = line.text.isEmpty ? ' ' : line.text;
                            if (query.isEmpty) {
                              return Text(
                                text,
                                style: style,
                                strutStyle: strut,
                                textHeightBehavior:
                                    _VirtualJsonPane._textHeightBehavior,
                                softWrap: false,
                                maxLines: 1,
                              );
                            }
                            final isActiveLine =
                                widget.activeMatchKey != null &&
                                widget.activeGlobalMatchIndex != null &&
                                _lineContainsMatch(
                                  text,
                                  query,
                                  matchOffsets![index],
                                  widget.activeGlobalMatchIndex!,
                                );
                            return NmHighlightedText(
                              text: text,
                              query: query,
                              style: style,
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              matchIndexOffset: matchOffsets![index],
                              activeGlobalMatchIndex:
                                  widget.activeGlobalMatchIndex,
                              activeMatchKey: isActiveLine
                                  ? widget.activeMatchKey
                                  : null,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _foldControl(BuildContext context, JsonFoldLine line) {
    final range = line.foldRange;
    return SizedBox(
      width: 18,
      height: widget.rowHeight,
      child: range == null
          ? const SizedBox.shrink()
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => widget.onToggleFold!(range.startLine),
              child: Center(
                child: Icon(
                  line.isCollapsed ? Icons.arrow_right : Icons.arrow_drop_down,
                  size: 16,
                  color: NmTheme.onSurfaceVariant(context),
                ),
              ),
            ),
    );
  }
}

List<int> _matchOffsetsFor(
  List<JsonFoldLine> lines,
  String query,
  int startOffset,
) {
  final offsets = List<int>.filled(lines.length, 0);
  var acc = startOffset;
  final q = query.toLowerCase();
  for (var i = 0; i < lines.length; i++) {
    offsets[i] = acc;
    acc += _countMatches(lines[i].text, q);
  }
  return offsets;
}

int _countMatches(String text, String lowerQuery) {
  if (lowerQuery.isEmpty || text.isEmpty) return 0;
  final lower = text.toLowerCase();
  var count = 0;
  var start = 0;
  while (true) {
    final index = lower.indexOf(lowerQuery, start);
    if (index < 0) return count;
    count++;
    start = index + lowerQuery.length;
  }
}

bool _lineContainsMatch(
  String text,
  String query,
  int lineOffset,
  int activeGlobalIndex,
) {
  final local = activeGlobalIndex - lineOffset;
  if (local < 0) return false;
  return local < _countMatches(text, query.toLowerCase());
}
