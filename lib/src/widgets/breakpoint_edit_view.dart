import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/network_monitor_controller.dart';
import '../l10n/nm_localizations.dart';
import '../models/breakpoint_edit_result.dart';
import '../models/http_record_model.dart';
import '../theme/nm_theme.dart';

/// Full-screen editor shown when a request or response hits a breakpoint.
class BreakpointEditView extends StatefulWidget {
  final String breakpointId;
  final NetworkMonitorController controller;

  const BreakpointEditView({
    super.key,
    required this.breakpointId,
    required this.controller,
  });

  static Future<void> show(
    BuildContext context, {
    required String breakpointId,
    required NetworkMonitorController controller,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BreakpointEditView(
          breakpointId: breakpointId,
          controller: controller,
        ),
      ),
    );
  }

  @override
  State<BreakpointEditView> createState() => _BreakpointEditViewState();
}

class _BreakpointEditViewState extends State<BreakpointEditView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _urlController;
  late TextEditingController _headersController;
  late TextEditingController _bodyController;
  bool _isResponse = false;
  HttpRecordModel? _record;

  @override
  void initState() {
    super.initState();
    _isResponse = widget.controller.isResponseBreakpoint(widget.breakpointId);
    _record = widget.controller.getPausedRecord(widget.breakpointId);
    _tabController = TabController(length: _isResponse ? 2 : 3, vsync: this);

    _urlController = TextEditingController(text: _record?.url ?? '');
    _headersController = TextEditingController(text: _formatInitialHeaders());
    _bodyController = TextEditingController(text: _formatInitialBody());
  }

  String _formatInitialHeaders() {
    if (_record == null) return '{}';
    final headers = _isResponse
        ? _record!.responseHeaders
        : _record!.requestHeaders;
    if (headers == null || headers.isEmpty) return '{}';
    try {
      return const JsonEncoder.withIndent('  ').convert(headers);
    } catch (_) {
      return headers.toString();
    }
  }

  String _formatInitialBody() {
    if (_record == null) return '';
    final body = _isResponse ? _record!.responseBody : _record!.requestBody;
    if (body == null) return '';
    try {
      if (body is Map || body is List) {
        return const JsonEncoder.withIndent('  ').convert(body);
      }
      final decoded = jsonDecode(body.toString());
      return const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {
      return body.toString();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    _headersController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.nmL10n;

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: NmTheme.surface(context),
        appBar: AppBar(
          title: Text(
            _isResponse ? l10n.editResponse : l10n.editRequest,
            style: NmTextStyles.bold18(
              context,
            ).copyWith(color: NmTheme.onSurface(context)),
          ),
          backgroundColor: NmTheme.surface(context),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: NmTheme.icon(context)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            TextButton.icon(
              onPressed: _cancelRequest,
              icon: Icon(Icons.cancel_outlined, color: Colors.red, size: 18),
              label: Text(
                l10n.cancel,
                style: NmTextStyles.bold14(context).copyWith(color: Colors.red),
              ),
            ),
            TextButton.icon(
              onPressed: _continueWithEdits,
              icon: Icon(Icons.play_arrow, color: Colors.green, size: 18),
              label: Text(
                l10n.continueAction,
                style: NmTextStyles.bold14(
                  context,
                ).copyWith(color: Colors.green),
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: NmTheme.primary(context),
            unselectedLabelColor: NmTheme.onSurfaceVariant(context),
            indicatorColor: NmTheme.primary(context),
            labelStyle: NmTextStyles.bold14(context),
            unselectedLabelStyle: NmTextStyles.medium14(context),
            tabs: [
              if (!_isResponse) Tab(text: l10n.url),
              Tab(text: l10n.headers),
              Tab(text: l10n.body),
            ],
          ),
        ),
        body: Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            children: [
              _InfoBanner(record: _record, isResponse: _isResponse),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    if (!_isResponse)
                      _EditorField(
                        controller: _urlController,
                        hintText: l10n.editUrlHint,
                        singleLine: true,
                      ),
                    _EditorField(
                      controller: _headersController,
                      hintText: l10n.editHeadersHint,
                    ),
                    _EditorField(
                      controller: _bodyController,
                      hintText: l10n.editBodyHint,
                    ),
                  ],
                ),
              ),
              _ActionBar(
                onContinueOriginal: _continueOriginal,
                onContinueWithEdits: _continueWithEdits,
                onCancel: _cancelRequest,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _continueOriginal() {
    widget.controller.continueBreakpoint(widget.breakpointId);
    Navigator.of(context).pop();
  }

  void _continueWithEdits() {
    Map<String, dynamic>? editedHeaders;
    String? editedBody;
    String? editedUrl;

    if (!_isResponse) {
      final urlText = _urlController.text.trim();
      if (urlText.isNotEmpty && urlText != (_record?.url ?? '')) {
        final uri = Uri.tryParse(urlText);
        if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.nmL10n.invalidUrl),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        editedUrl = urlText;
      }
    }

    final headersText = _headersController.text.trim();
    if (headersText.isNotEmpty && headersText != _formatInitialHeaders()) {
      try {
        final parsed = jsonDecode(headersText);
        if (parsed is Map) {
          editedHeaders = Map<String, dynamic>.from(parsed);
        }
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.nmL10n.invalidJsonInHeaders),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    final bodyText = _bodyController.text.trim();
    if (bodyText.isNotEmpty && bodyText != _formatInitialBody()) {
      editedBody = bodyText;
    }

    final result = BreakpointEditResult(
      action: BreakpointAction.continueRequest,
      editedHeaders: editedHeaders,
      editedBody: editedBody,
      editedUrl: editedUrl,
    );

    widget.controller.continueBreakpoint(widget.breakpointId, result: result);
    Navigator.of(context).pop();
  }

  void _cancelRequest() {
    widget.controller.cancelBreakpoint(widget.breakpointId);
    Navigator.of(context).pop();
  }
}

class _InfoBanner extends StatelessWidget {
  final HttpRecordModel? record;
  final bool isResponse;

  const _InfoBanner({required this.record, required this.isResponse});

  @override
  Widget build(BuildContext context) {
    if (record == null) return const SizedBox.shrink();

    final l10n = context.nmL10n;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.orange.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pause_circle_filled, color: Colors.orange, size: 16),
              SizedBox(width: 6),
              Text(
                isResponse ? l10n.responsePaused : l10n.requestPaused,
                style: NmTextStyles.bold12(
                  context,
                ).copyWith(color: Colors.orange),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            '${record!.method} ${record!.path}',
            style: NmTextStyles.medium12(
              context,
            ).copyWith(color: NmTheme.onSurface(context)),
          ),
          Text(
            record!.url,
            style: NmTextStyles.regular10(
              context,
            ).copyWith(color: NmTheme.onSurfaceVariant(context)),
          ),
        ],
      ),
    );
  }
}

