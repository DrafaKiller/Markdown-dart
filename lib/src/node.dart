import 'package:marked/src/placeholder.dart';
import 'package:marked/src/symbol.dart';

class MarkdownNode {
  final MarkdownPlaceholder placeholder;
  final MarkdownSymbol start;
  final MarkdownSymbol end;
  final String input;
  final int level;

  String get text => input.substring(start.end, end.start);

  MarkdownNode(this.placeholder, this.input, this.start, this.end, this.level);

  String apply() {
    return input.replaceRange(start.start, end.end, placeholder.replace(text, this));
  }
}