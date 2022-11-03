class MarkdownPattern {
  final RegExp start;
  final RegExp end;

  MarkdownPattern(this.start, [ RegExp? end ]) : this.end = end ?? RegExp('');

  bool get symmetrical => start.pattern == end.pattern;
  bool get singleToken => end.pattern.isEmpty;

  /* -= Alternatives =- */

  factory MarkdownPattern.regexp(String start, [ String? end ]) =>
    MarkdownPattern(RegExp(start), end == null ? null : RegExp(end));

  factory MarkdownPattern.string(String start, [ String? end ]) =>
    MarkdownPattern.regexp(
      RegExp.escape(start),
      end == null ? null : RegExp.escape(end)
    );

  factory MarkdownPattern.enclosed(String start, [ String? end ]) {
    return MarkdownPattern.string(
      start,
      end ?? start,
    );
  }

  factory MarkdownPattern.tag(String start, [ String? end ]) {
    start = RegExp.escape(start)
      .replaceAll(r'\.\.\.', r'.+?')
      .replaceAllMapped(RegExp(r'\\\\d(?:\\([\*\+]))?'), (match) => r'\d' + (match.group(1) ?? ''));

    end = end == null ? start : RegExp.escape(end)
      .replaceAll(r'\.\.\.', r'.+?')
      .replaceAllMapped(RegExp(r'\\\\d(?:\\([\*\+]))?'), (match) => r'\d' + (match.group(1) ?? ''));

    return MarkdownPattern.regexp(
      '<$start>',
      '<\\/${ end }>',
    );
  }

  factory MarkdownPattern.tagWithProperties(String tag) {
    return MarkdownPattern.regexp(
      '<$tag(?:\\s+[^\\>]+)?>',
      '<\\/$tag>',
    );
  }
}

void main() {
  print(MarkdownPattern.tag(r'rgb(\d+)').end.pattern);

}