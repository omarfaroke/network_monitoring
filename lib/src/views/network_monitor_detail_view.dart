import 'package:flutter/material.dart';

import '../../generated/l10n/network_monitoring_localizations.dart';
import '../l10n/nm_localizations.dart';
import '../models/http_record_model.dart';
import '../theme/nm_theme.dart';
import 'detail/http_record_detail_actions.dart';
import 'detail/network_monitor_detail_tabs.dart';

/// Tabbed detail screen for a single [HttpRecordModel].
class NetworkMonitorDetailView extends StatelessWidget {
  final HttpRecordModel record;

  const NetworkMonitorDetailView({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final l10n = context.nmL10n;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: NmTheme.surface(context),
        appBar: AppBar(
          title: Text(
            '${record.method} ${record.path}',
            style: NmTextStyles.bold16(context).copyWith(
              color: NmTheme.onSurface(context),
            ),
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
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: NmTheme.icon(context)),
              onSelected: (action) =>
                  HttpRecordDetailActions.handleMenuAction(context, record, action),
              itemBuilder: (_) => _buildMenuItems(l10n),
            ),
          ],
          bottom: TabBar(
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
        body: TabBarView(
          children: [
            NetworkMonitorOverviewTab(record: record),
            NetworkMonitorRequestTab(record: record),
            NetworkMonitorResponseTab(record: record),
            NetworkMonitorHeadersTab(record: record),
          ],
        ),
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems(NetworkMonitoringLocalizations l10n) {
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
