import 'package:marked/marked.dart';

final htmlMarkdown = Markdown({
  MarkdownPlaceholder.enclosed(name: 'bold', '**', (text, match) => '<b>$text</b>'),
  MarkdownPlaceholder.enclosed(name: 'italic', '*', (text, match) => '<i>$text</i>'),
  MarkdownPlaceholder.enclosed(name: 'strike', '~~', (text, match) => '<strike>$text</strike>'),
  MarkdownPlaceholder.enclosed(name: 'code', '`', (text, match) => '<code>$text</code>'),
});

void main() {
  print(htmlMarkdown.apply('HTML Markdown: **bold** *italic* ~~strike~~ `code`', name: 'bold'));
  // [Output]
  // HTML Markdown: <b>bold</b> *italic* ~~strike~~ `code`
}
