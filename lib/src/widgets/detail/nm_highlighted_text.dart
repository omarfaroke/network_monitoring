import 'package:flutter/material.dart';

import '../../l10n/nm_localizations.dart';
import '../../theme/nm_theme.dart';

/// Highlights case-insensitive [query] matches inside [text].
///
/// When [activeGlobalMatchIndex] points at a match in this text, that match is
/// wrapped with [activeMatchKey] so callers can scroll it into view.
class NmHighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle? style;
  final TextStyle? highlightStyle;
  final TextStyle? activeHighlightStyle;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool selectable;
  final int matchIndexOffset;
  final int? activeGlobalMatchIndex;
  final GlobalKey? activeMatchKey;
  final bool wrapAnywhere;

  const NmHighlightedText({
    super.key,
    required this.text,
    required this.query,
    this.style,
    this.highlightStyle,
    this.activeHighlightStyle,
    this.maxLines,
    this.overflow,
    this.selectable = false,
    this.matchIndexOffset = 0,
    this.activeGlobalMatchIndex,
    this.activeMatchKey,
    this.wrapAnywhere = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle =
        style ??
        TextStyle(
          fontFamily: 'monospace',
          fontSize: 11,
          color: NmTheme.onSurface(context),
        );
    final markStyle =
        highlightStyle ??
        baseStyle.copyWith(
          backgroundColor: Colors.yellow.withValues(alpha: 0.45),
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        );
    final activeStyle =
        activeHighlightStyle ??
        baseStyle.copyWith(
          backgroundColor: Colors.orange.shade400,
          color: Colors.black,
          fontWeight: FontWeight.w700,
        );

    final spans = _buildSpans(
      text: text,
      query: query,
      baseStyle: baseStyle,
      highlightStyle: markStyle,
      activeHighlightStyle: activeStyle,
      matchIndexOffset: matchIndexOffset,
      activeGlobalMatchIndex: activeGlobalMatchIndex,
      activeMatchKey: activeMatchKey,
      wrapAnywhere: wrapAnywhere,
    );

    // WidgetSpan anchors are used for scroll-into-view; keep non-selectable
    // while searching so layout stays stable.
    if (!selectable || query.trim().isNotEmpty) {
      return Text.rich(
        TextSpan(children: spans),
        maxLines: maxLines,
        overflow: overflow ?? TextOverflow.clip,
        softWrap: true,
      );
    }

    return SelectableText.rich(TextSpan(children: spans), style: baseStyle);
  }

  static String _wrapAnywhere(String value) => value.split('').join('\u200B');

  static List<InlineSpan> _buildSpans({
    required String text,
    required String query,
    required TextStyle baseStyle,
    required TextStyle highlightStyle,
    required TextStyle activeHighlightStyle,
    required int matchIndexOffset,
    required int? activeGlobalMatchIndex,
    required GlobalKey? activeMatchKey,
    required bool wrapAnywhere,
  }) {
    String display(String value) => wrapAnywhere ? _wrapAnywhere(value) : value;

    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty || text.isEmpty) {
      return [TextSpan(text: display(text), style: baseStyle)];
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = normalizedQuery.toLowerCase();
    final spans = <InlineSpan>[];
    var start = 0;
    var localMatchIndex = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index < 0) {
        if (start < text.length) {
          spans.add(
            TextSpan(text: display(text.substring(start)), style: baseStyle),
          );
        }
        break;
      }
      if (index > start) {
        spans.add(
          TextSpan(
            text: display(text.substring(start, index)),
            style: baseStyle,
          ),
        );
      }

      final matchText = text.substring(index, index + lowerQuery.length);
      final globalIndex = matchIndexOffset + localMatchIndex;
      final isActive = activeGlobalMatchIndex == globalIndex;
      final displayMatch = display(matchText);

      if (isActive && activeMatchKey != null) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              key: activeMatchKey,
              padding: const EdgeInsets.symmetric(horizontal: 1),
              color: activeHighlightStyle.backgroundColor,
              child: Text(displayMatch, style: activeHighlightStyle),
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: displayMatch,
            style: isActive ? activeHighlightStyle : highlightStyle,
          ),
        );
      }

      localMatchIndex++;
      start = index + lowerQuery.length;
    }

    return spans.isEmpty
        ? [TextSpan(text: display(text), style: baseStyle)]
        : spans;
  }
}

/// Tab indexes available for detail search scoping.
abstract final class DetailSearchTabIndexes {
  static const overview = 0;
  static const request = 1;
  static const response = 2;
  static const headers = 3;
  static const all = {overview, request, response, headers};
}

