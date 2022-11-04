import 'package:marked/marked.dart';

final markdown = Markdown.map({
  '[**]': (text, match) => '<b>$text</b>',
  '[*]': (text, match) => '<i>$text</i>',
  '[~~]': (text, match) => '<s>$text</s>',
  '<test p1|p2|p3>': (text, match) {
    print(match.tagProperties);
    return '<b>$text</b>';
  },
});

void main() {
  print(markdown.apply('Hello <test p1="test" p2="test2" p3>nice</test>!'));
}