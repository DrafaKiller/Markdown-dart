import 'package:marked/marked.dart';

final markdown = Markdown.map({
  '**': (text, match) => '<b>$text</b>',
  '[*]': (text, match) => '<i>$text</i>',
  '<tag>': (text, match) => '<other>$text</other>',
  '/from here(.*?)to here/': (text, match) => '[$text]'
}, {
  MarkdownPlaceholder.enclosed('/*', end: '*/', (text, match) => '<comment>$text</comment>'),
});

void main() {
  print(
    markdown.apply('''
      This is a **bold** text.
      This is a sticky *token*.
       > Doesn't work like * this *, unlike ** the bold **.
      This is a <tag>text</tag>.
      This is a text from here ... something else ... to here.
      This is extra customizable /* comment */.
      This is nested /* a /* b */ a */.
      This is also nested ***bold and italic***.
    ''')
  );

  // Output:
  // This is a <b>bold</b> text.
  // This is a sticky <i>text</i>.
  //  > Doesn't work like * this *, unlike <b> the bold </b>.
  // This is a <other>text</other>.
  // This is a text [ ... something else ... ].
  // This is extra customizable <comment> comment </comment>.
  // This is nested <comment> a <comment> b </comment> a </comment>.
  // This is also nested <i><b>bold and italic</b></i>.
}