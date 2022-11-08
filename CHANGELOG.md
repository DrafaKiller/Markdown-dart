## 0.2.1

Added:
- Basic placeholder alternative, for single token replacements

## 0.2.0

BREAKING CHANGES:
- The markdown was refactored to process the input sequentially using a start and end token,
instead of a single matching RegExp
- Contains escape sequences for the start and end tokens, so that they can be used in the input text
- The API was all changed to be more consistent and to allow for more flexibility
- Added many other placeholder alternatives

## 0.1.0

Added:
- Markdown escaping, see [escape example](https://github.com/DrafaKiller/Markdown-dart/blob/main/example/escape.dart)
Changed:
- Renamed `placeholder.regex` to `placeholder.pattern`
- Enclosed pattern, a `*` won't match `**` anymore because it must be a single match
Removed:
- `Markdown.applyAll` method, now you must instantiate a `Markdown` object and call `apply` method due to escaping

## 0.0.2

Added:
- Code Documentation
- Create a Markdown from a map, support for all placeholder alternatives: [Markdown.map](https://pub.dev/documentation/marked/latest/marked/Markdown/Markdown.map.html)
- Markdown Placeholder alternative: [MarkdownPlaceholder.regexp](https://pub.dev/documentation/marked/latest/marked/MarkdownPlaceholder/MarkdownPlaceholder.regexp.html)
- Apply placeholder of a Markdown in a specific set of names

## 0.0.1

Initial release: Marked