class _EditorField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool singleLine;

  const _EditorField({
    required this.controller,
    required this.hintText,
    this.singleLine = false,
  });

  @override
  State<_EditorField> createState() => _EditorFieldState();
}

class _EditorFieldState extends State<_EditorField> {
  bool _isTableView = false;

  Map<String, dynamic>? get _parsedMap {
    try {
      final decoded = jsonDecode(widget.controller.text);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return null;
  }

  List? get _parsedList {
    try {
      final decoded = jsonDecode(widget.controller.text);
      if (decoded is List) return decoded;
    } catch (_) {}
    return null;
  }

  bool get _canShowTable => _parsedMap != null || _parsedList != null;

  @override
  Widget build(BuildContext context) {
    final l10n = context.nmL10n;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            if (_canShowTable && !widget.singleLine)
              Container(
                margin: EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => setState(() => _isTableView = false),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: !_isTableView
                              ? NmTheme.primary(context).withValues(alpha: 0.15)
                              : NmTheme.fieldBackground(context),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: !_isTableView
                                ? NmTheme.primary(context)
                                : NmTheme.border(context),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.code,
                              size: 14,
                              color: !_isTableView
                                  ? NmTheme.primary(context)
                                  : NmTheme.icon(context),
                            ),
                            SizedBox(width: 4),
                            Text(
                              l10n.rawJson,
                              style: NmTextStyles.bold12(context).copyWith(
                                color: !_isTableView
                                    ? NmTheme.primary(context)
                                    : NmTheme.onSurfaceVariant(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    InkWell(
                      onTap: () => setState(() => _isTableView = true),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _isTableView
                              ? NmTheme.primary(context).withValues(alpha: 0.15)
                              : NmTheme.fieldBackground(context),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _isTableView
                                ? NmTheme.primary(context)
                                : NmTheme.border(context),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.table_rows_rounded,
                              size: 14,
                              color: _isTableView
                                  ? NmTheme.primary(context)
                                  : NmTheme.icon(context),
                            ),
                            SizedBox(width: 4),
                            Text(
                              l10n.table,
                              style: NmTextStyles.bold12(context).copyWith(
                                color: _isTableView
                                    ? NmTheme.primary(context)
                                    : NmTheme.onSurfaceVariant(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: widget.singleLine
                  ? Container(
                      decoration: BoxDecoration(
                        color: NmTheme.fieldBackground(context),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: NmTheme.border(context)),
                      ),
                      child: TextField(
                        controller: widget.controller,
                        maxLines: 3,
                        minLines: 1,
                        textAlignVertical: TextAlignVertical.top,
                        keyboardType: TextInputType.url,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: NmTheme.onSurface(context),
                        ),
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          hintStyle: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: NmTheme.onSurfaceVariant(
                              context,
                            ).withValues(alpha: 0.5),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                          border: InputBorder.none,
                        ),
                      ),
                    )
                  : _isTableView && _canShowTable
                  ? _EditableTableView(
                      controller: widget.controller,
                      onChanged: () => setState(() {}),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: NmTheme.fieldBackground(context),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: NmTheme.border(context)),
                      ),
                      child: TextField(
                        controller: widget.controller,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: NmTheme.onSurface(context),
                        ),
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          hintStyle: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: NmTheme.onSurfaceVariant(
                              context,
                            ).withValues(alpha: 0.5),
                          ),
                          contentPadding: EdgeInsets.all(12),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditableTableView extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;

  const _EditableTableView({required this.controller, required this.onChanged});

  @override
  State<_EditableTableView> createState() => _EditableTableViewState();
}

class _EditableTableViewState extends State<_EditableTableView> {
  dynamic get _parsed {
    try {
      return jsonDecode(widget.controller.text);
    } catch (_) {
      return null;
    }
  }

  void _updateData(dynamic newData) {
    widget.controller.text = const JsonEncoder.withIndent(
      '  ',
    ).convert(newData);
    widget.onChanged();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.nmL10n;
    final data = _parsed;
    if (data == null) {
      return Center(
        child: Text(
          'Cannot parse as JSON',
          style: NmTextStyles.medium14(
            context,
          ).copyWith(color: NmTheme.onSurfaceVariant(context)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: NmTheme.fieldBackground(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: NmTheme.border(context)),
      ),
      child: ListView(
        padding: EdgeInsets.all(8),
        children: [
          if (data is Map<String, dynamic>)
            ...data.entries.map(
              (entry) => _EditableKeyValueRow(
                entryKey: entry.key,
                value: entry.value,
                depth: 0,
                onValueChanged: (newValue) {
                  final map = Map<String, dynamic>.from(data);
                  map[entry.key] = newValue;
                  _updateData(map);
                },
                onCopy: (text) {
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.copiedKey(entry.key)),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            )
          else if (data is List)
            ...data.asMap().entries.map(
              (entry) => _EditableKeyValueRow(
                entryKey: '[${entry.key}]',
                value: entry.value,
                depth: 0,
                onValueChanged: (newValue) {
                  final list = List.from(data);
                  list[entry.key] = newValue;
                  _updateData(list);
                },
                onCopy: (text) {
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.copiedKeyBracket(entry.key)),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _EditableKeyValueRow extends StatefulWidget {
  final String entryKey;
  final dynamic value;
  final int depth;
  final ValueChanged<dynamic> onValueChanged;
  final ValueChanged<String> onCopy;

  const _EditableKeyValueRow({
    required this.entryKey,
    required this.value,
    required this.depth,
    required this.onValueChanged,
    required this.onCopy,
  });

  @override
  State<_EditableKeyValueRow> createState() => _EditableKeyValueRowState();
}

class _EditableKeyValueRowState extends State<_EditableKeyValueRow> {
  bool _isExpanded = false;
  bool _isEditing = false;
  bool _showAsTable = true;
  late TextEditingController _editController;

  static const int _maxDepth = 5;

  bool get _isNestedJson => widget.value is Map<String, dynamic>;
  bool get _isNestedList => widget.value is List;
  bool get _isExpandable =>
      (_isNestedJson || _isNestedList) && widget.depth < _maxDepth;

  String get _displayValue {
    if (widget.value == null) return 'null';
    if (_isNestedJson) return '{${(widget.value as Map).length} keys}';
    if (_isNestedList) return '[${(widget.value as List).length} items]';
    return widget.value.toString();
  }

  String get _copyValue {
    if (widget.value == null) return 'null';
    if (_isNestedJson || _isNestedList) {
      return const JsonEncoder.withIndent('  ').convert(widget.value);
    }
    return widget.value.toString();
  }

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: _displayValue);
  }

  @override
  void didUpdateWidget(covariant _EditableKeyValueRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_isEditing) {
      _editController.text = _displayValue;
    }
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  void _saveEdit() {
    final text = _editController.text.trim();
    dynamic newValue;
    try {
      newValue = jsonDecode(text);
    } catch (_) {
      if (text == 'null') {
        newValue = null;
      } else if (text == 'true') {
        newValue = true;
      } else if (text == 'false') {
        newValue = false;
      } else if (int.tryParse(text) != null) {
        newValue = int.parse(text);
      } else if (double.tryParse(text) != null) {
        newValue = double.parse(text);
      } else {
        newValue = text;
      }
    }
    widget.onValueChanged(newValue);
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: NmTheme.border(context).withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_isExpandable)
                InkWell(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: NmTheme.icon(context),
                  ),
                ),
              Expanded(
                flex: 2,
                child: Text(
                  widget.entryKey,
                  style: NmTextStyles.bold12(
                    context,
                  ).copyWith(color: NmTheme.primary(context)),
                ),
              ),
              SizedBox(width: 4),
              if (!_isExpandable && _isEditing)
                Expanded(
                  flex: 4,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _editController,
                          autofocus: true,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: NmTheme.onSurface(context),
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                color: NmTheme.primary(context),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                color: NmTheme.primary(context),
                              ),
                            ),
                          ),
                          onSubmitted: (_) => _saveEdit(),
                        ),
                      ),
                      SizedBox(width: 4),
                      InkWell(
                        onTap: _saveEdit,
                        child: Icon(Icons.check, size: 16, color: Colors.green),
                      ),
                      SizedBox(width: 4),
                      InkWell(
                        onTap: () {
                          _editController.text = _displayValue;
                          setState(() => _isEditing = false);
                        },
                        child: Icon(Icons.close, size: 16, color: Colors.red),
                      ),
                    ],
                  ),
                )
              else
                Expanded(
                  flex: 4,
                  child: GestureDetector(
                    onTap: !_isExpandable
                        ? () => setState(() => _isEditing = true)
                        : null,
                    child: Text(
                      _displayValue,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: (_isNestedJson || _isNestedList)
                            ? NmTheme.onSurfaceVariant(context)
                            : NmTheme.onSurface(context),
                        fontStyle: (_isNestedJson || _isNestedList)
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              SizedBox(width: 4),
              if (_isExpandable && _isExpanded)
                InkWell(
                  onTap: () => setState(() => _showAsTable = !_showAsTable),
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: !_showAsTable
                          ? NmTheme.primary(context).withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      _showAsTable ? Icons.code : Icons.table_rows_rounded,
                      size: 14,
                      color: !_showAsTable
                          ? NmTheme.primary(context)
                          : NmTheme.icon(context),
                    ),
                  ),
                ),
              if (!_isEditing && !_isExpandable)
                InkWell(
                  onTap: () => setState(() => _isEditing = true),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: Icon(
                      Icons.edit,
                      size: 14,
                      color: NmTheme.icon(context),
                    ),
                  ),
                ),
              InkWell(
                onTap: () => widget.onCopy(_copyValue),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    Icons.copy,
                    size: 14,
                    color: NmTheme.icon(context),
                  ),
                ),
              ),
            ],
          ),
          if (_isExpandable && _isExpanded) ...[
            SizedBox(height: 6),
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(left: 8),
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: NmTheme.surface(context),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: NmTheme.border(context).withValues(alpha: 0.5),
                ),
              ),
              child: _showAsTable
                  ? _buildNestedTable()
                  : SelectableText(
                      const JsonEncoder.withIndent('  ').convert(widget.value),
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: NmTheme.onSurface(context),
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNestedTable() {
    if (_isNestedJson) {
      final map = widget.value as Map<String, dynamic>;
      return Column(
        children: map.entries
            .map(
              (entry) => _EditableKeyValueRow(
                entryKey: entry.key,
                value: entry.value,
                depth: widget.depth + 1,
                onValueChanged: (newValue) {
                  final updated = Map<String, dynamic>.from(map);
                  updated[entry.key] = newValue;
                  widget.onValueChanged(updated);
                },
                onCopy: (text) {
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.nmL10n.copiedKey(entry.key)),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            )
            .toList(),
      );
    }
    if (_isNestedList) {
      final list = widget.value as List;
      return Column(
        children: list
            .asMap()
            .entries
            .map(
              (entry) => _EditableKeyValueRow(
                entryKey: '[${entry.key}]',
                value: entry.value,
                depth: widget.depth + 1,
                onValueChanged: (newValue) {
                  final updated = List.from(list);
                  updated[entry.key] = newValue;
                  widget.onValueChanged(updated);
                },
                onCopy: (text) {
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.nmL10n.copiedKeyBracket(entry.key)),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            )
            .toList(),
      );
    }
    return const SizedBox.shrink();
  }
}

class _ActionBar extends StatelessWidget {
  final VoidCallback onContinueOriginal;
  final VoidCallback onContinueWithEdits;
  final VoidCallback onCancel;

  const _ActionBar({
    required this.onContinueOriginal,
    required this.onContinueWithEdits,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.nmL10n;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: NmTheme.surface(context),
        border: Border(top: BorderSide(color: NmTheme.border(context))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onContinueOriginal,
                icon: Icon(Icons.skip_next, size: 18),
                label: Text(
                  l10n.skipNoEdit,
                  style: NmTextStyles.bold12(context),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: NmTheme.onSurface(context),
                  side: BorderSide(color: NmTheme.border(context)),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onContinueWithEdits,
                icon: Icon(Icons.send, size: 18),
                label: Text(
                  l10n.applyAndContinue,
                  style: NmTextStyles.bold12(
                    context,
                  ).copyWith(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: NmTheme.primary(context),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
