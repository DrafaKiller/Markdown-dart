import 'package:marked/marked.dart';
import 'package:test/test.dart';

void main() {
  group('Symmetrical non-nested', () {
    final markdown = Markdown({
      MarkdownPlaceholder.symmetrical('*', (text, match) => '<[$text]>', nested: false),
    });

    test('nested', () => expect(markdown.apply('*** a ***'), '**<[ a ]>**'));
  });
  
  group('Symmetrical sticky', () {
    final markdown = Markdown({
      MarkdownPlaceholder.symmetrical('*', (text, match) => '<[$text]>', sticky: true),
    });

    test('nested', () => expect(markdown.apply('*a *b* c*'), '<[a <[b]> c]>'));
  });
}