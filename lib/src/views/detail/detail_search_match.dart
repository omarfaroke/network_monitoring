import 'package:flutter/widgets.dart';

import '../../models/http_record_model.dart';
import '../../utils/http_record_search_utils.dart';

/// A single find-in-page match inside the detail view.
class DetailSearchMatch {
  final int globalIndex;
  final int tabIndex;
  final String blockId;

  const DetailSearchMatch({
    required this.globalIndex,
    required this.tabIndex,
    required this.blockId,
  });
}

/// Searchable text block shown on a detail tab.
class DetailSearchBlock {
  final int tabIndex;
  final String blockId;
  final String text;

  const DetailSearchBlock({
    required this.tabIndex,
    required this.blockId,
    required this.text,
  });
}

/// Flat match list + helpers for detail-view search navigation.
class DetailSearchMatchInfo {
  final List<DetailSearchMatch> matches;
  final String query;

  const DetailSearchMatchInfo({required this.matches, required this.query});

  static const empty = DetailSearchMatchInfo(matches: [], query: '');

  int get totalMatches => matches.length;

  bool get isEmpty => matches.isEmpty;

  DetailSearchMatch? matchAt(int index) {
    if (matches.isEmpty) return null;
    if (index < 0 || index >= matches.length) return null;
    return matches[index];
  }

  /// Global index of the first match in [blockId], or `null` if none.
  int? firstGlobalIndexForBlock(String blockId) {
    for (final match in matches) {
      if (match.blockId == blockId) return match.globalIndex;
    }
    return null;
  }

  static List<DetailSearchBlock> blocksFor(HttpRecordModel record) {
    return [
      DetailSearchBlock(
        tabIndex: 0,
        blockId: DetailSearchBlockIds.overviewUrl,
        text: record.url,
      ),
      DetailSearchBlock(
        tabIndex: 0,
        blockId: DetailSearchBlockIds.overviewMethod,
        text: record.method,
      ),
      if ('${record.statusCode ?? ''} ${record.statusMessage ?? ''}'
          .trim()
          .isNotEmpty)
        DetailSearchBlock(
          tabIndex: 0,
          blockId: DetailSearchBlockIds.overviewStatus,
          text: '${record.statusCode ?? ''} ${record.statusMessage ?? ''}'
              .trim(),
        ),
      if (record.errorMessage != null)
        DetailSearchBlock(
          tabIndex: 0,
          blockId: DetailSearchBlockIds.overviewError,
          text: record.errorMessage!,
        ),
      if (record.authToken != null)
        DetailSearchBlock(
          tabIndex: 0,
          blockId: DetailSearchBlockIds.overviewToken,
          text: record.authToken!,
        ),
      if (record.queryParameters != null && record.queryParameters!.isNotEmpty)
        DetailSearchBlock(
          tabIndex: 1,
          blockId: DetailSearchBlockIds.requestQuery,
          text: record.queryParametersFormatted,
        ),
      if (record.requestBodyFormatted.isNotEmpty)
        DetailSearchBlock(
          tabIndex: 1,
          blockId: DetailSearchBlockIds.requestBody,
          text: record.requestBodyFormatted,
        ),
      if (record.responseBodyFormatted.isNotEmpty)
        DetailSearchBlock(
          tabIndex: 2,
          blockId: DetailSearchBlockIds.responseBody,
          text: record.responseBodyFormatted,
        ),
      DetailSearchBlock(
        tabIndex: 3,
        blockId: DetailSearchBlockIds.requestHeaders,
        text: record.requestHeadersFormatted,
      ),
      if (record.responseHeadersFormatted.isNotEmpty)
        DetailSearchBlock(
          tabIndex: 3,
          blockId: DetailSearchBlockIds.responseHeaders,
          text: record.responseHeadersFormatted,
        ),
    ];
  }

  static DetailSearchMatchInfo analyze(
    HttpRecordModel record,
    String query, {
    Set<int>? tabIndexes,
  }) {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      return DetailSearchMatchInfo(matches: const [], query: normalized);
    }

    final matches = <DetailSearchMatch>[];
    for (final block in blocksFor(record)) {
      if (tabIndexes != null && !tabIndexes.contains(block.tabIndex)) {
        continue;
      }
      final count = HttpRecordSearchUtils.countMatches(block.text, normalized);
      for (var i = 0; i < count; i++) {
        matches.add(
          DetailSearchMatch(
            globalIndex: matches.length,
            tabIndex: block.tabIndex,
            blockId: block.blockId,
          ),
        );
      }
    }

    return DetailSearchMatchInfo(matches: matches, query: normalized);
  }
}

/// Stable ids for searchable detail blocks.
abstract final class DetailSearchBlockIds {
  static const overviewUrl = 'overview.url';
  static const overviewMethod = 'overview.method';
  static const overviewStatus = 'overview.status';
  static const overviewError = 'overview.error';
  static const overviewToken = 'overview.token';
  static const requestQuery = 'request.query';
  static const requestBody = 'request.body';
  static const responseBody = 'response.body';
  static const requestHeaders = 'headers.request';
  static const responseHeaders = 'headers.response';
}

/// Navigation state passed into detail tabs for highlight + scroll.
class DetailSearchNavigation {
  final String query;
  final int activeGlobalIndex;
  final GlobalKey activeMatchKey;
  final DetailSearchMatchInfo matchInfo;

  const DetailSearchNavigation({
    required this.query,
    required this.activeGlobalIndex,
    required this.activeMatchKey,
    required this.matchInfo,
  });

  DetailSearchMatch? get activeMatch => matchInfo.matchAt(activeGlobalIndex);

  bool isActiveBlock(String blockId) => activeMatch?.blockId == blockId;

  int matchIndexOffset(String blockId) =>
      matchInfo.firstGlobalIndexForBlock(blockId) ?? 0;
}
