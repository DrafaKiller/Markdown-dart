class MarkdownPlaceholder {
  final String? name;
  final RegExp regex;
  final MarkdownReplace replace;

  MarkdownPlaceholder(this.regex, this.replace, { this.name });

  String apply(String text) => text.replaceAllMapped(regex, (match) => replace(match.group(1) ?? '', match));

  bool matches(String text) => regex.hasMatch(text);

  /* -= Alternatives =- */

  factory MarkdownPlaceholder.regexp(String pattern, MarkdownReplace replace, { String? name }) {
    return MarkdownPlaceholder(name: name, RegExp(pattern), replace);
  }

  factory MarkdownPlaceholder.enclosed(String start, MarkdownReplace replace, { String? name, String? end }) {
    start = RegExp.escape(start);
    end = end != null ? RegExp.escape(end) : start;
    return MarkdownPlaceholder.regexp(name: name, '$start(.+?)$end', replace);
  }

  factory MarkdownPlaceholder.tag(String tag, MarkdownReplace replace, { String? name }) {
    return MarkdownPlaceholder.enclosed(name: name, '<$tag>', end: '</$tag>', replace);
  }
}

/* -= Type Aliases =- */

typedef MarkdownReplace = String Function(String text, Match match);