import 'dart:convert';

import 'package:marked/marked.dart';
import 'package:marked/src/pattern.dart';

final markdown = Markdown({
  MarkdownPlaceholder(MarkdownPattern.string('*'), (text, match) => '<i>$text</i>'),
  MarkdownPlaceholder(MarkdownPattern.string('**'), (text, match) => '<b>$text</b>'),
});

void main() {
  print(markdown.apply('Hello ***123***!'));
}