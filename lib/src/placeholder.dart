
import 'package:marked/src/error.dart';
import 'package:marked/src/node.dart';
import 'package:marked/src/pattern.dart';
import 'package:marked/src/schema.dart';

class MarkdownPlaceholder {
  final MarkdownPattern pattern;
  final MarkdownReplace replace;
  final bool strict;

  MarkdownPlaceholder(this.pattern, this.replace, { this.strict = false });

  MarkdownPlaceholder.pattern(String start, MarkdownReplace replace, { String? end })
    : this(MarkdownPattern.string(start, end), replace);
    
  String apply(String input) {
    final nodes = _parseNested(input);
    if (nodes.isEmpty) return input;
    return _applyAll(nodes, keepEnd: true);
  }

  String _applyAll(List<MarkdownNode> nodes, { bool keepEnd = false }) {
    String result = '';
  
    for (final node in nodes) {
      final isLast = node == nodes.last;
      result += node.apply().substring(0, isLast && keepEnd ? null : node.translate(node.end.end));
    }

    return result;
  }

  List<MarkdownNode> _parseNested(String input, [ int level = 0 ]) {
    final nested = <MarkdownNode>[];
    final original = input;

    while (true) {
      final node = _parse(input, level);
      if (node == null) break;

      nested.add(node);
      input = node.apply().substring(node.translate(node.end.end));
    }

    if (strict && level == 0) {
      final end = pattern.end.firstMatch(input);
      if (end != null) {
        throw MarkdownMissingTokenError(
          pattern,
          input: original,
          index: end.start + original.length - input.length,
          length: end.end - end.start,
          ending: false,
        );
      }
    }

    return nested;
  }

  MarkdownNode? _parse(String input, [ int level = 0 ]) {
    final next = _nextLevel(input, level);
    if (next < level) return null;

    final start = pattern.start.firstMatch(input);
    if (start == null) return null;

    final nested = _parseNested(input.substring(start.end), level + 1);
    int startEnd = start.end;

    final original = input;
    if (nested.isNotEmpty) {
      input = input.replaceRange(startEnd, null, _applyAll(nested, keepEnd: true));
      startEnd += _endOfNested(nested, translated: true);
    }
    
    final end = pattern.end.firstMatch(input.substring(startEnd));
    if (end == null) {
      if (strict) {
        throw MarkdownMissingTokenError(
          pattern,
          input: original,
          index: start.start,
          length: start.end - start.start,
          ending: true,
        );
      }
      
      if (nested.isEmpty) return null;
      final node = nested.first;
      return node.clone(
        input: original,
        start: MarkdownToken(node.start.match, node.start.start + start.end, node.start.end + start.end),
        end: MarkdownToken(node.end.match, node.end.start + start.end, node.end.end + start.end),
      );
    }

    return MarkdownNode(
      this,
      input,
      MarkdownToken(start, start.start, start.end),
      MarkdownToken(end, end.start + startEnd, end.end + startEnd),
      level,
    );
  }

  int _endOfNested(List<MarkdownNode> nodes, { bool translated = false }) {
    int end = 0;
    for (final node in nodes) {
      end += translated
        ? node.translate(node.end.end)
        : node.end.end;
    }
    return end;
  }
  
  int _nextLevel(String input, int level) {
    final start = pattern.start.firstMatch(input);
    final end = pattern.end.firstMatch(input);

    if (pattern.symmetrical) {
      if (start == null) return level;
      if (level == 0 || start.start == 0) return level + 1;
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
