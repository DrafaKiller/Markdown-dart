import 'package:marked/src/pattern.dart';

class MarkdownExpectedEndError extends Error {
  final MarkdownPattern pattern;
  final int index;
  final String input;

  MarkdownExpectedEndError(this.pattern, this.index, this.input);

  @override
  String toString() => '''
Expected end token matching expression "${pattern.end.pattern}", to end token at $index
  ${'${ ' ' * 10 }$input${ ' ' * 10 }'.substring(index, index + 20)}
            ^''';
}