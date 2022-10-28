import 'package:marked/marked.dart';

final htmlMarkdown = Markdown({
  MarkdownPlaceholder.enclosed('**', (text, match) => '<b>$text</b>'),
  MarkdownPlaceholder.enclosed('*', (text, match) => '<i>$text</i>'),
  MarkdownPlaceholder.enclosed('~~', (text, match) => '<strike>$text</strike>'),
  MarkdownPlaceholder.enclosed('`', (text, match) => '<code>$text</code>'),
});

void main() {
  print(htmlMarkdown.apply('HTML Markdown: **bold** *italic* ~~strike~~ `code`'));
  // [Output]
  // HTML Markdown: <b>bold</b> <i>italic</i> <strike>strike</strike> <code>code</code>
}
