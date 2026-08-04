import 'package:flutter/material.dart';

import '../../l10n/nm_localizations.dart';
import '../../models/http_record_model.dart';
import '../../utils/date_format_utils.dart';
import '../../widgets/detail/jwt_decode_section.dart';
import '../../widgets/detail/nm_code_block.dart';
import '../../widgets/detail/nm_detail_section.dart';
import '../../widgets/detail/nm_info_card.dart';
import 'detail_search_match.dart';

export 'detail_search_match.dart';

/// Overview tab: summary, auth token, and JWT decode for one HTTP record.
class NetworkMonitorOverviewTab extends StatelessWidget {
  final HttpRecordModel record;
  final DetailSearchNavigation? searchNavigation;

  const NetworkMonitorOverviewTab({
    super.key,
    required this.record,
    this.searchNavigation,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.nmL10n;
    final query = searchNavigation?.query;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(16),
        children: [
          NmInfoCard(
            title: l10n.general,
            searchQuery: query,
            searchNavigation: searchNavigation,
            items: [
              NmInfoItem(
                label: l10n.url,
                value: record.url,
                copyable: true,
                searchBlockId: DetailSearchBlockIds.overviewUrl,
              ),
              NmInfoItem(
                label: l10n.method,
                value: record.method,
                searchBlockId: DetailSearchBlockIds.overviewMethod,
              ),
              NmInfoItem(
                label: l10n.status,
                value:
                    '${record.statusCode ?? l10n.pending} ${record.statusMessage ?? ''}'
                        .trim(),
                searchBlockId:
                    '${record.statusCode ?? ''} ${record.statusMessage ?? ''}'
                        .trim()
                        .isNotEmpty
                    ? DetailSearchBlockIds.overviewStatus
                    : null,
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
          const NmDetailGap(),
          NmInfoCard(
            title: l10n.size,
            searchQuery: query,
            items: [
              NmInfoItem(
                label: l10n.sizeReqHeaders,
                value: record.formattedRequestHeadersSize,
              ),
              NmInfoItem(
                label: l10n.sizeReqBody,
                value: record.formattedRequestBodySize,
              ),
              NmInfoItem(
                label: l10n.sizeReqTotal,
                value: record.formattedRequestPayloadSize,
              ),
              NmInfoItem(
                label: l10n.sizeResHeaders,
                value: record.formattedResponseHeadersSize,
              ),
              NmInfoItem(
                label: l10n.sizeResBody,
                value: record.formattedResponseBodySize,
              ),
              NmInfoItem(
                label: l10n.sizeResTotal,
                value: record.formattedResponsePayloadSize,
              ),
            ],
          ),
          if (record.errorMessage != null) ...[
            const NmDetailGap(),
            NmInfoCard(
              title: l10n.error,
              titleColor: Colors.red,
              searchQuery: query,
              searchNavigation: searchNavigation,
              items: [
                NmInfoItem(
                  label: l10n.message,
                  value: record.errorMessage!,
                  searchBlockId: DetailSearchBlockIds.overviewError,
                ),
              ],
            ),
          ],
          if (record.authToken != null) ...[
            const NmDetailGap(),
            NmInfoCard(
              title: l10n.authentication,
              searchQuery: query,
              searchNavigation: searchNavigation,
              items: [
                NmInfoItem(
                  label: l10n.token,
                  value: record.authToken!,
                  copyable: true,
                  searchBlockId: DetailSearchBlockIds.overviewToken,
                  maxLines: null,
                  wrapAnywhere: true,
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
  final DetailSearchNavigation? searchNavigation;

  const NetworkMonitorRequestTab({
    super.key,
    required this.record,
    this.searchNavigation,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.nmL10n;
    final query = searchNavigation?.query;

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(16),
      children: [
        if (record.queryParameters != null &&
            record.queryParameters!.isNotEmpty) ...[
          NmCodeBlock(
            title: l10n.queryParameters,
            content: record.queryParametersFormatted,
            copyable: true,
            searchQuery: query,
            searchBlockId: DetailSearchBlockIds.requestQuery,
            searchNavigation: searchNavigation,
          ),
          const NmDetailGap(),
        ],
        NmCodeBlock(
          title: l10n.requestBody,
          content: record.requestBodyFormatted.isEmpty
              ? l10n.noRequestBody
              : record.requestBodyFormatted,
          copyable: record.requestBodyFormatted.isNotEmpty,
          searchQuery: query,
          searchBlockId: record.requestBodyFormatted.isNotEmpty
              ? DetailSearchBlockIds.requestBody
              : null,
          searchNavigation: searchNavigation,
        ),
      ],
    );
  }
}

/// Response tab: response body with JSON/table view.
class NetworkMonitorResponseTab extends StatelessWidget {
  final HttpRecordModel record;
  final DetailSearchNavigation? searchNavigation;

  const NetworkMonitorResponseTab({
    super.key,
    required this.record,
    this.searchNavigation,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.nmL10n;
    final query = searchNavigation?.query;

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(16),
      children: [
        NmCodeBlock(
          title: l10n.responseBody,
          content: record.responseBodyFormatted.isEmpty
              ? l10n.noResponseBody
              : record.responseBodyFormatted,
          copyable: record.responseBodyFormatted.isNotEmpty,
          searchQuery: query,
          searchBlockId: record.responseBodyFormatted.isNotEmpty
              ? DetailSearchBlockIds.responseBody
              : null,
          searchNavigation: searchNavigation,
        ),
      ],
    );
  }
}

/// Headers tab: request and response headers.
class NetworkMonitorHeadersTab extends StatelessWidget {
  final HttpRecordModel record;
  final DetailSearchNavigation? searchNavigation;

  const NetworkMonitorHeadersTab({
    super.key,
    required this.record,
    this.searchNavigation,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.nmL10n;
    final query = searchNavigation?.query;

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(16),
      children: [
        NmCodeBlock(
          title: l10n.requestHeaders,
          content: record.requestHeadersFormatted,
          copyable: true,
          searchQuery: query,
          searchBlockId: DetailSearchBlockIds.requestHeaders,
          searchNavigation: searchNavigation,
        ),
        const NmDetailGap(),
        NmCodeBlock(
          title: l10n.responseHeaders,
          content: record.responseHeadersFormatted.isEmpty
              ? l10n.noResponseHeaders
              : record.responseHeadersFormatted,
          copyable: record.responseHeadersFormatted.isNotEmpty,
          searchQuery: query,
          searchBlockId: record.responseHeadersFormatted.isNotEmpty
              ? DetailSearchBlockIds.responseHeaders
              : null,
          searchNavigation: searchNavigation,
        ),
      ],
    );
  }
}
