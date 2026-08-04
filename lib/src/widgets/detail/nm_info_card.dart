import 'package:flutter/material.dart';

import '../../l10n/nm_localizations.dart';
import '../../theme/nm_theme.dart';
import '../../views/detail/detail_search_match.dart';
import '../nm_clipboard.dart';
import 'nm_detail_section.dart';
import 'nm_highlighted_text.dart';

/// Label/value row data for [NmInfoCard].
class NmInfoItem {
  final String label;
  final String value;
  final bool copyable;
  final String? searchBlockId;

  /// Max lines for the value. `null` shows the full value without truncation.
  final int? maxLines;

  /// When `true`, long unbroken strings (e.g. tokens) wrap within the row width.
  final bool wrapAnywhere;

  const NmInfoItem({
    required this.label,
    required this.value,
    this.copyable = false,
    this.searchBlockId,
    this.maxLines = 3,
    this.wrapAnywhere = false,
  });
}

/// Card of label/value rows, optionally with per-row copy actions.
class NmInfoCard extends StatelessWidget {
  final String title;
  final Color? titleColor;
  final List<NmInfoItem> items;
  final String? searchQuery;
  final DetailSearchNavigation? searchNavigation;

  const NmInfoCard({
    super.key,
    required this.title,
    required this.items,
    this.titleColor,
    this.searchQuery,
    this.searchNavigation,
  });

  @override
  Widget build(BuildContext context) {
    return NmDetailSection(
      title: title,
      titleColor: titleColor,
      children: items
          .map(
            (item) => NmInfoItemRow(
              item: item,
              searchQuery: searchNavigation?.query ?? searchQuery,
              searchNavigation: searchNavigation,
            ),
          )
          .toList(),
    );
  }
}

/// Single label/value row inside an [NmInfoCard].
class NmInfoItemRow extends StatelessWidget {
  final NmInfoItem item;
  final String? searchQuery;
  final DetailSearchNavigation? searchNavigation;

  const NmInfoItemRow({
    super.key,
    required this.item,
    this.searchQuery,
    this.searchNavigation,
  });

  @override
  Widget build(BuildContext context) {
    final query = searchQuery?.trim() ?? '';
    final valueStyle = NmTextStyles.regular12(context).copyWith(
      color: NmTheme.onSurface(context),
    );
    final blockId = item.searchBlockId;
    final navigation = searchNavigation;
    final displayValue = item.wrapAnywhere
        ? _wrapAnywhere(item.value)
        : item.value;
    final overflow = item.maxLines == null
        ? TextOverflow.visible
        : TextOverflow.ellipsis;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              item.label,
              style: NmTextStyles.medium12(context).copyWith(
                color: NmTheme.onSurfaceVariant(context),
              ),
            ),
          ),
          Expanded(
            child: query.isEmpty
                ? Text(
                    displayValue,
                    style: valueStyle,
                    maxLines: item.maxLines,
                    overflow: overflow,
                    softWrap: true,
                  )
                : NmHighlightedText(
                    text: item.value,
                    query: query,
                    style: valueStyle,
                    maxLines: item.maxLines,
                    overflow: overflow,
                    wrapAnywhere: item.wrapAnywhere,
                    matchIndexOffset: blockId != null && navigation != null
                        ? navigation.matchIndexOffset(blockId)
                        : 0,
                    activeGlobalMatchIndex: navigation?.activeGlobalIndex,
                    activeMatchKey: blockId != null &&
                            navigation != null &&
                            navigation.isActiveBlock(blockId)
                        ? navigation.activeMatchKey
                        : null,
                  ),
          ),
          if (item.copyable)
            InkWell(
              onTap: () => NmClipboard.copyText(
                context,
                item.value,
                message: context.nmL10n.copiedLabel(item.label),
              ),
              child: Icon(Icons.copy, size: 16, color: NmTheme.icon(context)),
            ),
        ],
      ),
    );
  }

  static String _wrapAnywhere(String value) => value.split('').join('\u200B');
}
