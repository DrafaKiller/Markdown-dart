class MarkdownPlaceholder {
  final String? name;
  final RegExp regex;
  final MarkdownReplace replace;

  MarkdownPlaceholder(this.regex, this.replace, { this.name });

  String apply(String text) => text.replaceAllMapped(regex, (match) => replace(match.group(1) ?? '', match));

  /* -= Alternatives =- */

  factory MarkdownPlaceholder.enclosed(String start, MarkdownReplace replace, { String? name, String? end }) {
    start = RegExp.escape(start);
    end = end != null ? RegExp.escape(end) : start;
    return MarkdownPlaceholder(name: name, RegExp('$start(.+?)$end'), replace);
  }

  factory MarkdownPlaceholder.tag(String tag, MarkdownReplace replace, { String? name }) {
    return MarkdownPlaceholder.enclosed(name: name, '<$tag>', end: '</$tag>', replace);
  }
}

typedef MarkdownReplace = String Function(String text, Match match);