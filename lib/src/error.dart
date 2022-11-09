class MarkdownMissingTokenError extends RangedIndicatorError {
  final bool? ending;

  MarkdownMissingTokenError({
    required super.input,
    required super.index,
    required super.length,
    this.ending
  }) : super.length(maxLength: 60, indent: 4);
  
  @override
  String toString() => '''
  Missing${
    ending == null ? '' : (ending! ? ' end' : ' start')
  } token to match '$target' at index $start, line ${ row } character ${ column }.
''' + super.toString();
}

/* -= Base Errors =- */

class RangedIndicatorError extends Error {
  final String input;
  final int start;
  final int end;
  final int minLength;
  final int maxLength;
  final int indent;

  int get length => end - start;
  String get target => input.substring(start, end);
  int get visibility => ((maxLength - length) / 2).clamp(minLength + 4, double.infinity).floor();
  
  RangedIndicatorError({
    required this.input,
    required this.start,
    required this.end,
    this.minLength = 10,
    this.maxLength = 50,
    this.indent = 0
  });

  RangedIndicatorError.length({
    required this.input,
    required int index,
    required int length,
    this.minLength = 10,
    this.maxLength = 50,
    this.indent = 0
  }) :
    start = index,
    end = index + length;

  factory RangedIndicatorError.find({
    required String input,
    required Pattern target,
    int minLength = 10,
    int maxLength = 50,
    int indent = 0
  }) {
    final match = target.allMatches(input).first;
    return RangedIndicatorError(
      input: input,
      start: match.start,
      end: match.end,
      maxLength: maxLength,
      indent: indent
    );
  }

  int get row => input.substring(0, start).split('\n').length;
  int get column => input.substring(0, start).split('\n').last.length;
  String get line => input.split('\n')[row - 1];

  @override
  String toString() {
    int index = column;
    int length = this.length;
    bool infinite = false;

    String startText = line.substring(0, index);
    if (startText.length > visibility) {
      index -= startText.length - visibility;
      startText = '... ' + startText.substring(startText.length - visibility + 4);
    }

    String endText = line.substring(column + length);
    String text = startText + target + endText;
    if (text.length > maxLength) {
      if (startText.length + length + 4 > maxLength) {
        infinite = true;
        length = maxLength - startText.length - 4;
      }
      text = text.substring(0, maxLength - 4) + ' ...';
    }

    return '''
${ ' ' * indent }$text
${ ' ' * indent }${ pointer(index, length, infinite) }''';
  }

  /* -= Static Methods =- */

  static pointer(int index, [ int length = 1, bool infinite = false ]) =>
    ' ' * index + '^' + (
      length > 1
        ? infinite
          ? '-' * (length - 1)
          : '-' * (length - 2) + '^'
        : '');
}
