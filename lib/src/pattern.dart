import 'package:marked/src/schema.dart';

class MarkdownPattern {
  final RegExp start;
  final RegExp end;

  MarkdownPattern(this.start, [ RegExp? end ]) : this.end = end ?? RegExp('');

  RegExp get startEscaped => escaped(start);
  RegExp get endEscaped => escaped(end);

  /// Whether the pattern is consists only of a single type of character, for example `**`.
  bool get uniqueCharater => isUniqueCharater(start.pattern);

  /// Whether the pattern is symmetrical, which means the start and end patterns are identical.
  bool get symmetrical => start.pattern == end.pattern;

  /// Whether the pattern has only a start token.
  /// 
  /// This most likely means the token is basic in nature, or it handles the replacing itself.
  bool get singleToken => end.pattern.isEmpty;

  int? nextLevel(String input, [ int level = 0 ]) {
    final start = this.startEscaped.firstMatch(input);
    final end = this.endEscaped.firstMatch(input);
    
    if (symmetrical) {
      if (end == null) return null;
      if (level == 0) return level + 1;
      if (end.start == 0) return level;
      return level - 1;
    }

    if (start == null && end == null) return null;
    if (start == null) return level - 1;
    if (end == null) return level + 1;
    if (start.start < end.start) return level + 1;
    return level - 1;
  }

  MarkdownMatch? findEnd(String input, { int level = 1, int offset = 0, bool isIncreasing = true }) {
    final next = nextLevel(input, level);

    if (next == null) return null;
    if (next < level || (next == level && !isIncreasing)) {
      final end = this.endEscaped.firstMatch(input);
      if (end == null) return null;
      return MarkdownMatch(end, offset);
    }

    final start = this.startEscaped.firstMatch(input)!;
    final nextEnd = findEnd(input.substring(start.end), level: level + 1, offset: offset + start.end, isIncreasing: true);
    if (nextEnd == null) return null;

    final lastEnd = findEnd(input.substring(nextEnd.end - offset), level: level, offset: nextEnd.end, isIncreasing: false);
    if (lastEnd == null) return null;

    return lastEnd;
  }

  /* -= Escaping =- */

  static String escapePattern = r'(?<=(?<!\\)(?:\\\\)*)';
  static String unescapePattern = escapePattern + r'\\';

  static RegExp escaped(Pattern pattern) {
    if (pattern is RegExp) return RegExp(escapePattern + pattern.pattern);
    return RegExp(escapePattern + pattern.toString());
  }

  String escape(String input) => input.replaceAllMapped(RegExp(start.pattern), (match) => '\\${match.group(0)}');
  
  String unescape(String input) => input.replaceAll(RegExp('$unescapePattern(?=${ start.pattern }|${ end.pattern })'), '');

  /* -= Static =- */

  static bool isUniqueCharater(String input) => input.split('').toSet().length == 1;

  /* -= Alternatives =- */

  /// ### RegExp Pattern
  /// 
  /// Matches a regular expression, the **text** property is the first capture group.
  factory MarkdownPattern.regexp(String start, [ String? end ]) =>
    MarkdownPattern(RegExp(start), end == null ? null : RegExp(end));

  /// ### String/Normal Pattern
  /// 
  /// Basic pattern, matches an input enclosed by the escaped start and end tokens.
  /// 
  /// - Tokens are escaped.
  /// - The end token is not required, for basic replacing.
  factory MarkdownPattern.string(String start, [ String? end ]) =>
    MarkdownPattern.regexp(
      RegExp.escape(start),
      end == null ? null : RegExp.escape(end)
    );

  /// ### Enclosed Pattern
  /// 
  /// Matches an input enclosed by start and end token, and they are escaped.
  /// 
  /// Same as **string pattern**, but an end token is always present. <br>
  /// If not given it will be the same as the start token.
  /// 
  /// **Example:**
  /// - `('<', '>')` matches `<text>`
  /// - `('*'[, '*'])` matches `*text*`
  factory MarkdownPattern.enclosed(String start, [ String? end ]) =>
    MarkdownPattern.string(start, end ?? start);

  /// ### Symmetrical Pattern
  /// 
  /// Matches an input enclosed by the same token.
  /// 
  /// - The token is escaped.
  /// - Start and end token are the same, thus symmetrical.
  /// 
  /// Options:
  /// - **sticky** - applies regex to ensure any character to be next to the token.
  /// - **nested** - when set to *false*, it will only match the first instance of the token from the inside.
  ///
  /// **Example:**
  /// - `('*')` matches `*text*` to `<i>text</i>`
  /// - `('*', sticky: true)` matches `*text*`, but not `* text *`
  /// - `('*', nested: false)` matches `**text**` to `*<i>text</i>*`, instead of `<i><i>text</i></i>`
  factory MarkdownPattern.symmetrical(String start, { bool nested = true, bool sticky = false }) {
    String end = start;

    if (!nested || sticky) {
      start = assistUniqueCharacter(start);
      end = assistUniqueCharacter(end, true);
    } else {
      start = RegExp.escape(start);
      end = RegExp.escape(end);
    }

    if (sticky) {
      start = '$start(?=\\S)';
      end = '(?<=\\S)$end';
    }

    return MarkdownPattern.regexp(start, end);
  }

  static assistUniqueCharacter(String input, [ bool end = false ]) {
    return !end
      ? '${ RegExp.escape(input) }(?!${ RegExp.escape(input[0]) })'
      : '(?<!${ RegExp.escape(input[0]) })${ RegExp.escape(input) }';
  }

  factory MarkdownPattern.tag(String start, [ String? end, Set<String> properties = const {} ]) {
    end ??= RegExp(r'[\w-.:#]+').firstMatch(start)?.group(0) ?? start;

    return MarkdownPattern.regexp(
      '<$start${ properties.isNotEmpty ? _getPropertiesPattern(properties) : '' }>',
      '<\\/${ end }>',
    );
  }

  static Map<String, String> getPropertiesOfTag(String input) {
    final properties = <String, String>{};
    final match = _tagWithPropertiesPattern.allMatches(input);

    for (final property in match) {
      final propertiesMatch = _tagPropertyPattern.allMatches(property.group(1)!);
      for (final property in propertiesMatch) { 
        properties[property.group(1)!] = property.group(2) ?? '';
      }
    }

    return properties;
  }

  static _getPropertyPattern([ String? name, bool escape = true ]) =>
    '(${
      name != null && name.isNotEmpty && name != '*' ? (escape ? RegExp.escape(name) : name) : r'\w+'
    })(?:=["\']([^"\']*?)["\'])?';

  static _getPropertiesPattern([ Set<String> properties = const {} ]) =>
    '(?:\\s+${
      _getPropertyPattern(properties.join('|'), false)
    })*';

  static final _tagPropertyPattern = RegExp(_getPropertyPattern());
  static final _tagWithPropertiesPattern = RegExp('<.+?(${ _getPropertiesPattern() })>');
}
