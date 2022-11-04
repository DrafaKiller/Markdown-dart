import 'package:marked/marked.dart';
import 'package:marked/src/placeholder.dart';

class Markdown {
  final Set<MarkdownPlaceholder> placeholders;

  Markdown(this.placeholders);

  String apply(String input) {
    for (final placeholder in placeholders) {
      input = placeholder.apply(input);
    }
    return input;
  }

  factory Markdown.map(Map<String, MarkdownReplace> map, [ Set<MarkdownPlaceholder>? placeholders ]) {
    placeholders ??= <MarkdownPlaceholder>{};
    return Markdown(
      placeholders..addAll(
        map.entries
          .map((entry) {
            final pattern = entry.key;
            final replace = entry.value;
            
            if (pattern.startsWith('/') && pattern.endsWith('/')) {
              return MarkdownPlaceholder.regexp(
                pattern.substring(1, pattern.length - 1),
                replace
              );
            }
            
            if (pattern.startsWith('<') && pattern.endsWith('>')) {
              final tagMatch = _tagDefinitionPattern.firstMatch(pattern);
              if (tagMatch != null) {
                final name = tagMatch.namedGroup('name')!;
                final properties = (tagMatch.namedGroup('properties') ?? '')
                  .split('|').map((property) => property.trim()).toSet();
                  
                return MarkdownPlaceholder.tag(
                  name,
                  replace,
                  properties: properties
                );
              }
            }

            if (pattern.startsWith('[') && pattern.endsWith(']')) {
              final value = pattern.substring(1, pattern.length - 1);

              return MarkdownPlaceholder.regexp(
                '${ MarkdownPattern.assistUniqueCharacter(value) }(?=\\S)',
                end: '(?<=\\S)${ MarkdownPattern.assistUniqueCharacter(value, true) }',
                replace
              );
            }

            return MarkdownPlaceholder.enclosed(pattern, replace);
          }).toSet()
      )
    );
  }

  static final _tagDefinitionPattern = RegExp(r'^<(?<name>\w+)(?<properties>\s+(?:\w+(?:\s*\|\s*)?)*)?>$');
}