/// Compact search field with match navigation and optional tab scopes.
class NmDetailSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;
  final int matchCount;
  final int currentMatchIndex;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final String hintText;
  final bool autofocus;
  final bool followCurrentTab;
  final Set<int> selectedTabScopes;
  final bool showTabScopes;
  final VoidCallback onToggleTabScopesVisibility;
  final ValueChanged<int> onToggleTabScope;
  final VoidCallback onSelectAllTabs;
  final VoidCallback onSelectCurrentTab;

  const NmDetailSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClose,
    required this.matchCount,
    required this.hintText,
    required this.followCurrentTab,
    required this.selectedTabScopes,
    required this.showTabScopes,
    required this.onToggleTabScopesVisibility,
    required this.onToggleTabScope,
    required this.onSelectAllTabs,
    required this.onSelectCurrentTab,
    this.currentMatchIndex = 0,
    this.onPrevious,
    this.onNext,
    this.autofocus = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.nmL10n;
    final hasQuery = controller.text.trim().isNotEmpty;
    final hasMatches = matchCount > 0;
    final scopesActive = !followCurrentTab;

    return Material(
      color: NmTheme.fieldBackground(context),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.45),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.search, size: 20, color: NmTheme.icon(context)),
                const SizedBox(width: 8),
                Expanded(
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      inputDecorationTheme: const InputDecorationTheme(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        filled: false,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                      ),
                      textSelectionTheme: TextSelectionThemeData(
                        cursorColor: NmTheme.primary(context),
                        selectionColor: NmTheme.primary(
                          context,
                        ).withValues(alpha: 0.3),
                        selectionHandleColor: NmTheme.primary(context),
                      ),
                    ),
                    child: TextField(
                      controller: controller,
                      autofocus: autofocus,
                      onChanged: onChanged,
                      cursorColor: NmTheme.primary(context),
                      style: NmTextStyles.regular14(context).copyWith(
                        color: NmTheme.onSurface(context),
                        decoration: TextDecoration.none,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        isCollapsed: true,
                        hintText: hintText,
                        hintStyle: NmTextStyles.regular14(context).copyWith(
                          color: NmTheme.onSurfaceVariant(context),
                          decoration: TextDecoration.none,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        filled: false,
                        fillColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                if (hasQuery) ...[
                  Text(
                    hasMatches
                        ? l10n.searchMatchOf(currentMatchIndex + 1, matchCount)
                        : l10n.searchNoMatches,
                    style: NmTextStyles.regular12(context).copyWith(
                      color: hasMatches
                          ? NmTheme.onSurfaceVariant(context)
                          : Colors.red.shade400,
                    ),
                  ),
                  if (hasMatches) ...[
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: l10n.searchPrevious,
                      onPressed: onPrevious,
                      icon: Icon(
                        Icons.keyboard_arrow_up,
                        color: NmTheme.icon(context),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: l10n.searchNext,
                      onPressed: onNext,
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: NmTheme.icon(context),
                      ),
                    ),
                  ],
                ],
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: l10n.searchScopes,
                  onPressed: onToggleTabScopesVisibility,
                  icon: Icon(
                    Icons.tune,
                    color: showTabScopes || scopesActive
                        ? NmTheme.primary(context)
                        : NmTheme.icon(context),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: l10n.cancel,
                  onPressed: onClose,
                  icon: Icon(Icons.close, color: NmTheme.icon(context)),
                ),
              ],
            ),
            if (showTabScopes) ...[
              const SizedBox(height: 8),
              Text(
                l10n.searchScopes,
                style: NmTextStyles.medium12(
                  context,
                ).copyWith(color: NmTheme.onSurfaceVariant(context)),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ScopeChip(
                    label: l10n.searchScopeCurrentTab,
                    isSelected: followCurrentTab,
                    onTap: onSelectCurrentTab,
                    color: NmTheme.primary(context),
                  ),
                  _ScopeChip(
                    label: l10n.overview,
                    isSelected:
                        !followCurrentTab &&
                        selectedTabScopes.contains(
                          DetailSearchTabIndexes.overview,
                        ),
                    onTap: () =>
                        onToggleTabScope(DetailSearchTabIndexes.overview),
                  ),
                  _ScopeChip(
                    label: l10n.request,
                    isSelected:
                        !followCurrentTab &&
                        selectedTabScopes.contains(
                          DetailSearchTabIndexes.request,
                        ),
                    onTap: () =>
                        onToggleTabScope(DetailSearchTabIndexes.request),
                  ),
                  _ScopeChip(
                    label: l10n.response,
                    isSelected:
                        !followCurrentTab &&
                        selectedTabScopes.contains(
                          DetailSearchTabIndexes.response,
                        ),
                    onTap: () =>
                        onToggleTabScope(DetailSearchTabIndexes.response),
                  ),
                  _ScopeChip(
                    label: l10n.headers,
                    isSelected:
                        !followCurrentTab &&
                        selectedTabScopes.contains(
                          DetailSearchTabIndexes.headers,
                        ),
                    onTap: () =>
                        onToggleTabScope(DetailSearchTabIndexes.headers),
                  ),
                  _ScopeChip(
                    label: l10n.searchScopeAllTabs,
                    isSelected:
                        !followCurrentTab &&
                        selectedTabScopes.length ==
                            DetailSearchTabIndexes.all.length &&
                        selectedTabScopes.containsAll(
                          DetailSearchTabIndexes.all,
                        ),
                    onTap: onSelectAllTabs,
                    color: NmTheme.primary(context),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScopeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _ScopeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = color ?? NmTheme.primary(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withValues(alpha: 0.15)
              : NmTheme.surface(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? selectedColor : NmTheme.border(context),
          ),
        ),
        child: Text(
          label,
          style: NmTextStyles.bold12(context).copyWith(
            color: isSelected
                ? selectedColor
                : NmTheme.onSurfaceVariant(context),
          ),
        ),
      ),
    );
  }
}
