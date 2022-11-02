import 'package:marked/src/error.dart';
import 'package:marked/src/node.dart';
import 'package:marked/src/pattern.dart';
import 'package:marked/src/symbol.dart';

class MarkdownPlaceholder {
  final MarkdownPattern pattern;
  final MarkdownReplace replace;

  MarkdownPlaceholder(this.pattern, this.replace);

  MarkdownPlaceholder.pattern(String start, MarkdownReplace replace, { String? end })
    : this(MarkdownPattern.string(start, end), replace);

  String apply(String input, { int level = 0 }) {
    final node = _parse(input, level: level);
    if (node == null) {
      final next = pattern.start.firstMatch(input);
      if (next == null) return input;
      return input.replaceRange(next.end, null, apply(input.substring(next.end), level: level));
    }

    final text = node.apply();
    final difference = input.length - text.length;

    if (pattern.symmetrical && level > 0) {
      final post = pattern.end.firstMatch(input.substring(node.end.end));
      if (post != null) return text;
    }

    return text.replaceRange(node.end.end - difference, null, apply(text.substring(node.end.end - difference), level: level));
  }

  MarkdownNode? _parse(String input, { int level = 0 }) {
    final start = pattern.start.firstMatch(input);
    if (start == null) return null;
    final preEnd = pattern.end.firstMatch(input.substring(start.end));
    if (preEnd == null) return null;

    if (_isNextNested(input.substring(start.end), level: level)) {
      input = input.replaceRange(start.end, null, apply(input.substring(start.end), level: level + 1));
    }
    
    final end = pattern.end.firstMatch(input.substring(start.end));
    if (end == null) return null;

    return MarkdownNode(
      this,
      input,
      MarkdownSymbol(start, start.start, start.end),
      MarkdownSymbol(end, start.end + end.start, start.end + end.end),
      level
    );
  }

  bool _isNextNested(String input, { int level = 0 }) {
    final next = pattern.start.firstMatch(input);
    if (next == null) return false;

    final end = pattern.end.firstMatch(input);
    if (end == null) return false;

    if (pattern.symmetrical) {
      return next.start == 0;
    }
    return next.start < end.start;
  }
}

/* -= Type Aliases =- */

typedef MarkdownReplace = String Function(String text, MarkdownNode match);
