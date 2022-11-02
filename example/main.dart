import 'package:marked/marked.dart';
import 'package:marked/src/pattern.dart';

final markdown = Markdown({
  MarkdownPlaceholder(MarkdownPattern.string('*'), (text, match) => '<=$text=>'),
});

void main() {
  // print(markdown.apply('Hello /* 1 */ /* 2 */ /* 3 */!'));
  // print(markdown.apply('Hello /* /* /* 1 */ */ */!'));
  // print(markdown.apply('Hello /* /*1*/ /*2*/ /*3*/ */!'));

  print(markdown.apply('Hello *1* *2* *3*!'));
  print(markdown.apply('Hello ** *1* **!'));
  print(markdown.apply('Hello **1* *2* *3**!'));
}