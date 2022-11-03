import 'package:marked/src/placeholder.dart';
import 'package:marked/src/schema.dart';

class MarkdownNode {
  final MarkdownPlaceholder placeholder;
  final MarkdownToken open;
  final MarkdownToken close;
  final String input;
  final int level;

  String? _cachedApply;

  String get text => input.substring(open.end, close.start);

  MarkdownNode(this.placeholder, {
    required this.input,
    required this.open,
    required this.close,
    required this.level
  });

  String apply() {
    if (_cachedApply != null) return _cachedApply!;
    _cachedApply = input.replaceRange(open.start, close.end, placeholder.replace(placeholder.apply(text), this));
    return _cachedApply!;
  }

  int translate(int index) {
    return apply().length - input.length + index;
  }

  MarkdownNode clone({
    MarkdownPlaceholder? placeholder,
    MarkdownToken? open,
    MarkdownToken? close,
    String? input,
    int? level,
  }) => MarkdownNode(
      placeholder ?? this.placeholder,
      input: input ?? this.input,
      open: open ?? this.open,
      close: close ?? this.close,
      level: level ?? this.level,
    );

  static int endOfAll(List<MarkdownNode> nodes, { bool translated = false }) {
    int index = 0;
    for (final node in nodes) {
      index += translated
        ? node.translate(node.close.end)
        : node.close.end;
    }
    return index;
  }
}