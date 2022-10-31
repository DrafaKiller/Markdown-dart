import 'package:marked/marked.dart';

final htmlMarkdown = Markdown({
  MarkdownPlaceholder.enclosed('**', (text, match) => '<b>$text</b>'),
  MarkdownPlaceholder.enclosed('*', (text, match) => '<i>$text</i>'),
  MarkdownPlaceholder.enclosed('__', (text, match) => '<u>$text</u>'),
  MarkdownPlaceholder.enclosed('~~', (text, match) => '<strike>$text</strike>'),
  MarkdownPlaceholder.enclosed('`', (text, match) => '<code>$text</code>'),
  MarkdownPlaceholder.regexp(
    r'\[(.+?)\]\((.+?)\)',
    (text, match) => '<a href="${ match.group(2)! }">$text</a>'
  ),
});


void main() {
  print(
    htmlMarkdown.apply('''
      HTML Markdown:
        **bold**
        *italic*
        __underline__
        ~~strike~~
        `code`
        [Example Title](https://example.com)

        __One **inside** another__
    ''')
  );

  // [Output]
  // HTML Markdown:
  //   <b>bold</b>
  //   <i>italic</i>
  //   <strike>strike</strike>
  //   <code>code</code>
  //   <a href="https://example.com">Example Title</a>
  //
  //   <u>One <b>inside</b> another</u>
}
