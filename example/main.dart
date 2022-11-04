import 'package:marked/marked.dart';

final markdown = Markdown.map({}, {
  MarkdownPlaceholder.string('*', end: '*', (text, match) => '<b>$text</b>'),
});

void main() {
  markdown.placeholders.first.main();
}