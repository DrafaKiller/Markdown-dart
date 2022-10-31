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
  /// 
  /// ## Escaping
  /// 
  /// You can set an escape pattern to prevent placeholders from being applied.
  /// To disable escaping, set the `escape` to an empty string.
  /// 
  /// You may also escape the escape by repeating it twice, although you will only need to escape the ones before placeholders.
  /// 
  /// By default, the escape pattern is set to `\`.
  /// 
  /// ```dart
  /// final markdown = Markdown.map({ ... }, escape: r'\');
  /// 
  /// print(
  ///   markdown.apply(r'''
  ///     Hello **World**!
  ///     Hello \**World**!
  ///     Hello \\**World**!
  ///   ''')
  /// );
  /// 
  /// // Output:
  /// //   Hello <b>World</b>!
  /// //   Hello **World**!
  /// //   Hello \<b>World</b>!
  /// ```
  Markdown(this.placeholders, { String? escape })
    : escapePattern = getEscapeUsing(escape ?? r'\');

  /// Apply the placeholders from the Markdown.<br>
  /// If the list of names is empty, it will apply all placeholders currently attached.
  /// 
  /// Returns the parsed result text.
  /// 
  /// This encodes the placeholders that match a escape pattern behind, applys the markdown and then decodes.<br>
  /// If there are no matching escaping patterns, or if the escape pattern is set to an empty string,
  /// no performance will be lost.
  String apply(String text, [ Set<String> names = const {} ]) {
    final ignorePositions = _getEscapePositions(text);
    text = Markdown.applyAll(
      text,
      names.isNotEmpty
        ? placeholders.where((placeholder) => names.contains(placeholder.name)).toSet()
        : placeholders,
      ignorePositions: ignorePositions
    );
    return _clearEscapeCharacters(text);
  }

  /// Apply all the placeholders given to the text.
  /// 
  /// Returns the parsed result text.
  static String applyAll(String text, Set<MarkdownPlaceholder> placeholders, { Set<int> ignorePositions = const {} }) {
    for (final markdown in placeholders) {
      text = markdown.apply(text, ignoreCharacters: ignorePositions);
    }
    return text;
  }

  static RegExp? getEscapeUsing(String pattern) {
    if (pattern.isEmpty) return null;
    return RegExp(RegExp.escape(pattern));
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
  factory Markdown.map(Map<String, MarkdownReplace> placeholders, { String? escape }) {
    return Markdown(
      placeholders.entries.map((entry) {
        final pattern = entry.key;
        final replace = entry.value;
        
        if (pattern.startsWith('<') && pattern.endsWith('>')) {
          return MarkdownPlaceholder.tag(pattern.substring(1, pattern.length - 1), replace);
        }
      
        if (pattern.startsWith('/') && pattern.endsWith('/')) {
          return MarkdownPlaceholder.regexp(pattern.substring(1, pattern.length - 1), replace);
        }

        return MarkdownPlaceholder.enclosed(pattern, replace);
      }).toSet(),
      escape: escape
    );
  }

  /* -= Advanced Methods =- */

  Set<int> _getEscapePositions(String text) {
    if (escapePattern == null) return {};
    
    final positions = <int>{};
    int previous = -1;
    for (final match in escapePattern!.allMatches(text)) {
      if (previous == match.start) continue;
      positions.add(match.end);
      previous = match.end;
    }
    return positions;
  }

  Set<int> _getPlaceholderPositions(String text) {
    final positions = <int>{};
    for (final placeholder in placeholders) {
      for (final match in placeholder.pattern.allMatches(text)) {
        positions.add(match.start);
      }
    }
    return positions;
  }

  String _clearEscapeCharacters(String text) {
    if (escapePattern == null) return text;

    final placeholderPositions = _getPlaceholderPositions(text);

    int previous = -1;
    return text.replaceAllMapped(escapePattern!, (match) {
      if (previous == match.start || placeholderPositions.contains(match.end)) {
        return '';
      }
      previous = match.end;
      return match.group(0)!;
    });
  }
}
