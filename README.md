[![Pub.dev package](https://img.shields.io/badge/pub.dev-marked-blue)](https://pub.dev/packages/marked)
[![GitHub repository](https://img.shields.io/badge/GitHub-Markdown--dart-blue?logo=github)](https://github.com/DrafaKiller/Markdown-dart)

# Marked - Markdown syntax

A simple Markdown parser for Dart.
Create your own custom Markdown syntax.

## Features

* Attach placeholder replacements to your Markdown syntax
* Simple to create a Markdown syntax
* Easily improvable and extendable, with better organization
* Generalized for most use cases

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
final markdown = Markdown({
  MarkdownPlaceholder.enclosed('**', (text, match) => '<b>$text</b>'),
  ...
});

print(markdown.apply('Hello, **World**!'));
// Output: Hello, <b>World</b>!
```

## Placeholders

Placeholders are modular elements that can be used to create a Markdown syntax.
They are used to replace a specific part of the text that matches a pattern.

```dart
MarkdownPlaceholder(RegExp(r'\*\*(.*?)\*\*'), (text, match) => '<b>$text</b>');
```

When creating a placeholder, you can atributte a name to it. This allows you to specify which placeholder to apply.
```dart
MarkdownPlaceholder(name: 'bold', ...);

markdown.apply('Hello, **World**!', [ 'bold' ]);
```

To make it easier to create placeholders, there are some predefined constructors:

### Enclosed

The `MarkdownPlaceholder.enclosed` method creates a placeholder that matches a text enclosed by a specific character.

```dart
MarkdownPlaceholder.enclosed('**', (text, match) => '<b>$text</b>');
```

### Tag

The `MarkdownPlaceholder.tag` method creates a placeholder that matches a text enclosed by a specific tag, HTML-like.

```dart
MarkdownPlaceholder.tag('b', (text, match) => '<b>$text</b>');
```

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
  // HTML Markdown: <b>bold</b> <i>italic</i> <strike>strike</strike> <code>code</code>
}
```