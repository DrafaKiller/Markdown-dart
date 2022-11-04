import 'package:marked/src/error.dart';
import 'package:marked/src/node.dart';
import 'package:marked/src/pattern.dart';
import 'package:marked/src/schema.dart';

export 'package:marked/src/pattern.dart';

class MarkdownPlaceholder {
  final MarkdownPattern pattern;
  final MarkdownReplace replace;
  final bool strict;

  MarkdownPlaceholder(this.pattern, this.replace, { this.strict = false });
    
  String apply(String input) {
    final nodes = _parseAll(input);
    if (nodes.isEmpty) return input;

    if (strict) {
      final endIndex = MarkdownNode.endOfAll(nodes);
      if (_nextLevel(input.substring(endIndex)) < 0) {
        final end = pattern.end.firstMatch(input.substring(endIndex))!;

        throw MarkdownMissingTokenError(
          pattern,
          input: input,
          index: endIndex + end.start,
          length: end.end - end.start,
          ending: false,
        );
      }
    }

    return _applyAll(nodes);
  }

  String _applyAll(List<MarkdownNode> nodes) {
    String result = '';

    for (final node in nodes) {
      final isLast = node == nodes.last;
      result += node.apply().substring(0, isLast ? null : node.translate(node.end.end));
    }

    return result;
  }

  MarkdownNode? _parse(String input, [ int level = 0 ]) {
    final start = pattern.start.firstMatch(input);
    if (start == null) return null;

    final end = _findEnd(input.substring(start.end), level);
    if (end == null) {
      if (strict) {
        throw MarkdownMissingTokenError(
          pattern,
          input: input,
          index: start.start,
          length: start.end - start.start,
          ending: true,
        );
      }

      final node = _parse(input.substring(start.end), level + 1);
      if (node == null) return null;

      return node.clone(
        input: input,
        start: MarkdownToken(node.start.match, node.start.start + start.end, node.start.end + start.end),
        end: MarkdownToken(node.end.match, node.end.start + start.end, node.end.end + start.end),
      );
    }

    return MarkdownNode(
      this,
      input: input,
      start: MarkdownToken(start, start.start, start.end),
      end: MarkdownToken(end.match, start.end + end.start + end.match.start, start.end + end.start + end.match.end),
      level: level,
    );
  }

  List<MarkdownNode> _parseAll(String input, [ int level = 0 ]) {
    final nested = <MarkdownNode>[];
    while (true) {
      final node = _parse(input, level);
      if (node == null) break;
      nested.add(node);
      input = input.substring(node.end.end);
    }
    return nested;
  }
  
  int _nextLevel(String input, [ int level = 0 ]) {
    final start = pattern.start.firstMatch(input);
    final end = pattern.end.firstMatch(input);

    if (pattern.symmetrical) {
      if (start == null) return level;
      if (start.start == 0) return level + 1;
      return level - 1;
    }

    if (start == null && end == null) return level;
    if (start == null) return level - 1;
    if (end == null) return level + 1;
    if (start.start < end.start) return level + 1;
    return level - 1;
  }

  MarkdownMatch? _findEnd(String input, [ int level = 0 ]) {
    final next = _nextLevel(input, level);

    if (next == level) return null;
    if (next < level) {
      final end = pattern.end.firstMatch(input);
      if (end == null) return null;
      
      return MarkdownMatch(end, 0);
    }

    final start = pattern.start.firstMatch(input)!;
    final nextEnd = _findEnd(input.substring(start.end), level + 1);
    if (nextEnd == null) return null;

    final end = _findEnd(input.substring(start.end + nextEnd.start + nextEnd.match.end), level);
    if (end == null) return null;

    return MarkdownMatch(end.match, end.start + start.end + nextEnd.start + nextEnd.match.end);
  }

  /* -= Alternatives =- */

  factory MarkdownPlaceholder.enclosed(String start, MarkdownReplace replace, { String? end, bool strict = false }) {
    return MarkdownPlaceholder(
      MarkdownPattern.enclosed(start, end),
      replace,
      strict: strict,
    );
  }

  factory MarkdownPlaceholder.regexp(String start, MarkdownReplace replace, { String? end, bool strict = false }) {
    return MarkdownPlaceholder(
      MarkdownPattern.regexp(start, end),
      replace,
      strict: strict,
    );
  }

  factory MarkdownPlaceholder.tag(String start, MarkdownReplace replace, { String? end, Set<String> properties = const {}, bool strict = false }) {
    return MarkdownPlaceholder(
      MarkdownPattern.tag(start, end, properties),
      replace,
      strict: strict,
    );
  }
}

/* -= Type Aliases =- */

typedef MarkdownReplace = String Function(String text, MarkdownNode match);
