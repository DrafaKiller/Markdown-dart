class MarkdownToken {
  final RegExpMatch match;
  final int start;
  final int end;

  MarkdownToken(this.match, this.start, this.end);
}

class MarkdownMatch {
  final RegExpMatch token;
  final int offset;

  MarkdownMatch(this.token, this.offset);

  int get start => token.start + offset;
  int get end => token.end + offset;
}

class MarkdownDifference {
  final String common;
  final String text;
  final String input;

  int get atInput => input.length - common.length;
  int get atText => text.length - common.length;

  MarkdownDifference(this.input, this.text, this.common);
}