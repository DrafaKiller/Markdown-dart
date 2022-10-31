import 'package:marked/marked.dart';

final markdown = Markdown.map({
  '**': (text, match) => '<b>$text</b>',
});

void main() {
  print(
    markdown.apply('''
      Hello **World**!
      Hello \*World*!
      Hello \\*World*!
      Hello \\\*World*!

      * test  test *
    ''')
  );

  // Output:
  //   Hello <b>World</b>!
  //   Hello **World**!
}