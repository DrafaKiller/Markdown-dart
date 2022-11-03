import 'package:marked/src/placeholder.dart';
import 'package:marked/src/schema.dart';

class MarkdownNode {
  final MarkdownPlaceholder placeholder;
  final MarkdownToken start;
  final MarkdownToken end;
  final String input;
  final int level;

  String? _cachedApply;

  String get text => input.substring(start.end, end.start);

  MarkdownNode(this.placeholder, this.input, this.start, this.end, this.level);

  String apply() {
    if (_cachedApply != null) return _cachedApply!;
    _cachedApply = input.replaceRange(start.start, end.end, placeholder.replace(text, this));
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
      input ?? this.input,
      start ?? this.start,
      end ?? this.end,
      level ?? this.level,
    );
}