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
  const Markdown(this.placeholders);

  /// Apply the placeholders from the Markdown.<br>
  /// If the list of names is empty, it will apply all placeholders currently attached.
  /// 
  /// Returns the parsed result text.
  String apply(String text, [ Set<String> names = const {} ]) {
    if (names.isNotEmpty) {
      return Markdown.applyAll(text, placeholders.where((placeholder) => names.contains(placeholder.name)).toSet());
    }
    return Markdown.applyAll(text, placeholders);
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
