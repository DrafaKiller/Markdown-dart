import 'package:marked/marked.dart';
import 'package:marked/src/placeholder.dart';

class Markdown {
  final Set<MarkdownPlaceholder> placeholders;

  Markdown(this.placeholders);

  String apply(String input) {
    for (final placeholder in placeholders) {
      input = placeholder.apply(input);
    }
    return input;
  }

  factory Markdown.map(Map<String, MarkdownReplace> map) {
    return Markdown(
      map.entries
        .map((entry) {
          final pattern = entry.key;
          final replace = entry.value;

          if (pattern.startsWith('/') && pattern.endsWith('/')) {
            return MarkdownPlaceholder(
              MarkdownPattern(RegExp(pattern.substring(1, pattern.length - 1))),
              replace
            );
          } else if (pattern.startsWith('r<') && pattern.endsWith('>')) {
            return MarkdownPlaceholder(
              MarkdownPlaceholder.pattern(),
              replace
            );
          }

          return MarkdownPlaceholder.pattern(entry.key, entry.value);
        }).toSet(),
    );
  }
}