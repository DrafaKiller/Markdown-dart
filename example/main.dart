import 'package:marked/marked.dart';

final markdown = Markdown.map({
  '**': (text, match) => '<b>$text</b>',
  '*': (text, match) => '<i>$text</i>',
  '__': (text, match) => '<u>$text</u>',
  '<custom>' : (text, match) => '<tag>$text</tag>',
}, {
  MarkdownPlaceholder.enclosed(
    'from here', end: 'to here',
    (text, match) => '[$text]'
  ),
});

void main() {
  print(
    markdown.apply('''
      Hello **World**!
      __Looks *pretty* easy__
      <custom>Custom tags</custom>
      from here ... do anything ... to here
    ''')
  );

  // Output:
  //   Hello <b>World</b>!
  //   <u>Looks <i>pretty</i> easy</u>
  //   <tag>Custom tags</tag>
  //   [ ... do anything ... ]
}