import 'package:flutter/material.dart';

import '../../app/shell_scope.dart';

/// Tombol aksi untuk membuka Chat AI dengan pertanyaan terkait modul informasi.
class AskPolaButton extends StatelessWidget {
  const AskPolaButton({
    super.key,
    required this.prompt,
    this.label = 'Tanya POLA',
  });

  final String prompt;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () {
          ShellScope.of(context).openChat(context, chatPrompt: prompt);
        },
        icon: const Icon(Icons.auto_awesome_rounded),
        label: Text(label),
      ),
    );
  }
}
