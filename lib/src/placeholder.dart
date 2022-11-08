import 'package:marked/src/error.dart';
import 'package:marked/src/node.dart';
import 'package:marked/src/pattern.dart';
import 'package:marked/src/schema.dart';

export 'package:marked/src/pattern.dart';

class MarkdownPlaceholder {
  /// Pattern to be matched in the input, when applying.
  final MarkdownPattern pattern;

  /// Method to be called when an instance of the pattern is matched.
  /// 
  /// The result of this method will be used to replace the match.
  final MarkdownReplace replace;

  /// If set to `true`, the placeholder will throw an exception when parsing if
  /// an instance of the pattern is missing a start or end token.
  /// 
  /// If set to `false`, the placeholder will ignore the missing token and leave it as is.
  final bool strict;

  MarkdownPlaceholder(this.pattern, this.replace, { this.strict = false });
  
  /// Apply the placeholder to an input. It will parse the input and apply the replace method to all instances of the pattern.
  String apply(String input, { int level = 0 }) {
    final nodes = _parseAll(input, level);
    if (nodes.isEmpty) return input;

    if (strict) {
      final endIndex = MarkdownNode.endOfAll(nodes);
      if ((pattern.nextLevel(input.substring(endIndex), level) ?? level) < 0) {
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

    final result = _applyAll(nodes);
    return pattern.unescape(result);
  }

  String _applyAll(List<MarkdownNode> nodes) {
    String result = '';

    for (final node in nodes) {
      final isLast = node == nodes.last;
      result += node.apply().substring(0, isLast ? null : node.translate(node.end.end));
    }

    return result;
  }

  MarkdownNode? _parse(String input, [ int level = 0, bool levelIncreased = false ]) {
    final start = pattern.escapedStart.firstMatch(input);
    if (start == null) return null;

    final end = pattern.findEnd(input.substring(start.end), level: level + 1);

    if (end != null) {
      return MarkdownNode(
        this,
        input: input,
        start: MarkdownToken(start, start.start, start.end),
        end: MarkdownToken(end.token, start.end + end.offset + end.token.start, start.end + end.offset + end.token.end),
        level: level,
      );
    }

    if (strict) {
      throw MarkdownMissingTokenError(
        pattern,
        input: input,
        index: start.start,
        length: start.end - start.start,
        ending: true,
      );
    }

    final node = _parse(input.substring(start.end), level, true);
    if (node == null) return null;

    return node.clone(
      input: input,
      start: MarkdownToken(node.start.match, node.start.start + start.end, node.start.end + start.end),
      end: MarkdownToken(node.end.match, node.end.start + start.end, node.end.end + start.end),
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

  /* -= Alternatives =- */

  /// A markdown placeholder with an [string pattern](https://pub.dev/documentation/marked/latest/marked/MarkdownPattern/string.html).
  factory MarkdownPlaceholder.string(
    String start,
    MarkdownReplace replace,
    { String? end, bool strict = false }
  ) {
    return MarkdownPlaceholder(
      MarkdownPattern.string(start, end),
      replace,
      strict: strict,
    );
  }

  /// A markdown placeholder with an [enclosed pattern](https://pub.dev/documentation/marked/latest/marked/MarkdownPattern/MarkdownPattern.enclosed.html).
  factory MarkdownPlaceholder.enclosed(
    String start,
    MarkdownReplace replace,
    { String? end, bool strict = false }
  ) {
    return MarkdownPlaceholder(
      MarkdownPattern.enclosed(start, end),
      replace,
      strict: strict,
    );
  }

  /// A markdown placeholder with a [regexp pattern](https://pub.dev/documentation/marked/latest/marked/MarkdownPattern/MarkdownPattern.regexp.html).
  factory MarkdownPlaceholder.regexp(
    String start,
    MarkdownReplace replace,
    { String? end, bool strict = false }
  ) {
    return MarkdownPlaceholder(
      MarkdownPattern.regexp(start, end),
      replace,
      strict: strict,
    );
  }

  /// A markdown placeholder with a [tag pattern](https://pub.dev/documentation/marked/latest/marked/MarkdownPattern/MarkdownPattern.tag.html).
  factory MarkdownPlaceholder.tag(
    String start,
    MarkdownReplace replace,
    { String? end, Set<String> properties = const {}, bool strict = false }
  ) {
    return MarkdownPlaceholder(
      MarkdownPattern.tag(start, end, properties),
      replace,
      strict: strict,
    );
  }

  /// A markdown placeholder with a [symmetrical pattern](https://pub.dev/documentation/marked/latest/marked/MarkdownPattern/MarkdownPattern.symmetrical.html).
  factory MarkdownPlaceholder.symmetrical(
    String start,
    MarkdownReplace replace,
    { bool nested = true, bool sticky = false, bool strict = false }
  ) {
    return MarkdownPlaceholder(
      MarkdownPattern.symmetrical(start, nested: nested, sticky: sticky),
      replace,
      strict: strict,
    );
  }
}

/* -= Type Aliases =- */

typedef MarkdownReplace = String Function(String text, MarkdownNode match);
