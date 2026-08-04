import 'dart:convert';

import 'package:flutter/material.dart';

import '../../l10n/nm_localizations.dart';
import '../../utils/nm_share.dart';
import '../../theme/nm_theme.dart';
import '../../views/detail/detail_search_match.dart';
import '../nm_clipboard.dart';
import 'nm_highlighted_text.dart';
import 'nm_json_table.dart';

/// JSON/text block with optional table view, copy, and share actions.
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

  bool get _hasSearch {
    final query =
        widget.searchNavigation?.query ?? widget.searchQuery?.trim() ?? '';
    return query.isNotEmpty;
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
                Text(
                  widget.title,
                  style: NmTextStyles.bold14(
                    context,
                  ).copyWith(color: NmTheme.onSurface(context)),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_canShowTable && !_hasSearch) _buildViewToggle(context),
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
              _RawContent(
                content: widget.content,
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
              ),
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
  final String? searchQuery;
  final int matchIndexOffset;
  final int? activeGlobalMatchIndex;
  final GlobalKey? activeMatchKey;

  const _RawContent({
    required this.content,
    this.searchQuery,
    this.matchIndexOffset = 0,
    this.activeGlobalMatchIndex,
    this.activeMatchKey,
  });

  @override
  Widget build(BuildContext context) {
    final query = searchQuery?.trim() ?? '';
    final style = TextStyle(
      fontFamily: 'monospace',
      fontSize: 11,
      color: NmTheme.onSurface(context),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: NmTheme.surface(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: query.isEmpty
          ? SelectableText(content, style: style)
          : NmHighlightedText(
              text: content,
              query: query,
              style: style,
              matchIndexOffset: matchIndexOffset,
              activeGlobalMatchIndex: activeGlobalMatchIndex,
              activeMatchKey: activeMatchKey,
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
