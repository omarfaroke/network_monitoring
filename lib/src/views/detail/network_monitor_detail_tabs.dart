import 'package:flutter/material.dart';

import '../../l10n/nm_localizations.dart';
import '../../models/http_record_model.dart';
import '../../utils/date_format_utils.dart';
import '../../widgets/detail/jwt_decode_section.dart';
import '../../widgets/detail/nm_code_block.dart';
import '../../widgets/detail/nm_detail_section.dart';
import '../../widgets/detail/nm_info_card.dart';

/// Overview tab: summary, auth token, and JWT decode for one HTTP record.
class NetworkMonitorOverviewTab extends StatelessWidget {
  final HttpRecordModel record;

  const NetworkMonitorOverviewTab({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final l10n = context.nmL10n;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          NmInfoCard(
            title: l10n.general,
            items: [
              NmInfoItem(label: l10n.url, value: record.url, copyable: true),
              NmInfoItem(label: l10n.method, value: record.method),
              NmInfoItem(
                label: l10n.status,
                value:
                    '${record.statusCode ?? l10n.pending} ${record.statusMessage ?? ''}',
              ),
              NmInfoItem(label: l10n.duration, value: record.formattedDuration),
              NmInfoItem(
                label: l10n.startTime,
                value: NmDateFormat.time(record.startTime),
              ),
              if (record.endTime != null)
                NmInfoItem(
                  label: l10n.endTime,
                  value: NmDateFormat.time(record.endTime!),
                ),
            ],
          ),
          if (record.errorMessage != null) ...[
            const NmDetailGap(),
            NmInfoCard(
              title: l10n.error,
              titleColor: Colors.red,
              items: [
                NmInfoItem(label: l10n.message, value: record.errorMessage!),
              ],
            ),
          ],
          if (record.authToken != null) ...[
            const NmDetailGap(),
            NmInfoCard(
              title: l10n.authentication,
              items: [
                NmInfoItem(
                  label: l10n.token,
                  value: record.authToken!,
                  copyable: true,
                ),
              ],
            ),
            const NmDetailGap(),
            JwtDecodeSection(jwtResult: record.authTokenJwtDecode),
          ],
        ],
      ),
    );
  }
}

/// Request tab: query parameters and request body.
class NetworkMonitorRequestTab extends StatelessWidget {
  final HttpRecordModel record;

  const NetworkMonitorRequestTab({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final l10n = context.nmL10n;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (record.queryParameters != null &&
            record.queryParameters!.isNotEmpty) ...[
          NmCodeBlock(
            title: l10n.queryParameters,
            content: record.queryParametersFormatted,
            copyable: true,
          ),
          const NmDetailGap(),
        ],
        NmCodeBlock(
          title: l10n.requestBody,
          content: record.requestBodyFormatted.isEmpty
              ? l10n.noRequestBody
              : record.requestBodyFormatted,
          copyable: record.requestBodyFormatted.isNotEmpty,
        ),
      ],
    );
  }
}

/// Response tab: response body with JSON/table view.
class NetworkMonitorResponseTab extends StatelessWidget {
  final HttpRecordModel record;

  const NetworkMonitorResponseTab({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final l10n = context.nmL10n;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        NmCodeBlock(
          title: l10n.responseBody,
          content: record.responseBodyFormatted.isEmpty
              ? l10n.noResponseBody
              : record.responseBodyFormatted,
          copyable: record.responseBodyFormatted.isNotEmpty,
        ),
      ],
    );
  }
}

/// Headers tab: request and response headers.
class NetworkMonitorHeadersTab extends StatelessWidget {
  final HttpRecordModel record;

  const NetworkMonitorHeadersTab({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final l10n = context.nmL10n;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        NmCodeBlock(
          title: l10n.requestHeaders,
          content: record.requestHeadersFormatted,
          copyable: true,
        ),
        const NmDetailGap(),
        NmCodeBlock(
          title: l10n.responseHeaders,
          content: record.responseHeadersFormatted.isEmpty
              ? l10n.noResponseHeaders
              : record.responseHeadersFormatted,
          copyable: record.responseHeadersFormatted.isNotEmpty,
        ),
      ],
    );
  }
}
