import 'package:marked/marked.dart';

final htmlMarkdown = Markdown({
  MarkdownPlaceholder.enclosed(name: 'bold', '**', (text, match) => '<b>$text</b>'),
  MarkdownPlaceholder.enclosed(name: 'italic', '*', (text, match) => '<i>$text</i>'),
  MarkdownPlaceholder.enclosed(name: 'underline', '__', (text, match) => '<u>$text</u>'),
  MarkdownPlaceholder.enclosed(name: 'strike', '~~', (text, match) => '<strike>$text</strike>'),
  MarkdownPlaceholder.enclosed(name: 'code', '`', (text, match) => '<code>$text</code>'),
});

void main() {
  print(htmlMarkdown.apply('HTML Markdown: **bold** *italic* __underline__ ~~strike~~ `code`', { 'bold', 'italic' }));
  // [Output]
  // HTML Markdown: <b>bold</b> <i>italic</i> __underline__ ~~strike~~ <code>code</code>
}
