import 'package:marked/marked.dart';
import 'package:test/test.dart';

void main() {
  group('Asymmetrical', () {
    final markdown = Markdown({
      MarkdownPlaceholder.string('/*', end: '*/', (text, match) => '<[$text]>'),
    });

    test('single', () {
      expect(markdown.apply('/*a*/'), '<[a]>');
      expect(markdown.apply('/* a */'), '<[ a ]>');
      expect(markdown.apply('a /* b */'), 'a <[ b ]>');
      expect(markdown.apply('a /* b */ c'), 'a <[ b ]> c');
    });

    test('multiple', () {
      expect(markdown.apply('/* a */ /* b */ /* c */'), '<[ a ]> <[ b ]> <[ c ]>');
      expect(markdown.apply('/* a *//* b *//* c */' ), '<[ a ]><[ b ]><[ c ]>');
    });

    test('nested', () {
      expect(markdown.apply('/*/*/* a */*/*/'), '<[<[<[ a ]>]>]>');
      expect(markdown.apply('/* /* /* a */ */ */'), '<[ <[ <[ a ]> ]> ]>');

      expect(markdown.apply('/* a /* b */ c */'), '<[ a <[ b ]> c ]>');
      expect(
        markdown.apply('/* a /* b */ c */ /* d /* e1 */ /* e2 */ /* e3 */ f */'),
        '<[ a <[ b ]> c ]> <[ d <[ e1 ]> <[ e2 ]> <[ e3 ]> f ]>'
      );
    });
  });
}