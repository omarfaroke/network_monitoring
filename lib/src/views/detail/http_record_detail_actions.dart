import 'package:flutter/material.dart';

import '../../l10n/nm_localizations.dart';
import '../../models/http_record_model.dart';
import '../../utils/nm_share.dart';
import '../../widgets/nm_clipboard.dart';

/// Copy and share actions for [NetworkMonitorDetailView].
abstract final class HttpRecordDetailActions {
  HttpRecordDetailActions._();

  static void handleMenuAction(BuildContext context, HttpRecordModel record, String action) {
    if (action == 'share_all') {
      nmShareContent(context, buildShareContent(context, record));
      return;
    }

    final content = _copyContent(record, action);
    if (content == null || content.isEmpty) return;

    NmClipboard.copyText(
      context,
      content,
      message: context.nmL10n.copiedToClipboard,
    );
  }

  static String? _copyContent(HttpRecordModel record, String action) {
    return switch (action) {
      'copy_url' => record.url,
      'copy_request_headers' => record.requestHeadersFormatted,
      'copy_request_body' => record.requestBodyFormatted,
      'copy_response_body' => record.responseBodyFormatted,
      'copy_token' => record.authToken,
      'copy_jwt_payload' => record.decodedAuthToken?.payloadFormatted,
      _ => null,
    };
  }

  static String buildShareContent(BuildContext context, HttpRecordModel record) {
    final l10n = context.nmL10n;
    final buffer = StringBuffer()
      ..writeln(l10n.shareApiRequestDetails)
      ..writeln('${l10n.url}: ${record.url}')
      ..writeln('${l10n.method}: ${record.method}')
      ..writeln('${l10n.status}: ${record.statusCode} ${record.statusMessage ?? ''}')
      ..writeln('${l10n.duration}: ${record.formattedDuration}')
      ..writeln('${l10n.startTime}: ${record.startTime}')
      ..writeln()
      ..writeln(l10n.shareRequestHeaders)
      ..writeln(record.requestHeadersFormatted)
      ..writeln();

    if (record.requestBody != null) {
      buffer
        ..writeln(l10n.shareRequestBody)
        ..writeln(record.requestBodyFormatted)
        ..writeln();
    }

    if (record.responseBody != null) {
      buffer
        ..writeln(l10n.shareResponseHeaders)
        ..writeln(record.responseHeadersFormatted)
        ..writeln()
        ..writeln(l10n.shareResponseBody)
        ..writeln(record.responseBodyFormatted);
    }

    return buffer.toString();
  }
}
