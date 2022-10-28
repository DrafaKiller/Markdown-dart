import 'package:marked/marked.dart';

final htmlMarkdown = Markdown.map({
  '**': (text, match) => '<b>$text</b>',
  '*': (text, match) => '<i>$text</i>',
  '__': (text, match) => '<u>$text</u>',
  '~~': (text, match) => '<strike>$text</strike>',
  '`': (text, match) => '<code>$text</code>',
  r'\[(.+?)\]\((.+?)\)': (text, match) => '<a href="${ match.group(1)! }">${ match.group(2)! }</a>',
  '<strong>': (text, match) => '<b>$text</b>',
});

void main() {
  print(htmlMarkdown.apply('''
    HTML Markdown:
      **bold**
      *italic*
      __underline__
      ~~strike~~
      `code`
      [https://example.com](Example Title)
      <strong>bold</strong>
  '''));

  // [Output]
  // HTML Markdown:
  //   <b>bold</b>
  //   <i>italic</i>
  //   <strike>strike</strike>
  //   <code>code</code>
  //   <a href="https://example.com">Example Title</a>
  //   <b>bold</b>
}