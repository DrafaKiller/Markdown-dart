class MarkdownToken {
  final Match match;
  final int start;
  final int end;

  MarkdownToken(this.match, this.start, this.end);
}

class MarkdownMatch {
  final Match match;
  final int start;

  MarkdownMatch(this.match, this.start);
}

class MarkdownDifference {
  final String common;
  final String text;
  final String input;

  int get atInput => input.length - common.length;
  int get atText => text.length - common.length;

  MarkdownDifference(this.input, this.text, this.common);
}