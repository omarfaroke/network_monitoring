import 'dart:async';

import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../controllers/network_monitor_controller.dart';
import '../l10n/nm_localizations.dart';
import '../models/http_record_model.dart';
import '../network_monitoring_registry.dart';

/// Dio interceptor that records traffic and applies breakpoints when monitoring is on.
///
/// Register via [NetworkMonitoring.createInterceptor] and add it **last** on
/// [Dio.interceptors] so the monitor sees the final outgoing request.
class NetworkMonitorInterceptor extends Interceptor {
  static const _uuid = Uuid();
  static const _requestIdKey = 'network_monitor_request_id';
  static const _startTimeKey = 'network_monitor_start_time';

  final NetworkMonitorController _controller;

  NetworkMonitorInterceptor(this._controller);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!NetworkMonitoringRegistry.config.enabled ||
        !_controller.isMonitoringEnabled) {
      handler.next(options);
      return;
    }

    final requestId = _uuid.v4();
    final startTime = DateTime.now();

    options.extra[_requestIdKey] = requestId;
    options.extra[_startTimeKey] = startTime.millisecondsSinceEpoch;

    final record = HttpRecordModel(
      id: requestId,
      startTime: startTime,
      method: options.method,
      url: options.uri.toString(),
      baseUrl: options.baseUrl,
      path: options.path,
      requestHeaders: Map<String, dynamic>.from(options.headers),
      queryParameters: options.queryParameters.isNotEmpty
          ? Map<String, dynamic>.from(options.queryParameters)
          : null,
      requestBody: _extractBody(options.data),
      status: HttpRecordStatus.pending,
    );

    _controller.addRecord(record);

    if (_controller.shouldBreakOnRequest(options.uri.toString())) {
      final result = await _controller.waitForBreakpoint(requestId);

      if (result.isCancelled) {
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.cancel,
            message: nmL10nFromRegistry.requestCancelledByBreakpoint,
          ),
        );
        record.status = HttpRecordStatus.cancelled;
        record.errorMessage = nmL10nFromRegistry.cancelledByBreakpoint;
        record.endTime = DateTime.now();
        record.duration = record.endTime!.difference(record.startTime);
        _controller.updateRecord(requestId, record);
        return;
      }

      if (result.hasEdits) {
        if (result.editedHeaders != null) {
          options.headers.clear();
          options.headers.addAll(result.editedHeaders!);
          record.requestHeaders
            ..clear()
            ..addAll(result.editedHeaders!);
        }
        if (result.editedBody != null) {
          options.data = result.parsedBody;
          record.requestBody = result.parsedBody;
        }
        _controller.updateRecord(requestId, record);
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    if (!NetworkMonitoringRegistry.config.enabled ||
        !_controller.isMonitoringEnabled) {
      handler.next(response);
      return;
    }

    final requestId = response.requestOptions.extra[_requestIdKey] as String?;
    final startTimeMs =
        response.requestOptions.extra[_startTimeKey] as int?;

    if (requestId != null) {
      final endTime = DateTime.now();
      final duration = startTimeMs != null
          ? endTime.difference(
              DateTime.fromMillisecondsSinceEpoch(startTimeMs))
          : null;

      final records = _controller.records;
      final existingIndex = records.indexWhere((r) => r.id == requestId);

      if (existingIndex != -1) {
        final existing = records[existingIndex];
        existing.endTime = endTime;
        existing.duration = duration;
        existing.statusCode = response.statusCode;
        existing.statusMessage = response.statusMessage;
        existing.responseHeaders = _extractHeaders(response.headers);
        existing.responseBody = response.data;
        existing.status = HttpRecordStatus.success;
        _controller.updateRecord(requestId, existing);
      }

      if (_controller.shouldBreakOnResponse(
          response.requestOptions.uri.toString())) {
        final result = await _controller.waitForBreakpoint('res_$requestId');

        if (result.isCancelled) {
          handler.next(response);
          return;
        }

        if (result.hasEdits) {
          if (result.editedBody != null) {
            response.data = result.parsedBody;
            if (existingIndex != -1) {
              final existing = records[existingIndex];
              existing.responseBody = result.parsedBody;
              _controller.updateRecord(requestId, existing);
            }
          }
          if (result.editedHeaders != null) {
            if (existingIndex != -1) {
              final existing = records[existingIndex];
              existing.responseHeaders = result.editedHeaders;
              _controller.updateRecord(requestId, existing);
            }
          }
        }
      }
    }

    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!NetworkMonitoringRegistry.config.enabled ||
        !_controller.isMonitoringEnabled) {
      handler.next(err);
      return;
    }

    final requestId = err.requestOptions.extra[_requestIdKey] as String?;
    final startTimeMs = err.requestOptions.extra[_startTimeKey] as int?;

    if (requestId != null) {
      final endTime = DateTime.now();
      final duration = startTimeMs != null
          ? endTime.difference(
              DateTime.fromMillisecondsSinceEpoch(startTimeMs))
          : null;

      final records = _controller.records;
      final existingIndex = records.indexWhere((r) => r.id == requestId);

      if (existingIndex != -1) {
        final existing = records[existingIndex];
        existing.endTime = endTime;
        existing.duration = duration;
        existing.statusCode = err.response?.statusCode;
        existing.statusMessage = err.response?.statusMessage;
        existing.responseHeaders = err.response != null
            ? _extractHeaders(err.response!.headers)
            : null;
        existing.responseBody = err.response?.data;
        existing.status = HttpRecordStatus.error;
        existing.errorMessage = err.message ?? err.type.name;
        _controller.updateRecord(requestId, existing);
      }
    }

    handler.next(err);
  }

  dynamic _extractBody(dynamic data) {
    if (data == null) return null;
    if (data is FormData) {
      final map = <String, dynamic>{};
      for (final field in data.fields) {
        map[field.key] = field.value;
      }
      for (final file in data.files) {
        map[file.key] = '[File: ${file.value.filename}]';
      }
      return map;
    }
    return data;
  }

  Map<String, dynamic> _extractHeaders(Headers headers) {
    final map = <String, dynamic>{};
    headers.forEach((name, values) {
      map[name] = values.length == 1 ? values.first : values;
    });
    return map;
  }
}
