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
    
  String apply(String input) {
    final nodes = _parseNested(input);
    if (nodes.isEmpty) return input;
    return _applyAll(nodes);
  }

  String _applyAll(List<MarkdownNode> nodes) {
    String result = '';
  
    for (final node in nodes) {
      final isLast = node == nodes.last;
      result += node.apply().substring(0, isLast ? null : node.end.end);
    }

    return result;
  }

  List<MarkdownNode> _parseNested(String input, [ int level = 0 ]) {
    final nested = <MarkdownNode>[];

    while (true) {
      final node = _parse(input, level);
      if (node == null) break;

      nested.add(node);
      input = input.substring(node.end.end);
    }

    return nested;
  }

  MarkdownNode? _parse(String input, [ int level = 0 ]) {
    final next = _nextLevel(input, level);
    if (next < level) return null; 

    final start = pattern.start.firstMatch(input);
    if (start == null) return null;
    
    final nested = _parseNested(input.substring(start.end), level + 1);
    final endNested = start.end + _endOfNested(nested);

    input = input.replaceRange(start.end, endNested, _applyAll(nested).substring(0, endNested - start.end));

    final end = pattern.end.firstMatch(input.substring(endNested));
    if (end == null) return null;

    return MarkdownNode(
      this,
      input,
      MarkdownToken(start, start.start, start.end),
      MarkdownToken(end, end.start + endNested, end.end + endNested),
      level,
    );
  }

  int _endOfNested(List<MarkdownNode> nodes) {
    int end = 0;
    for (final node in nodes) {
      end += node.end.end;
    }
    return end;
  }
  
  int _nextLevel(String input, int level) {
    final start = pattern.start.firstMatch(input);
    final end = pattern.end.firstMatch(input);

    if (pattern.symmetrical) {
      if (start == null) return level;
      if (level == 0) return level + 1;
      return level - 1;
      if (start.start == 0) return level + 1;
      return level - 1;
    }

    if (start == null && end == null) return level;
    if (start == null) return level - 1;
    if (end == null) return level + 1;
    if (start.start < end.start) return level + 1;
    return level - 1;
  }
}

/* -= Type Aliases =- */

typedef MarkdownReplace = String Function(String text, MarkdownNode match);
