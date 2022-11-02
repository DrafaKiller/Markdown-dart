class MarkdownPattern {
  final RegExp start;
  final RegExp end;

  MarkdownPattern(this.start, [ RegExp? end ]) : this.end = end ?? start;

  MarkdownPattern.string(String start, [ String? end ])
    : this(RegExp(RegExp.escape(start)), end == null ? null : RegExp(RegExp.escape(end)));

  bool get symmetrical => start.pattern == end.pattern;
}