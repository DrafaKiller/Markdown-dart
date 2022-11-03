import 'package:marked/src/pattern.dart';

class MarkdownMissingTokenError extends Error {
  final MarkdownPattern pattern;
  final int index;
  final int length;
  final String input;
  final bool? ending;

  MarkdownMissingTokenError(this.pattern, {
    required this.input,
    required this.index,
    required this.length,
    this.ending
  });

  @override
  String toString() => '''
Missing${ ending == null ? '' : (ending! ? ' end' : ' start') } token to match '${ input.substring(index, index + length) }' at index $index.
  ${'${ ' ' * 10 }$input${ ' ' * 10 }'.substring(index, index + 20)}
            ^${ '^' * (length - 1) }''';
}