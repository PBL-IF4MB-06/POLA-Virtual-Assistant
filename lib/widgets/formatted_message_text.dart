import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Renders chat text with light Markdown: **bold**, ## headings, - lists, URLs.
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
      TextSpan(style: base, children: _parseBlocks(text, base, context)),
    );
  }

  static List<InlineSpan> _parseBlocks(
    String text,
    TextStyle base,
    BuildContext context,
  ) {
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
      } else if (RegExp(r'^\d+\.\s').hasMatch(line)) {
        final match = RegExp(r'^(\d+\.)\s').firstMatch(line)!;
        spans.add(TextSpan(text: '${match.group(1)} ', style: base));
        line = line.substring(match.end);
      }

      spans.addAll(_parseInline(line, lineStyle, context));
    }

    if (spans.isEmpty) {
      spans.addAll(_parseInline(text, base, context));
    }

    return spans;
  }

  static List<InlineSpan> _parseInline(
    String text,
    TextStyle style,
    BuildContext context,
  ) {
    final spans = <InlineSpan>[];
    final pattern = RegExp(
      r'\*\*(.+?)\*\*|(https?://[^\s<>\]\)]+)',
    );
    var start = 0;

    for (final match in pattern.allMatches(text)) {
      if (match.start > start) {
        spans.add(
          TextSpan(text: text.substring(start, match.start), style: style),
        );
      }

      if (match.group(1) != null) {
        spans.add(
          TextSpan(
            text: match.group(1),
            style: style.merge(const TextStyle(fontWeight: FontWeight.w700)),
          ),
        );
      } else if (match.group(2) != null) {
        final url = match.group(2)!;
        final linkColor =
            Theme.of(context).colorScheme.primary;
        spans.add(
          TextSpan(
            text: url,
            style: style.merge(
              TextStyle(
                color: linkColor,
                decoration: TextDecoration.underline,
                decorationColor: linkColor,
              ),
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _openUrl(context, url),
          ),
        );
      }

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

  static Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka tautan.')),
      );
    }
  }
}
