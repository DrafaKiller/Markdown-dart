import 'dart:math' as math;

import 'package:marked/src/node.dart';
import 'package:marked/src/pattern.dart';
import 'package:marked/src/schema.dart';

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
    final end = node.translate(node.end.end);

    return text.replaceRange(end, null, apply(text.substring(end), level: level));
  }

  MarkdownNode? _parse(String input, { int level = 0 }) {
    final start = pattern.start.firstMatch(input);
    if (start == null) return null;

    if (_nextLevel(input.substring(start.end), level: level) > level) {
      input = input.replaceRange(start.end, null, apply(input.substring(start.end), level: level + 1));
    }

    final end = pattern.end.firstMatch(input.substring(start.end));
    if (end == null) return null;

    if (pattern.symmetrical && start.end == start.end + end.start) {
      return null;
    }

    return MarkdownNode(
      this,
      input,
      MarkdownSymbol(start, start.start, start.end),
      MarkdownSymbol(end, start.end + end.start, start.end + end.end),
      level
    );
  }

  int _nextLevel(String input, { int level = 0 }) {
    final next = pattern.start.firstMatch(input);
    if (next == null) return level;

    final end = pattern.end.firstMatch(input);
    if (end == null) return level;

    if (pattern.symmetrical && next.start == 0) return level + 1;
    return level + (next.start < end.start ? 1 : 0);
  }
}

/* -= Type Aliases =- */

typedef MarkdownReplace = String Function(String text, MarkdownNode match);
