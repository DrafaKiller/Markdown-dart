import 'package:marked/src/pattern.dart';

class MarkdownMissingTokenError extends Error {
  final int index;
  final int length;
  final String input;
  final bool? ending;

  MarkdownMissingTokenError({
    required this.input,
    required this.index,
    required this.length,
    this.ending
  });

  int get lineIndex => input.substring(0, index).split('\n').length;
  int get columnIndex => input.substring(0, index).split('\n').last.length;
  String get line => input.split('\n')[lineIndex - 1];

  @override
  String toString() => '''
  Missing${
    ending == null ? '' : (ending! ? ' end' : ' start')
  } token to match '${
    input.substring(index, index + length)
  }' at index $index, line ${ lineIndex } character ${ columnIndex }.
  ${ (' ' * 8 + '> ' + line + ' <' + ' ' * 8).substring(columnIndex, columnIndex + 20) }
  ${ ' ' * (columnIndex + (10 - columnIndex)) }^''';
}