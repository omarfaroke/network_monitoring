import 'package:flutter/material.dart';

import '../../l10n/nm_localizations.dart';
import '../../theme/nm_theme.dart';
import '../nm_clipboard.dart';
import 'nm_detail_section.dart';

/// Label/value row data for [NmInfoCard].
class NmInfoItem {
  final String label;
  final String value;
  final bool copyable;

  const NmInfoItem({
    required this.label,
    required this.value,
    this.copyable = false,
  });
}

/// Card of label/value rows, optionally with per-row copy actions.
class NmInfoCard extends StatelessWidget {
  final String title;
  final Color? titleColor;
  final List<NmInfoItem> items;

  const NmInfoCard({
    super.key,
    required this.title,
    required this.items,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return NmDetailSection(
      title: title,
      titleColor: titleColor,
      children: items.map((item) => NmInfoItemRow(item: item)).toList(),
    );
  }
}

/// Single label/value row inside an [NmInfoCard].
class NmInfoItemRow extends StatelessWidget {
  final NmInfoItem item;

  const NmInfoItemRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
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
            child: Text(
              item.value,
              style: NmTextStyles.regular12(context).copyWith(
                color: NmTheme.onSurface(context),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
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
}
