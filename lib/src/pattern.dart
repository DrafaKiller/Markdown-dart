import 'package:marked/src/node.dart';

class MarkdownPattern {
  final RegExp start;
  final RegExp end;

  MarkdownPattern(this.start, [ RegExp? end ]) : this.end = end ?? RegExp('');

  bool get uniqueCharater => start.pattern.split('').toSet().length == 1;
  bool get symmetrical => start.pattern == end.pattern;
  bool get singleToken => end.pattern.isEmpty;

  /* -= Alternatives =- */

  // RegExp 
  factory MarkdownPattern.regexp(String start, [ String? end ]) =>
    MarkdownPattern(RegExp(start), end == null ? null : RegExp(end));

  // String / Text
  factory MarkdownPattern.string(String start, [ String? end ]) =>
    MarkdownPattern.regexp(
      RegExp.escape(start),
      end == null ? null : RegExp.escape(end)
    );

  // Enclosed
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
      name != null && name.isNotEmpty ? (escape ? RegExp.escape(name) : name) : r'\w+'
    })(?:=["\']([^"\']*?)["\'])?';

  static _getPropertiesPattern([ Set<String> properties = const {} ]) =>
    '(?:\\s+${
      _getPropertyPattern(properties.join('|'), false)
    })*';

  static final _tagPropertyPattern = RegExp(_getPropertyPattern());
  static final _tagWithPropertiesPattern = RegExp('<.+?(${ _getPropertiesPattern() })>');
}
