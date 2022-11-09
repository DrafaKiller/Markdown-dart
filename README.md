[![Pub.dev package](https://img.shields.io/badge/pub.dev-marked-blue)](https://pub.dev/packages/marked)
[![GitHub repository](https://img.shields.io/badge/GitHub-Markdown--dart-blue?logo=github)](https://github.com/DrafaKiller/Markdown-dart)

# Markdown

A simple-setup Markdown syntax parser for Dart.<br>
Create your own custom Markdown syntax.

## Features

* Simple Markdown syntax setup
* Generic Markdown-base for any use-case
* Apply the Markdown to any text
* Attach placeholders to modify the input

## Getting started

Install it using pub:
```
dart pub add marked
```

And import the package:
```dart
import 'package:marked/marked.dart';
```

## Usage

Create a Markdown instance with all the placeholders you want to use.

Then, use the `apply` method to parse the Markdown syntax.

```dart
import 'package:marked/marked.dart';

final markdown = Markdown.map({
  '**': (text, match) => '<b>$text</b>',
  '*': (text, match) => '<i>$text</i>',
  '__': (text, match) => '<u>$text</u>',
});

void main() {
  print(
    markdown.apply('''
      Hello **World**!
      __Looks *pretty* easy__
    ''')
  );

  // Output:
  //   Hello <b>World</b>!
  //   <u>Looks <i>pretty</i> easy</u>
}
```

## Placeholders

Placeholders are modular elements that can be used to create a Markdown syntax.
They are used to replace a specific part of the text that matches a pattern.

```dart
MarkdownPlaceholder(RegExp(r'\*\*(.*?)\*\*'), (text, match) => '<b>$text</b>');
```

To make it easier to create placeholders, there are some predefined methods:

```dart
MarkdownPlaceholder.enclosed('**', (text, match) => '<b>$text</b>');
// Hello **World**! -> Hello <b>World</b>!

MarkdownPlaceholder.tag('strong', (text, match) => '<b>$text</b>');
// Hello <strong>World</strong>! -> Hello <b>World</b>!

MarkdownPlaceholder.regexp(r'\*\*(.*?)\*\*', (text, match) => '<b>$text</b>');
// Hello **World**! -> Hello <b>World</b>!
```

## Placeholder Mapping

To Simplify the markdown definition, you may transform a set of entries into placeholders, given the related string key. Using the `Markdown.map()` method.

Usage example, with the following placeholder equivalent:
```dart
'*': (text, match) => '<b>$text</b>'
  MarkdownPlaceholder.enclosed('*', (text, match) => '<b>$text</b>'),

'<custom>': (text, match) => '[$text]'
  MarkdownPlaceholder.tag('custom', (text, match) => '[$text]'),

'/\*([^*]+)\*/': (text, match) => '<b>$text</b>'
  MarkdownPlaceholder.regexp('/\*([^*]+)\*/', (text, match) => '<b>$text</b>'),
```

A prefix can be used to ensure the right placeholder is used. 
```dart
'enclosed: *': (text, match) => '<b>$text</b>'
'tag: <custom>': (text, match) => '[$text]'
'regexp: \*([^*]+)\*': (text, match) => '<b>$text</b>'
```

### Types of placeholders: 

| Type | Description | Prefix | Symbol |
| ---- | ----------- | ------ |	------ |
| Normal | Applies the default placeholder, which is **enclosed**. | `normal: ` | None |
| Enclosed | Starts and ends with the same token, like **\*** for `*text*`. | `enclosed: ` | None |
| Basic | Single token placeholder, for a basic replacement. | `basic: ` | None |
| Sticky | Same as **enclosed**, but tokens must be next to a character. | `sticky: ` | `[...]` |
| Split | Splits the start token at ` \| ` to set the end token, like `/* \| */` matching with  `/*text*/`. | `split: ` | `... \| ...` |
| RegExp | Matches a regular expression, the **text** is the first capture group. | `regexp: ` | `/.../` |
| Tag | Starts with a tag of type **\<tag>** and ending with **\</tag>**, HTML-like.<br> Tags may have properties, `key[="value"]`, defined as `<tag prop1\|...>`, and can be fetched using `match.tagProperties`.  | `tag: ` | `<...>` |

**Note:**
When using a unique character token, the created placeholders will be symmetrical with no nesting, this is so it's more intuitive. 

## Escaping

  To escape a placeholder, you can use the `\` character.
  You may also escape the escape character, instances of **\\\\** will be replaced with **\\**, since they are escaped.

  An input can be manually escaped and unescaped using the methods `markdown.escape(input)` and `markdown.unescape(input)`.

## Example

```dart
import 'package:marked/marked.dart';

final htmlMarkdown = Markdown({
  MarkdownPlaceholder.enclosed('**', (text, match) => '<b>$text</b>'),
  MarkdownPlaceholder.enclosed('*', (text, match) => '<i>$text</i>'),
  MarkdownPlaceholder.enclosed('~~', (text, match) => '<strike>$text</strike>'),
  MarkdownPlaceholder.enclosed('`', (text, match) => '<code>$text</code>'),
});

void main() {
  print(htmlMarkdown.apply('HTML Markdown: **bold** *italic* ~~strike~~ `code`'));
  
  // [Output]
  //   HTML Markdown: <b>bold</b> <i>italic</i> <strike>strike</strike> <code>code</code>
}
```

More Examples:
* [HTML Markdown](https://pub.dev/packages/marked/example)
* [Markdown Map](https://github.com/DrafaKiller/Markdown-dart/blob/main/example/mapped.dart)