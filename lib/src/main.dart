import 'placeholder.dart';

class Markdown {
  final Set<MarkdownPlaceholder> placeholders;

  const Markdown(this.placeholders);

  String apply(String text, [ Set<String> names = const {} ]) {
    if (names.isNotEmpty) {
      return Markdown.applyAll(text, placeholders.where((placeholder) => names.contains(placeholder.name)).toSet());
    }
    return Markdown.applyAll(text, placeholders);
  }
  
  static String applyAll(String text, Set<MarkdownPlaceholder> placeholders) {
    String result = text;
    for (final markdown in placeholders) {
      result = markdown.apply(result);
    }
    return result;
  }

  /* -= Alternatives =- */

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
