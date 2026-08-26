import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../generated/l10n/network_monitoring_localizations.dart';
import '../controllers/network_monitor_controller.dart';
import '../l10n/nm_localizations.dart';
import '../models/http_record_model.dart';
import '../models/network_monitor_change.dart';
import '../models/network_search_scope.dart';
import '../theme/nm_theme.dart';
import '../widgets/applied_breakpoints_bottom_sheet.dart';
import '../widgets/applied_host_overrides_bottom_sheet.dart';
import '../widgets/breakpoint_dialog.dart';
import '../widgets/breakpoint_edit_view.dart';
import '../widgets/clear_records_dialog.dart';
import '../widgets/host_override_dialog.dart';
import '../widgets/http_record_options_bottom_sheet.dart';
import '../widgets/network_monitoring_builder.dart';
import 'dev_mode_options_view.dart';
import 'network_monitor_detail_view.dart';

/// Main screen listing captured HTTP requests with search, filters, and breakpoints.
class NetworkMonitorView extends StatefulWidget {
  const NetworkMonitorView({super.key});

  @override
  State<NetworkMonitorView> createState() => _NetworkMonitorViewState();
}

class _NetworkMonitorViewState extends State<NetworkMonitorView>
    with NetworkMonitorControllerListener {
  @override
  Set<NetworkMonitorChange> get networkMonitorListenTo =>
      NetworkMonitorChanges.monitorView;

  late final TextEditingController _searchController;
  String _searchQuery = '';
  String? _selectedMethod;
  Set<NetworkSearchScope> _searchScopes = {...NetworkSearchScopes.defaults};
  bool _showSearchScopes = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearchScope(NetworkSearchScope scope) {
    setState(() {
      if (_searchScopes.contains(scope)) {
        if (_searchScopes.length == 1) return;
        _searchScopes = {..._searchScopes}..remove(scope);
      } else {
        _searchScopes = {..._searchScopes, scope};
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.nmL10n;
    final controller = networkMonitorController;
    final filteredRecords = controller.filterRecords(
      searchQuery: _searchQuery,
      methodFilter: _selectedMethod,
      searchScopes: _searchScopes,
    );

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: NmTheme.surface(context),
        appBar: AppBar(
          title: Text(
            l10n.networkMonitor,
            style: NmTextStyles.bold18(
              context,
            ).copyWith(color: NmTheme.onSurface(context)),
          ),
          backgroundColor: NmTheme.surface(context),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: NmTheme.icon(context)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            if (controller.activeBreakpointCount > 0)
              _BreakpointBadge(count: controller.activeBreakpointCount),
            IconButton(
              icon: Icon(
                controller.isPausedGlobally
                    ? Icons.play_arrow_rounded
                    : Icons.pause_rounded,
                color: controller.isPausedGlobally
                    ? Colors.orange
                    : NmTheme.icon(context),
              ),
              tooltip: controller.isPausedGlobally
                  ? l10n.resumeAllRequests
                  : l10n.pauseAllRequests,
              onPressed: () => controller.togglePausedGlobally(),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: NmTheme.icon(context)),
              tooltip: l10n.more,
              onSelected: (value) {
                switch (value) {
                  case 'add_breakpoint':
                    BreakpointDialog.show(
                      context,
                      onAdd: controller.addBreakpoint,
                    );
                  case 'breakpoints':
                    AppliedBreakpointsBottomSheet.show(
                      context,
                      controller: controller,
                    );
                  case 'add_host_override':
                    HostOverrideDialog.show(
                      context,
                      onAdd: controller.addHostOverride,
                    );
                  case 'host_overrides':
                    AppliedHostOverridesBottomSheet.show(
                      context,
                      controller: controller,
                    );
                  case 'dev_mode':
                    DevModeOptionsView.push(context);
                  case 'clear':
                    ClearRecordsDialog.show(
                      context,
                      onConfirm: controller.clearRecords,
                    );
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'add_breakpoint',
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: NmTheme.icon(context),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.addBreakpoint,
                        style: NmTextStyles.medium14(
                          context,
                        ).copyWith(color: NmTheme.onSurface(context)),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'breakpoints',
                  child: Row(
                    children: [
                      Icon(
                        Icons.rule,
                        color: controller.breakpoints.isNotEmpty
                            ? NmTheme.primary(context)
                            : NmTheme.icon(context),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.appliedBreakpoints,
                        style: NmTextStyles.medium14(
                          context,
                        ).copyWith(color: NmTheme.onSurface(context)),
                      ),
                      if (controller.breakpoints.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: NmTheme.primary(
                              context,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${controller.breakpoints.length}',
                            style: NmTextStyles.bold10(
                              context,
                            ).copyWith(color: NmTheme.primary(context)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'add_host_override',
                  child: Row(
                    children: [
                      Icon(Icons.swap_horiz, color: NmTheme.icon(context)),
                      const SizedBox(width: 12),
                      Text(
                        l10n.addHostOverride,
                        style: NmTextStyles.medium14(
                          context,
                        ).copyWith(color: NmTheme.onSurface(context)),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'host_overrides',
                  child: Row(
                    children: [
                      Icon(
                        Icons.alt_route,
                        color: controller.hostOverrides.isNotEmpty
                            ? NmTheme.primary(context)
                            : NmTheme.icon(context),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.appliedHostOverrides,
                        style: NmTextStyles.medium14(
                          context,
                        ).copyWith(color: NmTheme.onSurface(context)),
                      ),
                      if (controller.hostOverrides.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: NmTheme.primary(
                              context,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${controller.hostOverrides.length}',
                            style: NmTextStyles.bold10(
                              context,
                            ).copyWith(color: NmTheme.primary(context)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'dev_mode',
                  child: Row(
                    children: [
                      Icon(Icons.developer_mode, color: NmTheme.icon(context)),
                      const SizedBox(width: 12),
                      Text(
                        l10n.devModeOptions,
                        style: NmTextStyles.medium14(
                          context,
                        ).copyWith(color: NmTheme.onSurface(context)),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline, color: Colors.red),
                      const SizedBox(width: 12),
                      Text(
                        l10n.clearAll,
                        style: NmTextStyles.medium14(
                          context,
                        ).copyWith(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            _SearchAndFilterBar(
              searchController: _searchController,
              onSearchChanged: (value) => setState(() => _searchQuery = value),
              selectedMethod: _selectedMethod,
              onMethodChanged: (value) =>
                  setState(() => _selectedMethod = value),
              searchScopes: _searchScopes,
              showSearchScopes: _showSearchScopes,
              onToggleScopesVisibility: () =>
                  setState(() => _showSearchScopes = !_showSearchScopes),
              onToggleSearchScope: _toggleSearchScope,
              onSelectAllScopes: () =>
                  setState(() => _searchScopes = {...NetworkSearchScopes.all}),
              onResetScopes: () => setState(
                () => _searchScopes = {...NetworkSearchScopes.defaults},
              ),
            ),
            if (controller.isPausedGlobally)
              _GlobalPauseHintBar(controller: controller)
            else if (controller.hasEnabledAllEndpointsBreakpoint)
              _AllEndpointsBreakpointHintBar(),
            if (controller.hasEnabledHostOverride)
              _HostOverrideHintBar(controller: controller),
            if (controller.activeBreakpointCount > 0)
              _ActiveBreakpointsBar(controller: controller),
            Expanded(
              child: filteredRecords.isEmpty
                  ? _EmptyState()
                  : ListView.separated(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: filteredRecords.length,
                      separatorBuilder: (context, index) => SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final record = filteredRecords[index];
                        return _HttpRecordCard(
                          record: record,
                          controller: controller,
                          onTap: () => _openRecordDetails(context, record),
                          onLongPress: () => _showRecordOptionsSheet(
                            context,
                            controller,
                            record,
                            onViewDetails: () =>
                                _openRecordDetails(context, record),
                          ),
                          onToggleBreakpoint: () => _toggleQuickBreakpoint(
                            context,
                            controller,
                            record,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _openRecordDetails(BuildContext context, HttpRecordModel record) {
    final initialSearchQuery = _searchQuery.trim();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NetworkMonitorDetailView(
          record: record,
          initialSearchQuery: initialSearchQuery.isEmpty
              ? null
              : initialSearchQuery,
        ),
      ),
    );
  }

  void _showRecordOptionsSheet(
    BuildContext context,
    NetworkMonitorController controller,
    HttpRecordModel record, {
    required VoidCallback onViewDetails,
  }) {
    HttpRecordOptionsBottomSheet.show(
      context,
      record: record,
      controller: controller,
      onViewDetails: () {
        Navigator.of(context).pop();
        onViewDetails();
      },
      onToggleQuickBreakpoint: () {
        Navigator.of(context).pop();
        _toggleQuickBreakpoint(context, controller, record);
      },
      onAddCustomBreakpoint: () {
        Navigator.of(context).pop();
        BreakpointDialog.show(
          context,
          onAdd: controller.addBreakpoint,
          initialEndpointPattern: record.path,
        );
      },
      onAddHostOverride: () {
        Navigator.of(context).pop();
        final host = Uri.tryParse(record.url)?.host;
        HostOverrideDialog.show(
          context,
          onAdd: controller.addHostOverride,
          initialFromHost: host,
          initialUrlPattern: record.path,
        );
      },
      onCopyUrl: () {
        Clipboard.setData(ClipboardData(text: record.url));
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.nmL10n.urlCopied),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      },
    );
  }

  void _toggleQuickBreakpoint(
    BuildContext context,
    NetworkMonitorController controller,
    HttpRecordModel record,
  ) {
    final l10n = context.nmL10n;
    final hadBreakpoint = controller.hasBreakpointForEndpoint(record.path);
    controller.toggleBreakpointForEndpoint(record.path);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          hadBreakpoint
              ? l10n.breakpointRemovedFor(record.path)
              : l10n.breakpointAddedFor(record.path),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _BreakpointBadge extends StatelessWidget {
  final int count;
  const _BreakpointBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 4),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          context.nmL10n.pausedCount(count),
          style: NmTextStyles.bold10(context).copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

class _GlobalPauseHintBar extends StatelessWidget {
  final NetworkMonitorController controller;

  const _GlobalPauseHintBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = context.nmL10n;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.orange.withValues(alpha: 0.12),
      child: Row(
        children: [
          const Icon(Icons.pause_rounded, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.allRequestsPausedHint,
              style: NmTextStyles.medium12(
                context,
              ).copyWith(color: Colors.orange.shade800),
            ),
          ),
          TextButton(
            onPressed: controller.togglePausedGlobally,
            child: Text(
              l10n.resumeAllRequests,
              style: NmTextStyles.bold12(
                context,
              ).copyWith(color: NmTheme.primary(context)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AllEndpointsBreakpointHintBar extends StatelessWidget {
  const _AllEndpointsBreakpointHintBar();

  @override
  Widget build(BuildContext context) {
    final l10n = context.nmL10n;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: NmTheme.primary(context).withValues(alpha: 0.08),
      child: Row(
        children: [
          Icon(Icons.rule, color: NmTheme.primary(context), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.allEndpointsBreakpointActiveHint,
              style: NmTextStyles.medium12(
                context,
              ).copyWith(color: NmTheme.primary(context)),
            ),
          ),
        ],
      ),
    );
  }
}

class _HostOverrideHintBar extends StatelessWidget {
  final NetworkMonitorController controller;

  const _HostOverrideHintBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = context.nmL10n;
    final enabledCount = controller.hostOverrides
        .where((rule) => rule.isEnabled)
        .length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: NmTheme.primary(context).withValues(alpha: 0.08),
      child: Row(
        children: [
          Icon(Icons.swap_horiz, color: NmTheme.primary(context), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.hostOverrideActiveHint(enabledCount),
              style: NmTextStyles.medium12(
                context,
              ).copyWith(color: NmTheme.primary(context)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveBreakpointsBar extends StatelessWidget {
  final NetworkMonitorController controller;
  const _ActiveBreakpointsBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = context.nmL10n;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.orange.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(Icons.pause_circle_filled, color: Colors.orange, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.requestsPaused(controller.activeBreakpointCount),
              style: NmTextStyles.medium12(
                context,
              ).copyWith(color: Colors.orange),
            ),
          ),
          TextButton(
            onPressed: () => controller.continueAllBreakpoints(),
            child: Text(
              l10n.continueAll,
              style: NmTextStyles.bold12(
                context,
              ).copyWith(color: NmTheme.primary(context)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchAndFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String? selectedMethod;
  final ValueChanged<String?> onMethodChanged;
  final Set<NetworkSearchScope> searchScopes;
  final bool showSearchScopes;
  final VoidCallback onToggleScopesVisibility;
  final ValueChanged<NetworkSearchScope> onToggleSearchScope;
  final VoidCallback onSelectAllScopes;
  final VoidCallback onResetScopes;

  const _SearchAndFilterBar({
    required this.searchController,
    required this.onSearchChanged,
    required this.selectedMethod,
    required this.onMethodChanged,
    required this.searchScopes,
    required this.showSearchScopes,
    required this.onToggleScopesVisibility,
    required this.onToggleSearchScope,
    required this.onSelectAllScopes,
    required this.onResetScopes,
  });

  String _scopeLabel(
    NetworkMonitoringLocalizations l10n,
    NetworkSearchScope scope,
  ) {
    switch (scope) {
      case NetworkSearchScope.url:
        return l10n.searchScopeUrl;
      case NetworkSearchScope.status:
        return l10n.searchScopeStatus;
      case NetworkSearchScope.headers:
        return l10n.searchScopeHeaders;
      case NetworkSearchScope.query:
        return l10n.searchScopeQuery;
      case NetworkSearchScope.requestBody:
        return l10n.searchScopeRequest;
      case NetworkSearchScope.responseBody:
        return l10n.searchScopeResponse;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.nmL10n;
    final scopesActive =
        searchScopes.length != NetworkSearchScopes.defaults.length ||
        !searchScopes.containsAll(NetworkSearchScopes.defaults);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            style: NmTextStyles.regular14(
              context,
            ).copyWith(color: NmTheme.onSurface(context)),
            decoration: InputDecoration(
              hintText: l10n.searchHint,
              hintStyle: NmTextStyles.regular14(
                context,
              ).copyWith(color: NmTheme.onSurfaceVariant(context)),
              prefixIcon: Icon(Icons.search, color: NmTheme.icon(context)),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (searchController.text.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.clear, color: NmTheme.icon(context)),
                      onPressed: () {
                        searchController.clear();
                        onSearchChanged('');
                      },
                    ),
                  IconButton(
                    tooltip: l10n.searchScopes,
                    icon: Icon(
                      Icons.tune,
                      color: showSearchScopes || scopesActive
                          ? NmTheme.primary(context)
                          : NmTheme.icon(context),
                    ),
                    onPressed: onToggleScopesVisibility,
                  ),
                ],
              ),
              filled: true,
              fillColor: NmTheme.fieldBackground(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          if (showSearchScopes) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.searchScopes,
                style: NmTextStyles.medium12(
                  context,
                ).copyWith(color: NmTheme.onSurfaceVariant(context)),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final scope in NetworkSearchScope.values)
                  _MethodChip(
                    label: _scopeLabel(l10n, scope),
                    isSelected: searchScopes.contains(scope),
                    onTap: () => onToggleSearchScope(scope),
                  ),
                _MethodChip(
                  label: l10n.searchScopeAll,
                  isSelected:
                      searchScopes.length == NetworkSearchScopes.all.length,
                  onTap: onSelectAllScopes,
                  color: NmTheme.primary(context),
                ),
                _MethodChip(
                  label: l10n.searchScopeReset,
                  isSelected: false,
                  onTap: onResetScopes,
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _MethodChip(
                  label: l10n.filterAll,
                  isSelected: selectedMethod == null,
                  onTap: () => onMethodChanged(null),
                ),
                const SizedBox(width: 8),
                _MethodChip(
                  label: 'GET',
                  isSelected: selectedMethod == 'GET',
                  onTap: () => onMethodChanged('GET'),
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                _MethodChip(
                  label: 'POST',
                  isSelected: selectedMethod == 'POST',
                  onTap: () => onMethodChanged('POST'),
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                _MethodChip(
                  label: 'PUT',
                  isSelected: selectedMethod == 'PUT',
                  onTap: () => onMethodChanged('PUT'),
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                _MethodChip(
                  label: 'PATCH',
                  isSelected: selectedMethod == 'PATCH',
                  onTap: () => onMethodChanged('PATCH'),
                  color: Colors.purple,
                ),
                const SizedBox(width: 8),
                _MethodChip(
                  label: 'DELETE',
                  isSelected: selectedMethod == 'DELETE',
                  onTap: () => onMethodChanged('DELETE'),
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _MethodChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? NmTheme.primary(context)).withValues(alpha: 0.15)
              : NmTheme.fieldBackground(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (color ?? NmTheme.primary(context))
                : NmTheme.border(context),
          ),
        ),
        child: Text(
          label,
          style: NmTextStyles.bold12(context).copyWith(
            color: isSelected
                ? (color ?? NmTheme.primary(context))
                : NmTheme.onSurfaceVariant(context),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.nmL10n;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.http_rounded,
            size: 64,
            color: NmTheme.onSurfaceVariant(context).withValues(alpha: 0.5),
          ),
          SizedBox(height: 16),
          Text(
            l10n.noHttpRequestsRecorded,
            style: NmTextStyles.medium16(
              context,
            ).copyWith(color: NmTheme.onSurfaceVariant(context)),
          ),
          SizedBox(height: 8),
          Text(
            l10n.requestsWillAppearWhenActive,
            style: NmTextStyles.regular14(context).copyWith(
              color: NmTheme.onSurfaceVariant(context).withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _HttpRecordCard extends StatelessWidget {
  final HttpRecordModel record;
  final NetworkMonitorController controller;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onToggleBreakpoint;

  const _HttpRecordCard({
    required this.record,
    required this.controller,
    required this.onTap,
    required this.onLongPress,
    required this.onToggleBreakpoint,
  });

  bool get _hasBreakpoint => controller.hasBreakpointForEndpoint(record.path);

  @override
  Widget build(BuildContext context) {
    final isPaused =
        controller.hasActiveBreakpoint(record.id) ||
        controller.hasActiveBreakpoint('res_${record.id}');
    final accent = isPaused ? Colors.orange : NmTheme.primary(context);

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: isPaused
              ? Colors.orange.withValues(alpha: 0.05)
              : NmTheme.fieldBackground(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPaused
                ? Colors.orange.withValues(alpha: 0.3)
                : NmTheme.border(context),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(12),
          splashColor: accent.withValues(alpha: 0.16),
          highlightColor: accent.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _MethodBadge(method: record.method),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        record.path,
                        style: NmTextStyles.medium12(
                          context,
                        ).copyWith(color: NmTheme.onSurface(context)),
                      ),
                    ),
                    if (isPaused) ...[
                      SizedBox(width: 8),
                      _PausedActions(
                        recordId: record.id,
                        controller: controller,
                      ),
                    ] else ...[
                      _QuickBreakpointButton(
                        hasBreakpoint: _hasBreakpoint,
                        onPressed: onToggleBreakpoint,
                      ),
                      SizedBox(width: 4),
                      _StatusBadge(record: record),
                    ],
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.url,
                            style: NmTextStyles.regular10(
                              context,
                            ).copyWith(color: NmTheme.onSurfaceVariant(context)),
                          ),
                          if (record.originalUrl != null &&
                              record.originalUrl != record.url)
                            Text(
                              record.originalUrl!,
                              style: NmTextStyles.regular10(context).copyWith(
                                color: NmTheme.onSurfaceVariant(
                                  context,
                                ).withValues(alpha: 0.7),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (record.duration != null) ...[
                      SizedBox(width: 8),
                      Text(
                        record.formattedDuration,
                        style: NmTextStyles.regular10(
                          context,
                        ).copyWith(color: NmTheme.onSurfaceVariant(context)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickBreakpointButton extends StatelessWidget {
  final bool hasBreakpoint;
  final VoidCallback onPressed;

  const _QuickBreakpointButton({
    required this.hasBreakpoint,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.nmL10n;

    return Tooltip(
      message: hasBreakpoint
          ? l10n.removeBreakpoint
          : l10n.addBreakpointTooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: hasBreakpoint
                ? Colors.orange.withValues(alpha: 0.15)
                : NmTheme.fieldBackground(context),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: hasBreakpoint
                  ? Colors.orange.withValues(alpha: 0.4)
                  : NmTheme.border(context),
            ),
          ),
          child: Icon(
            hasBreakpoint
                ? Icons.pause_circle_filled
                : Icons.pause_circle_outline,
            size: 16,
            color: hasBreakpoint ? Colors.orange : NmTheme.icon(context),
          ),
        ),
      ),
    );
  }
}

class _PausedActions extends StatelessWidget {
  final String recordId;
  final NetworkMonitorController controller;

  const _PausedActions({required this.recordId, required this.controller});

  @override
  Widget build(BuildContext context) {
    final breakpointId = controller.hasActiveBreakpoint(recordId)
        ? recordId
        : 'res_$recordId';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => BreakpointEditView.show(
            context,
            breakpointId: breakpointId,
            controller: controller,
          ),
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.edit, color: Colors.blue, size: 18),
          ),
        ),
        SizedBox(width: 4),
        InkWell(
          onTap: () => controller.continueBreakpoint(breakpointId),
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.play_arrow, color: Colors.green, size: 18),
          ),
        ),
        SizedBox(width: 4),
        InkWell(
          onTap: () => controller.cancelBreakpoint(breakpointId),
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.stop, color: Colors.red, size: 18),
          ),
        ),
      ],
    );
  }
}

class _MethodBadge extends StatelessWidget {
  final String method;
  const _MethodBadge({required this.method});

  Color get _color {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.blue;
      case 'POST':
        return Colors.green;
      case 'PUT':
        return Colors.orange;
      case 'PATCH':
        return Colors.purple;
      case 'DELETE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        method.toUpperCase(),
        style: NmTextStyles.bold10(context).copyWith(color: _color),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final HttpRecordModel record;
  const _StatusBadge({required this.record});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (record.status) {
      case HttpRecordStatus.pending:
        color = Colors.orange;
        text = '...';
      case HttpRecordStatus.success:
        color = Colors.green;
        text = '${record.statusCode}';
      case HttpRecordStatus.error:
        color = Colors.red;
        text = '${record.statusCode ?? 'ERR'}';
      case HttpRecordStatus.cancelled:
        color = Colors.grey;
        text = context.nmL10n.cancelled;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: NmTextStyles.bold10(context).copyWith(color: color),
      ),
    );
  }
}
