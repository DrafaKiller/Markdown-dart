import 'package:marked/marked.dart';

class Markdown {
  final Set<MarkdownPlaceholder> placeholders;

  Markdown(this.placeholders);

  String apply(String input) {
    for (final placeholder in placeholders) {
      input = placeholder.apply(input);
    }
    return input;
  }
}