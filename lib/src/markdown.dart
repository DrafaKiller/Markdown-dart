import 'package:marked/marked.dart';
import 'package:marked/src/placeholder.dart';

class Markdown {
  final Set<MarkdownPlaceholder> placeholders;

  Markdown(this.placeholders);

  /// Apply the markdown on an input.
  /// 
  /// Essentially, this method will apply all the placeholders
  String apply(String input) {
    for (final placeholder in placeholders) {
      input = placeholder.apply(input);
    }
    return input;
  }

  /// Simplifies the markdown definition by transforming a set of entries into placeholders, given the relating string key.
  /// 
  /// Usage example, with the following placeholder equivalent:
  /// ```dart
  /// '*': (text, match) => '<b>$text</b>'
  ///   MarkdownPlaceholder.enclosed('*', (text, match) => '<b>$text</b>'),
  /// 
  /// '<custom>': (text, match) => '[$text]'
  ///   MarkdownPlaceholder.tag('custom', (text, match) => '[$text]'),
  /// 
  /// '/\*([^*]+)\*/': (text, match) => '<b>$text</b>'
  ///   MarkdownPlaceholder.regexp('/\*([^*]+)\*/', (text, match) => '<b>$text</b>'),
  /// ```
  /// 
  /// A prefix can be used to ensure the right placeholder is used. 
  /// ```dart
  /// 'enclosed: *': (text, match) => '<b>$text</b>'
  /// 'tag: <custom>': (text, match) => '[$text]'
  /// 'regexp: \*([^*]+)\*': (text, match) => '<b>$text</b>'
  /// ```
  /// 
  /// ### Types of placeholders:
  /// 
  /// **Normal** - prefix `normal: `<br>
  ///   Applies the default placeholder, which is **enclosed**.
  /// 
  /// **Enclosed** - prefix `enclosed: `<br>
  ///   Starts and ends with the same token, like **\*** for `*text*`.
  /// 
  /// **Sticky** - `[ ]` or prefix `sticky: `<br>
  ///   Same as **enclosed**, but tokens must be next to a character.
  /// 
  /// **Split** - ` | ` or prefix `split: `<br>
  ///   Same as **enclosed**, but splits the start token at ` | ` to set the end token, like `/* | */` for `/*text*/`.
  /// 
  /// **RegExp** - `/ /` or prefix `regexp: `<br>
  ///   Matches a regular expression, the **text** is the first capture group.
  /// 
  /// **Tag** - `< >` or prefix `tag: `<br>
  ///   Starts with a tag of type **\<tag>** and ending with **\</tag>**, HTML-like.
  ///   Tags may have properties, which are of pattern `key[="value"]`.<br>
  ///   Properties are strict and specified, unless it contains `*`.<br>
  ///   Properties can be specified when mapping like `<tag prop1|...>`, and can be fetched using **match.tagProperties**. 
  factory Markdown.map(Map<String, MarkdownReplace> map, [ Set<MarkdownPlaceholder>? placeholders ]) {
    placeholders ??= <MarkdownPlaceholder>{};
    return Markdown(
      placeholders..addAll(
        map.entries
          .map((entry) {
            String pattern = entry.key;
            final replace = entry.value;
            final String mode;
            
            if (pattern.startsWith('normal: ')) {
              mode = 'normal';
              pattern = pattern.substring(8);
            } else if (pattern.startsWith('enclosed: ')) {
              mode = 'enclosed';
              pattern = pattern.substring(10);
            } else if (pattern.startsWith('regexp: ')) {
              mode = 'regexp';
              pattern = pattern.substring(8);
            } else if (pattern.startsWith('tag: ')) {
              mode = 'tag';
              pattern = pattern.substring(5);
            } else if (pattern.startsWith('sticky: ')) {
              mode = 'sticky';
              pattern = pattern.substring(8);
            } else  if (pattern.startsWith('split: ')) {
              mode = 'split';
              pattern = pattern.substring(7);
            } else 
            
            if (pattern.startsWith('/') && pattern.endsWith('/')) {
              mode = 'regexp';
              pattern = pattern.substring(1, pattern.length - 1);
            } else if (pattern.startsWith('<') && pattern.endsWith('>')) {
              mode = 'tag';
            } else if (pattern.startsWith('[') && pattern.endsWith(']')) {
              mode = 'sticky';
              pattern = pattern.substring(1, pattern.length - 1);
            } else if (pattern.contains('|')) {
              mode = 'split';
            } else {
              mode = 'enclosed';
            }

            switch (mode) {
              case 'normal':
                return MarkdownPlaceholder.enclosed(pattern, replace);

              case 'regexp':
                return MarkdownPlaceholder.regexp(pattern, replace);

              case 'tag':
                final tagMatch = _tagDefinitionPattern.firstMatch(pattern);
                if (tagMatch != null) {
                  final name = tagMatch.namedGroup('name')!;
                  final properties = (tagMatch.namedGroup('properties') ?? '')
                    .split('|').map((property) => property.trim()).toSet();
                    
                  return MarkdownPlaceholder.tag(name, replace, properties: properties);
                }
                break;

              case 'sticky':
                return MarkdownPlaceholder.symmetrical(pattern, replace, sticky: true);

              case 'split':
                final splitMatch = _splitPattern.firstMatch(pattern);
                if (splitMatch != null) {
                  return MarkdownPlaceholder.enclosed(
                    splitMatch.namedGroup('start')!,
                    end: splitMatch.namedGroup('end')!,
                    replace
                  );
                }
                break;

              case 'enclosed':
              default:
                break;
            }

            return MarkdownPlaceholder.enclosed(pattern, replace);
          }).toSet()
      )
    );
  }

  static final _tagDefinitionPattern = RegExp(r'^<(?<name>\w+)(?<properties>\s+(?:\w+(?:\s*\|\s*)?)*)?>$');
  static final _splitPattern = RegExp(r'(?<start>.+) \| (?<end>.+)');
}