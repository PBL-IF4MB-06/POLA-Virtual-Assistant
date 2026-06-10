import 'package:flutter/material.dart';

/// Renders chat text with light Markdown: **bold**, ## headings, - lists.
class FormattedMessageText extends StatelessWidget {
  const FormattedMessageText({
    super.key,
    required this.text,
    this.style,
  });

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final base = style ?? DefaultTextStyle.of(context).style;
    return Text.rich(
      TextSpan(style: base, children: _parseBlocks(text, base)),
    );
  }

  static List<InlineSpan> _parseBlocks(String text, TextStyle base) {
    final lines = text.split('\n');
    final spans = <InlineSpan>[];

    for (var i = 0; i < lines.length; i++) {
      if (i > 0) spans.add(const TextSpan(text: '\n'));

      var line = lines[i];
      var lineStyle = base;

      if (line.startsWith('## ')) {
        line = line.substring(3);
        lineStyle = base.merge(const TextStyle(fontWeight: FontWeight.w700));
      } else if (line.startsWith('- ')) {
        spans.add(TextSpan(text: '• ', style: base));
        line = line.substring(2);
      }

      spans.addAll(_parseInline(line, lineStyle));
    }

    if (spans.isEmpty) {
      spans.add(TextSpan(text: text, style: base));
    }

    return spans;
  }

  static List<InlineSpan> _parseInline(String text, TextStyle style) {
    final spans = <InlineSpan>[];
    final re = RegExp(r'\*\*(.+?)\*\*');
    var start = 0;

    for (final match in re.allMatches(text)) {
      if (match.start > start) {
        spans.add(
          TextSpan(text: text.substring(start, match.start), style: style),
        );
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: style.merge(const TextStyle(fontWeight: FontWeight.w700)),
        ),
      );
      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: style));
    }

    if (spans.isEmpty && text.isNotEmpty) {
      spans.add(TextSpan(text: text, style: style));
    }

    return spans;
  }
}
