import 'package:marked/src/placeholder.dart';
import 'package:marked/src/schema.dart';

class MarkdownNode {
  final MarkdownPlaceholder placeholder;
  final MarkdownToken start;
  final MarkdownToken end;
  final String input;
  final int level;

  String? _cachedApply;

  String get text {
    return placeholder.pattern.singleToken
      ? (start.match.groupCount > 0 ? start.match.group(1) ?? '' : '')
      : input.substring(start.end, end.start);
  }

  String get startText => start.match.group(0)!;
  String get endText => end.match.group(0)!;

  Map<String, String> get tagProperties => MarkdownPattern.getPropertiesOfTag(startText);

  MarkdownNode(this.placeholder, {
    required this.input,
    required this.start,
    required this.end,
    required this.level
  });

  String apply() {
    if (_cachedApply != null) return _cachedApply!;
    _cachedApply = input.replaceRange(start.start, end.end, placeholder.replace(placeholder.apply(text, level: level), this));
    return _cachedApply!;
  }

  int translate(int index) {
    return apply().length - input.length + index;
  }

  MarkdownNode clone({
    MarkdownPlaceholder? placeholder,
    MarkdownToken? start,
    MarkdownToken? end,
    String? input,
    int? level,
  }) => MarkdownNode(
      placeholder ?? this.placeholder,
      input: input ?? this.input,
      start: start ?? this.start,
      end: end ?? this.end,
      level: level ?? this.level,
    );

  static int endOfAll(List<MarkdownNode> nodes, { bool translated = false }) {
    int index = 0;
    for (final node in nodes) {
      index += translated
        ? node.translate(node.end.end)
        : node.end.end;
    }
    return index;
  }
}