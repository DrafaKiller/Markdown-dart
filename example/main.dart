import 'package:marked/marked.dart';
import 'package:marked/src/pattern.dart';

final markdown = Markdown({
  // MarkdownPlaceholder(MarkdownPattern(RegExp(r'(?:\*(?=\S)|(?<=\S)\*)')), (text, match) => '<=$text=>'),
  MarkdownPlaceholder(MarkdownPattern(RegExp(r'\*')), (text, match) => '<=$text=>'),
});

void main() {
  print(markdown.apply('Hello *okay* !'));
}