import 'package:flutter/material.dart';

import '../../generated/l10n/network_monitoring_localizations.dart';
import '../l10n/nm_localizations.dart';
import '../models/http_record_model.dart';
import '../theme/nm_theme.dart';
import '../widgets/detail/nm_highlighted_text.dart';
import 'detail/http_record_detail_actions.dart';
import 'detail/network_monitor_detail_tabs.dart';

/// Tabbed detail screen for a single [HttpRecordModel].
class NetworkMonitorDetailView extends StatefulWidget {
  final HttpRecordModel record;

  /// Pre-fills detail search when opened from the list search.
  final String? initialSearchQuery;

  const NetworkMonitorDetailView({
    super.key,
    required this.record,
    this.initialSearchQuery,
  });

  @override
  State<NetworkMonitorDetailView> createState() =>
      _NetworkMonitorDetailViewState();
}

class _NetworkMonitorDetailViewState extends State<NetworkMonitorDetailView>
    with SingleTickerProviderStateMixin {
  static const _tabCount = 4;

  late final TabController _tabController;
  late final TextEditingController _searchController;
  final GlobalKey _activeMatchKey = GlobalKey();

  bool _isSearchVisible = false;
  bool _searchAutofocus = false;
  String _searchQuery = '';
  int _matchCursor = 0;
  int _scrollRequestId = 0;

  /// When `true`, search is limited to the currently selected tab.
  bool _followCurrentTab = true;
  Set<int> _customTabScopes = {...DetailSearchTabIndexes.all};
  bool _showTabScopes = false;

  HttpRecordModel get record => widget.record;

  Set<int> get _effectiveTabScopes =>
      _followCurrentTab ? {_tabController.index} : _customTabScopes;

  DetailSearchMatchInfo get _matchInfo => DetailSearchMatchInfo.analyze(
    record,
    _searchQuery,
    tabIndexes: _effectiveTabScopes,
  );

  DetailSearchNavigation? get _searchNavigation {
    final query = _searchQuery.trim();
    if (query.isEmpty) return null;
    return DetailSearchNavigation(
      query: query,
      activeGlobalIndex: _matchCursor,
      activeMatchKey: _activeMatchKey,
      matchInfo: _matchInfo,
    );
  }

  DetailSearchNavigation? _navigationForTab(int tabIndex) {
    final navigation = _searchNavigation;
    if (navigation == null) return null;
    if (!_effectiveTabScopes.contains(tabIndex)) return null;
    return navigation;
  }

  @override
  void initState() {
    super.initState();
    final initialQuery = widget.initialSearchQuery?.trim() ?? '';
    _searchQuery = initialQuery;
    _isSearchVisible = initialQuery.isNotEmpty;
    _searchAutofocus = false;
    _searchController = TextEditingController(text: initialQuery);

    // Pick the first matching tab across all content, then search that tab.
    final allMatches = DetailSearchMatchInfo.analyze(record, initialQuery);
    final initialTab = allMatches.isEmpty
        ? 0
        : allMatches.matches.first.tabIndex;
    _tabController = TabController(
      length: _tabCount,
      vsync: this,
      initialIndex: initialTab,
    );
    _tabController.addListener(_onTabChanged);

    if (initialQuery.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToActiveMatch(forceTab: false);
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (!_followCurrentTab) return;
    if (!mounted) return;

    setState(() => _matchCursor = 0);
    if (_searchQuery.trim().isNotEmpty) {
      _scrollToActiveMatch(forceTab: false);
    }
  }

  void _toggleSearch() {
    setState(() {
      if (_isSearchVisible) {
        _closeSearch();
      } else {
        _isSearchVisible = true;
        _searchAutofocus = true;
      }
    });
  }

  void _closeSearch() {
    _isSearchVisible = false;
    _searchQuery = '';
    _matchCursor = 0;
    _showTabScopes = false;
    _followCurrentTab = true;
    _searchController.clear();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _matchCursor = 0;
    });

    final matchInfo = _matchInfo;
    if (matchInfo.isEmpty) return;

    final targetTab = matchInfo.matches.first.tabIndex;
    if (!_followCurrentTab && _tabController.index != targetTab) {
      _tabController.animateTo(targetTab);
    }
    _scrollToActiveMatch(forceTab: true);
  }

  void _toggleTabScope(int tabIndex) {
    setState(() {
      if (_followCurrentTab) {
        _followCurrentTab = false;
        _customTabScopes = {tabIndex};
      } else if (_customTabScopes.contains(tabIndex)) {
        if (_customTabScopes.length == 1) return;
        _customTabScopes = {..._customTabScopes}..remove(tabIndex);
      } else {
        _customTabScopes = {..._customTabScopes, tabIndex};
      }
      _matchCursor = 0;
    });
    _scrollToActiveMatch(forceTab: true);
  }

  void _selectAllTabs() {
    setState(() {
      _followCurrentTab = false;
      _customTabScopes = {...DetailSearchTabIndexes.all};
      _matchCursor = 0;
    });
    _scrollToActiveMatch(forceTab: true);
  }

  void _selectCurrentTab() {
    setState(() {
      _followCurrentTab = true;
      _matchCursor = 0;
    });
    _scrollToActiveMatch(forceTab: true);
  }

  Future<void> _goToAdjacentMatch({required bool next}) async {
    final matchInfo = _matchInfo;
    if (matchInfo.isEmpty) return;

    final newIndex = next
        ? (_matchCursor + 1) % matchInfo.totalMatches
        : (_matchCursor - 1 + matchInfo.totalMatches) % matchInfo.totalMatches;
    final match = matchInfo.matches[newIndex];

    setState(() => _matchCursor = newIndex);
    await _scrollToActiveMatch(forceTab: true, targetTab: match.tabIndex);
  }

  Future<void> _scrollToActiveMatch({
    required bool forceTab,
    int? targetTab,
  }) async {
    final requestId = ++_scrollRequestId;
    final matchInfo = _matchInfo;
    if (matchInfo.isEmpty) return;

    final match = matchInfo.matchAt(_matchCursor);
    if (match == null) return;

    final tab = targetTab ?? match.tabIndex;
    if (_tabController.index != tab) {
      _tabController.animateTo(tab);
      await _waitForTabSettled(tab);
      if (!mounted || requestId != _scrollRequestId) return;
      setState(() {});
    } else if (forceTab) {
      setState(() {});
    }

    await _ensureActiveMatchVisible(requestId);
  }

  Future<void> _waitForTabSettled(int tabIndex) async {
    if (_tabController.index == tabIndex && !_tabController.indexIsChanging) {
      await Future<void>.delayed(const Duration(milliseconds: 16));
      return;
    }

    await Future<void>.delayed(_tabController.animationDuration);
    var attempts = 0;
    while (mounted &&
        attempts < 12 &&
        (_tabController.index != tabIndex || _tabController.indexIsChanging)) {
      await Future<void>.delayed(const Duration(milliseconds: 16));
      attempts++;
    }
  }

  Future<void> _ensureActiveMatchVisible(int requestId) async {
    for (var attempt = 0; attempt < 8; attempt++) {
      await Future<void>.delayed(
        Duration(milliseconds: attempt == 0 ? 16 : 32),
      );
      if (!mounted || requestId != _scrollRequestId) return;

      final matchContext = _activeMatchKey.currentContext;
      if (matchContext == null || !matchContext.mounted) continue;

      await Scrollable.ensureVisible(
        matchContext,
        alignment: 0.25,
        alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.nmL10n;
    final matchInfo = _matchInfo;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: NmTheme.surface(context),
        appBar: AppBar(
          title: Text(
            '${record.method} ${record.path}',
            style: NmTextStyles.bold16(
              context,
            ).copyWith(color: NmTheme.onSurface(context)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: NmTheme.surface(context),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: NmTheme.icon(context)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isSearchVisible ? Icons.search_off : Icons.search,
                color: NmTheme.icon(context),
              ),
              tooltip: l10n.searchInDetails,
              onPressed: _toggleSearch,
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: NmTheme.icon(context)),
              onSelected: (action) => HttpRecordDetailActions.handleMenuAction(
                context,
                record,
                action,
              ),
              itemBuilder: (_) => _buildMenuItems(l10n),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: NmTheme.primary(context),
            unselectedLabelColor: NmTheme.onSurfaceVariant(context),
            indicatorColor: NmTheme.primary(context),
            labelStyle: NmTextStyles.bold12(context),
            unselectedLabelStyle: NmTextStyles.medium12(context),
            tabs: [
              Tab(text: l10n.overview),
              Tab(text: l10n.request),
              Tab(text: l10n.response),
              Tab(text: l10n.headers),
            ],
          ),
        ),
        body: Column(
          children: [
            if (_isSearchVisible)
              NmDetailSearchBar(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onClose: () => setState(_closeSearch),
                matchCount: matchInfo.totalMatches,
                currentMatchIndex: matchInfo.isEmpty ? 0 : _matchCursor,
                hintText: l10n.searchInDetailsHint,
                autofocus: _searchAutofocus,
                followCurrentTab: _followCurrentTab,
                selectedTabScopes: _effectiveTabScopes,
                showTabScopes: _showTabScopes,
                onToggleTabScopesVisibility: () =>
                    setState(() => _showTabScopes = !_showTabScopes),
                onToggleTabScope: _toggleTabScope,
                onSelectAllTabs: _selectAllTabs,
                onSelectCurrentTab: _selectCurrentTab,
                onPrevious: () => _goToAdjacentMatch(next: false),
                onNext: () => _goToAdjacentMatch(next: true),
              ),
            Expanded(
              child: Stack(
                children: [
                  TabBarView(
                    controller: _tabController,
                    children: [
                      NetworkMonitorOverviewTab(
                        record: record,
                        searchNavigation: _navigationForTab(0),
                      ),
                      NetworkMonitorRequestTab(
                        record: record,
                        searchNavigation: _navigationForTab(1),
                      ),
                      NetworkMonitorResponseTab(
                        record: record,
                        searchNavigation: _navigationForTab(2),
                      ),
                      NetworkMonitorHeadersTab(
                        record: record,
                        searchNavigation: _navigationForTab(3),
                      ),
                    ],
                  ),
                  if (_isSearchVisible)
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(child: _SearchBarScrollShadow()),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems(
    NetworkMonitoringLocalizations l10n,
  ) {
    return [
      PopupMenuItem(value: 'copy_url', child: Text(l10n.copyUrl)),
      PopupMenuItem(
        value: 'copy_request_headers',
        child: Text(l10n.copyRequestHeaders),
      ),
      PopupMenuItem(
        value: 'copy_request_body',
        child: Text(l10n.copyRequestBody),
      ),
      PopupMenuItem(
        value: 'copy_response_body',
        child: Text(l10n.copyResponseBody),
      ),
      if (record.authToken != null)
        PopupMenuItem(value: 'copy_token', child: Text(l10n.copyAuthToken)),
      if (record.hasDecodedAuthToken)
        PopupMenuItem(
          value: 'copy_jwt_payload',
          child: Text(l10n.copyJwtPayload),
        ),
      PopupMenuItem(value: 'share_all', child: Text(l10n.shareAllDetails)),
    ];
  }
}

/// Soft shadow painted over scrolling detail content under the search bar.
class _SearchBarScrollShadow extends StatelessWidget {
  const _SearchBarScrollShadow();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 8,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: isDark ? 0.45 : 0.16),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
