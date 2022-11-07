import 'package:marked/marked.dart';
import 'package:test/test.dart';

extension ExpectMarkdownPattern on MarkdownPattern {
  void expectEnd(String input, int start, int end, { int? offset }) {
    var match = findEnd(input);
    expect(match, isNotNull);
    if (offset != null) expect(match?.offset, offset);
    expect(match?.start, start);
    expect(match?.end, end);
  }

  void expectNoEnd(String input) => expect(findEnd(input), isNull);
}


void main() {
  group('Pattern -', () {
    group('Asymmetrical', () {
      final pattern = MarkdownPattern.string('/*', '*/');

      test('not found', () {
        pattern.expectNoEnd('');
        pattern.expectNoEnd('a b c');
        pattern.expectNoEnd('/*');
        pattern.expectNoEnd('a /* b */');
      });

      group('single', () {
        test('simple', () => pattern.expectEnd('*/', 0, 2));
        test('spaced', () => pattern.expectEnd('a */ b', 2, 4));
        test('not ambiguous', () => pattern.expectEnd('a */ */ b', 2, 4));
      });
    
      test('multiple', () => pattern.expectEnd('*/ /* a */ /* b */', 0, 2));
      group('nested', () {
        test('simple', () => pattern.expectEnd('a /* b */ c */', 12, 14));
        test('multiple', () => pattern.expectEnd('a /* b */ /* c */ d */', 20, 22));
        test('multiple extreme', () => pattern.expectEnd('a /* b1 /* b2 */ b3 */ /* /* c1 */ /* c2 */ /* c3*/ */ e */', 57, 59));
      });
    });

    group('Symmetrical', () {
      final pattern = MarkdownPattern.string('*', '*');

      test('not found', () {
        pattern.expectNoEnd('');
        pattern.expectNoEnd('a b c');
        pattern.expectNoEnd('*');
        pattern.expectNoEnd('* a * b');
      });

      test('simple', () => pattern.expectEnd(' a *', 3, 4));
      test('multiple', () => pattern.expectEnd('a* *b* *c*', 1, 2));

      group('nested', () {
        test('simple', () => pattern.expectEnd('* a **', 5, 6));
        test('multiple', () => pattern.expectEnd('** a ***', 7, 8));
        test('extra', () => pattern.expectEnd('** a * b * c *', 13, 14));
      });
    });
  });
}