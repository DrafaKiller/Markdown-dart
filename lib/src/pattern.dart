class MarkdownPattern {
  final RegExp start;
  final RegExp end;

  MarkdownPattern(this.start, [ RegExp? end ]) : this.end = end ?? RegExp('');

  /// Whether the pattern is consists only of a single type of character, for example `**`.
  bool get uniqueCharater => start.pattern.split('').toSet().length == 1;

  /// Whether the pattern is symmetrical, which means the start and end patterns are identical.
  bool get symmetrical => start.pattern == end.pattern;

  /// Whether the pattern has only a start token.
  /// 
  /// This most likely means the token is basic in nature, or it handles the replacing itself.
  bool get singleToken => end.pattern.isEmpty;

  /* -= Alternatives =- */

  /// ### RegExp Pattern
  /// 
  /// Matches a regular expression, the **text** property is the first capture group.
  factory MarkdownPattern.regexp(String start, [ String? end ]) =>
    MarkdownPattern(RegExp(start), end == null ? null : RegExp(end));

  // String / Text
  /// ### String/Normal Pattern
  /// 
  /// Basic pattern, matches an input enclosed by the escaped start and end tokens.
  factory MarkdownPattern.string(String start, [ String? end ]) =>
    MarkdownPattern.regexp(
      RegExp.escape(start),
      end == null ? null : RegExp.escape(end)
    );

  // Enclosed
  /// ### Enclosed Pattern
  /// 
  /// Matches an input enclosed by start and end token.
  /// 
  /// Tokens are escaped, and when is unique character is ensured it doesn't repeat.
  /// 
  /// **Example:**
  /// - `('<', '>')` matches `<text>`
  /// - `('*'[, '*'])` matches `*text*`
  /// 
  /// **Note:**<br>
  /// Unique character patterns can be unpredictable as the start and end token are identical.
  /// 
  /// The token `*` on `**text**` would apply as `<i>*text</i>*`, so it's ensured that
  /// it doesn't repeat by only applying it to the inner match `*<i>text</i>*`.
  factory MarkdownPattern.enclosed(String start, [ String? end ]) =>
    MarkdownPattern.regexp(
      assistUniqueCharacter(start),
      assistUniqueCharacter(end ?? start, true),
    );

  static _isUniqueCharacter(String input) => input.split('').toSet().length == 1;

  static assistUniqueCharacter(String input, [ bool end = false ]) {
    if (!_isUniqueCharacter(input)) return RegExp.escape(input);
    return !end
      ? '${ RegExp.escape(input) }(?!${ RegExp.escape(input[0]) })'
      : '(?<!${ RegExp.escape(input[0]) })${ RegExp.escape(input) }';
  }

  // Tag
  factory MarkdownPattern.tag(String start, [ String? end, Set<String> properties = const {} ]) {
    start = RegExp.escape(start)
      .replaceAll(r'\.\.\.', r'.+?')
      .replaceAllMapped(RegExp(r'\\\\d(?:\\([\*\+]))?'), (match) => r'\d' + (match.group(1) ?? ''));

    end = end == null ? start : RegExp.escape(end)
      .replaceAll(r'\.\.\.', r'.+?')
      .replaceAllMapped(RegExp(r'\\\\d(?:\\([\*\+]))?'), (match) => r'\d' + (match.group(1) ?? ''));

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
