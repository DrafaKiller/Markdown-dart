class MarkdownSymbol {
  final Match match;
  final int start;
  final int end;

  MarkdownSymbol(this.match, this.start, this.end);
}

class MarkdownDifference {
  final String common;
  final String text;
  final String input;

  int get atInput => input.length - common.length;
  int get atText => text.length - common.length;

  MarkdownDifference(this.input, this.text, this.common);
}