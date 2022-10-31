import 'dart:convert';

import 'placeholder.dart';

/// # Markdown
/// 
/// A simple Markdown parser for Dart.<br>
/// Create your own custom Markdown syntax.
/// 
/// ## Features
/// 
/// * Attach placeholder replacements to your Markdown syntax
/// * Simple to create a Markdown syntax
/// * Easily improvable and extendable, with better organization
/// * Generalized for most use cases
/// 
/// ## Usage
/// 
/// Create a Markdown instance with all the placeholders you want to use.
/// 
/// Then, use the `apply` method to parse the Markdown syntax.
/// 
/// <br>
/// 
/// ```dart
/// import 'package:marked/marked.dart';
/// 
/// final markdown = Markdown.map({
///   '**': (text, match) => '<b>$text</b>',
///   '*': (text, match) => '<i>$text</i>',
///   '~~': (text, match) => '<strike>$text</strike>',
///   '__': (text, match) => '<u>$text</u>',
///   '`': (text, match) => '<code>$text</code>',
/// });
/// 
/// void main() {
///   print(
///     markdown.apply('''
///       Hello **World**!
///       __Looks *pretty* easy__
///     ''')
///   );
/// 
///   // Output:
///   //   Hello <b>World</b>!
///   //   <u>Looks <i>pretty</i> easy</u>
/// }
/// ```
class Markdown {
  final Set<MarkdownPlaceholder> placeholders;
  final RegExp? escapePattern;

  /// Create a Markdown instance with all the placeholders you want to use.
  /// 
  /// Then, use the `apply` method to parse the Markdown syntax.
  /// 
  /// <br>
  /// 
  /// ```dart
  /// import 'package:marked/marked.dart';
  /// 
  /// final markdown = Markdown({
  ///   MarkdownPlaceholder.enclosed('**', (text, match) => '<b>$text</b>'),
  ///   MarkdownPlaceholder.enclosed('*', (text, match) => '<i>$text</i>'),
  ///   MarkdownPlaceholder.enclosed('__', (text, match) => '<u>$text</u>'),
  ///   MarkdownPlaceholder.enclosed('~~', (text, match) => '<strike>$text</strike>'),
  ///   MarkdownPlaceholder.enclosed('`', (text, match) => '<code>$text</code>'),
  /// });
  /// 
  /// void main() {
  ///   print(
  ///     markdown.apply('''
  ///       Hello **World**!
  ///       __Looks *pretty* easy__
  ///     ''')
  ///   );
  /// 
  ///   // Output:
  ///   //   Hello <b>World</b>!
  ///   //   <u>Looks <i>pretty</i> easy</u>
  /// }
  /// ```
  Markdown(this.placeholders, { String? escape, RegExp? escapePattern })
    : escapePattern = escapePattern ?? getEscapeUsing(escape ?? r'\');

  

  /// Apply the placeholders from the Markdown.<br>
  /// If the list of names is empty, it will apply all placeholders currently attached.
  /// 
  /// Returns the parsed result text.
  String apply(String text, [ Set<String> names = const {} ]) {
    text = encode(text);
    text = Markdown.applyAll(
      text,
      names.isNotEmpty
        ? placeholders.where((placeholder) => names.contains(placeholder.name)).toSet()
        : placeholders
    );
    return decode(text);
  }

  String encode(String text) {
    if (escapePattern == null) return text;

    int offset = 0;
    for (final match in escapePattern!.allMatches(text)) {
      final actualStart = match.start + offset;
      final actualEnd = match.end + offset;

      final textAfter = text.substring(actualEnd);
      for (final placeholder in placeholders) {
        final placeholderMatch = placeholder.regex.firstMatch(textAfter);
        if (placeholderMatch != null && placeholderMatch.start == 0) {
          text = text.replaceRange(actualStart, actualStart + placeholderMatch.end + 1, _encode(placeholderMatch.group(0)!));
          offset += placeholderMatch.end * 2 - 1;
          break;
        }
      }
    }

    return text; 
  }
  
  String decode(String text) => _decode(text);

  static String _encode(String text, [ Pattern? pattern ]) {
    if (pattern != null) return text.replaceAllMapped(pattern, (match) => _encode(match.group(0)!));
    return utf8.encoder
      .convert(text)
      .map((value) => '%${ value.toRadixString(16).padLeft(2, '0') }')
      .join('');
  }

  static String _decode(String text) {
    return text.replaceAllMapped(RegExp(r'(?:%\w{2})+'), (match) {
      return utf8.decoder
        .convert(
          RegExp(r'%(\w{2})')
            .allMatches(match.group(0)!)
            .map((value) => int.parse(value.group(1)!, radix: 16))
            .toList()
        );
    });
  }
  
  static void main() {
    print(_decode('test %74%65%73%74%20%31%32%33 123'));
  }
  
  /// Apply all the placeholders given to the text.
  /// 
  /// Returns the parsed result text.
  static String applyAll(String text, Set<MarkdownPlaceholder> placeholders) {
    String result = text;
    for (final markdown in placeholders) {
      result = markdown.apply(result);
    }
    return result;
  }

  static RegExp? getEscapeUsing(String pattern) {
    if (pattern.isEmpty) return null;

    pattern = RegExp.escape(pattern);
    return RegExp('(?=(?<!$pattern)$pattern$pattern)*$pattern');
  }

  /* -= Alternatives =- */

  /// Create a Markdown instance with all the placeholders you want to use.
  /// Then, use the `apply` method to parse the Markdown syntax.
  /// 
  /// ## Usage
  /// 
  /// A markdown syntax is defined using the map, for each entry a placeholder will be created
  /// depending on the key:
  /// 
  /// - `  ...  ` - Enclosed placeholder
  /// - `< ... >` - Tag placeholder
  /// - `/ ... /` - RegExp placeholder
  /// 
  /// <br>
  /// 
  /// ```dart
  /// import 'package:marked/marked.dart';
  /// 
  /// final markdown = Markdown.map({
  ///   '**': (text, match) => '<b>$text</b>',
  ///   '*': (text, match) => '<i>$text</i>',
  ///   '~~': (text, match) => '<strike>$text</strike>',
  ///   '__': (text, match) => '<u>$text</u>',
  ///   '`': (text, match) => '<code>$text</code>',
  ///   '<strong>': (text, match) => '<b>$text</b>',
  /// });
  /// 
  /// void main() {
  ///   print(
  ///     markdown.apply('''
  ///       Hello **World**!
  ///       __Looks *pretty* easy__
  ///     ''')
  ///   );
  /// 
  ///   // Output:
  ///   //   Hello <b>World</b>!
  ///   //   <u>Looks <i>pretty</i> easy</u>
  /// }
  /// ```
  factory Markdown.map(Map<String, MarkdownReplace> placeholders) {
    return Markdown(placeholders.entries.map((entry) {
      final pattern = entry.key;
      final replace = entry.value;
      
      if (pattern.startsWith('<') && pattern.endsWith('>')) {
        return MarkdownPlaceholder.tag(pattern.substring(1, pattern.length - 1), replace);
      }
    
      if (pattern.startsWith('/') && pattern.endsWith('/')) {
        return MarkdownPlaceholder.regexp(pattern.substring(1, pattern.length - 1), replace);
      }

      return MarkdownPlaceholder.enclosed(pattern, replace);
    }).toSet());
  }
}
