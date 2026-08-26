/// A multi-line `{...}` or `[...]` range that can be folded like a code editor.
class JsonFoldRange {
  /// 0-based line that contains the opening `{` or `[`.
  final int startLine;

  /// 0-based line that contains the matching `}` or `]`.
  final int endLine;

  /// `'{'` or `'['`.
  final String openChar;

  const JsonFoldRange({
    required this.startLine,
    required this.endLine,
    required this.openChar,
  });

  String get collapsedPreview => openChar == '[' ? '[ ... ]' : '{ ... }';
}

/// One visible row after applying collapsed fold ranges.
class JsonFoldLine {
  /// 1-based original line number.
  final int number;

  final String text;
  final JsonFoldRange? foldRange;
  final bool isCollapsed;

  const JsonFoldLine({
    required this.number,
    required this.text,
    this.foldRange,
    this.isCollapsed = false,
  });
}

/// Computes VS Code-style fold ranges for pretty-printed JSON (or JSON-like) text.
abstract final class JsonFoldUtils {
  JsonFoldUtils._();

  static List<JsonFoldRange> rangesFor(String content) {
    final ranges = <JsonFoldRange>[];
    final stack = <({int line, String ch})>[];
    var line = 0;
    var inString = false;
    var escape = false;

    for (var i = 0; i < content.length; i++) {
      final c = content[i];
      if (c == '\n') {
        line++;
        escape = false;
        continue;
      }
      if (inString) {
        if (escape) {
          escape = false;
        } else if (c == '\\') {
          escape = true;
        } else if (c == '"') {
          inString = false;
        }
        continue;
      }
      if (c == '"') {
        inString = true;
        continue;
      }
      if (c == '{' || c == '[') {
        stack.add((line: line, ch: c));
      } else if (c == '}' || c == ']') {
        if (stack.isEmpty) continue;
        final open = stack.removeLast();
        final expected = c == '}' ? '{' : '[';
        if (open.ch != expected) continue;
        if (line > open.line) {
          ranges.add(
            JsonFoldRange(
              startLine: open.line,
              endLine: line,
              openChar: open.ch,
            ),
          );
        }
      }
    }
    return ranges;
  }

  static Map<int, JsonFoldRange> rangeByStartLine(List<JsonFoldRange> ranges) {
    return {for (final range in ranges) range.startLine: range};
  }

  static List<JsonFoldLine> visibleLines({
    required String content,
    required Set<int> collapsedStartLines,
    List<String>? rawLines,
    List<JsonFoldRange>? ranges,
  }) {
    return visibleLinesFrom(
      rawLines: rawLines ?? content.split('\n'),
      ranges: ranges ?? rangesFor(content),
      collapsedStartLines: collapsedStartLines,
    );
  }

  static List<JsonFoldLine> visibleLinesFrom({
    required List<String> rawLines,
    required List<JsonFoldRange> ranges,
    required Set<int> collapsedStartLines,
  }) {
    final byStart = rangeByStartLine(ranges);
    final visible = <JsonFoldLine>[];
    var skipUntil = -1;

    for (var i = 0; i < rawLines.length; i++) {
      if (i <= skipUntil) continue;
      final range = byStart[i];
      final collapsed =
          range != null && collapsedStartLines.contains(range.startLine);
      visible.add(
        JsonFoldLine(
          number: i + 1,
          text: collapsed
              ? _collapseStartLine(rawLines[i], range.openChar)
              : rawLines[i],
          foldRange: range,
          isCollapsed: collapsed,
        ),
      );
      if (collapsed) skipUntil = range.endLine;
    }
    return visible;
  }

  static String _collapseStartLine(String line, String openChar) {
    final idx = _lastUnquoted(line, openChar);
    final preview = openChar == '[' ? '[ ... ]' : '{ ... }';
    if (idx < 0) return '$line $preview';
    return '${line.substring(0, idx)}$preview';
  }

  static int _lastUnquoted(String line, String needle) {
    var inString = false;
    var escape = false;
    var last = -1;
    for (var i = 0; i < line.length; i++) {
      final c = line[i];
      if (inString) {
        if (escape) {
          escape = false;
        } else if (c == '\\') {
          escape = true;
        } else if (c == '"') {
          inString = false;
        }
        continue;
      }
      if (c == '"') {
        inString = true;
        continue;
      }
      if (c == needle) last = i;
    }
    return last;
  }
}
