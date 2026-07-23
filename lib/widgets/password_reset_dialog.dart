import 'package:flutter/material.dart';

import '../app/app_state_scope.dart';

/// Dialog reset kata sandi via email Supabase.
Future<void> showPasswordResetDialog(BuildContext context) async {
  final auth = AppStateScope.of(context).auth;
  final emailController = TextEditingController(
    text: auth.email != 'guest@pola.app' ? auth.email : '',
  );

  final sent = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Lupa kata sandi'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Masukkan email terdaftar. Tautan reset akan dikirim jika Supabase aktif.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Kirim'),
        ),
      ],
    ),
  );

  if (sent != true || !context.mounted) {
    emailController.dispose();
    return;
  }

  final error = await auth.requestPasswordReset(emailController.text);
  emailController.dispose();
  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(error == null ? 'Email terkirim' : 'Gagal'),
      content: Text(
        error ??
            'Periksa kotak masuk email Anda untuk tautan reset kata sandi.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Tutup'),
        ),
      ],
    ),
  );
}
