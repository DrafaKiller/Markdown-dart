import 'placeholder.dart';

class Markdown {
  final Set<MarkdownPlaceholder> placeholders;

  const Markdown(this.placeholders);

  String apply(String text, { String? name }) {
    if (name != null) return placeholders.firstWhere((placeholder) => placeholder.name == name).apply(text);
    return Markdown.applyAll(text, placeholders);
  }
  
  static String applyAll(String text, Set<MarkdownPlaceholder> placeholders) {
    String result = text;
    for (final markdown in placeholders) {
      result = markdown.apply(result);
    }
    return result;
  }
}
