/// ## Markdown Placeholder
/// 
/// Placeholders are modular elements that can be used to create a Markdown syntax.
/// They are used to replace a specific part of the text that matches a pattern.
/// 
/// ```dart
/// MarkdownPlaceholder(RegExp(r'\*\*(.*?)\*\*'), (text, match) => '<b>$text</b>');
/// ```
/// 
/// ### Alternatives
/// 
/// To make it easier to create placeholders, there are some predefined methods:
/// 
/// ```dart
/// MarkdownPlaceholder.enclosed('**', (text, match) => '<b>$text</b>');
/// // Hello **World**! -> Hello <b>World</b>!
/// 
/// MarkdownPlaceholder.tag('strong', (text, match) => '<b>$text</b>');
/// // Hello <strong>World</strong>! -> Hello <b>World</b>!
/// 
/// MarkdownPlaceholder.regexp(r'\*\*(.*?)\*\*', (text, match) => '<b>$text</b>');
/// // Hello **World**! -> Hello <b>World</b>!
/// ```
/// 
/// ### Naming
/// 
/// When creating a placeholder, you can attribute a name to it. This allows you to specify which placeholder to apply.
/// ```dart
/// ... ({
///   MarkdownPlaceholder(name: 'bold', ... );
/// });
/// 
/// markdown.apply('Hello, **World**!', { 'bold' });
/// ```
class MarkdownPlaceholder {
  final String? name;
  final RegExp regex;
  final MarkdownReplace replace;

  MarkdownPlaceholder(this.regex, this.replace, { this.name });

  /// Apply the placeholder to the text.<br>
  /// Replace all the matches with the result of the `replace` function.
  /// 
  /// Returns the parsed result text.
  String apply(String text) => text.replaceAllMapped(regex, (match) => replace(match.group(1) ?? '', match));

  /// Returns whether the placeholder matches the given text.
  bool matches(String text) => regex.hasMatch(text);

  /* -= Alternatives =- */

  /// Create a placeholder that matches the given RegExp pattern.
  /// 
  /// ```dart
  /// MarkdownPlaceholder.regexp(r'\*\*(.*?)\*\*', (text, match) => '<b>$text</b>');
  /// // Hello **World**! -> Hello <b>World</b>!
  /// ```
  factory MarkdownPlaceholder.regexp(String pattern, MarkdownReplace replace, { String? name }) {
    return MarkdownPlaceholder(name: name, RegExp(pattern), replace);
  }

  /// Create a placeholder that matches the given enclosed pattern.
  /// 
  /// Enclosed patterns are defined by a start and end pattern.
  /// 
  /// ```dart
  /// MarkdownPlaceholder.enclosed('**', (text, match) => '<b>$text</b>');
  /// // Hello **World**! -> Hello <b>World</b>!
  /// ```
  factory MarkdownPlaceholder.enclosed(String start, MarkdownReplace replace, { String? name, String? end }) {
    start = RegExp.escape(start);
    end = end != null ? RegExp.escape(end) : start;
    return MarkdownPlaceholder.regexp(name: name, '$start(.+?)$end', replace);
  }

  /// Create a placeholder that matches the given tag, HTML-like.
  /// 
  /// ```dart
  /// MarkdownPlaceholder.tag('strong', (text, match) => '<b>$text</b>');
  /// // Hello <strong>World</strong>! -> Hello <b>World</b>!
  /// ```
  factory MarkdownPlaceholder.tag(String tag, MarkdownReplace replace, { String? name }) {
    return MarkdownPlaceholder.enclosed(name: name, '<$tag>', end: '</$tag>', replace);
  }
}

/* -= Type Aliases =- */

typedef MarkdownReplace = String Function(String text, Match match);
typedef MarkdownEncode = String Function(String text);