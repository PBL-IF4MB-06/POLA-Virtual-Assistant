import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../app/app_state_scope.dart';
import 'admin_page.dart';
import 'login_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AppStateScope.of(context).auth;
    final theme = AppStateScope.of(context).theme;
    final chat = AppStateScope.of(context).chat;
    final settings = AppStateScope.of(context).settings;

    return AnimatedBuilder(
      animation: Listenable.merge([auth, settings, theme]),
      builder: (context, _) {
        final isDark = theme.mode == ThemeMode.dark;
        final isId = settings.appLanguage == 'Indonesia';
        final effectiveName =
            settings.profileName.isNotEmpty ? settings.profileName : auth.displayName;
        final handleBase = settings.username.isNotEmpty
            ? settings.username
            : (auth.email.split('@').first);
        final handle = '@$handleBase';

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Text(
              'Pengaturan',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            _GroupHeader('Preferensi Aplikasi'),
            const SizedBox(height: 8),
            _SurfaceCard(
              children: [
                _SwitchRow(
                  icon: Icons.dark_mode_outlined,
                  title: 'Mode Gelap',
                  value: isDark,
                  onChanged: (v) => theme.setMode(v ? ThemeMode.dark : ThemeMode.light),
                ),
                _NavRow(
                  icon: Icons.language_outlined,
                  title: 'Bahasa',
                  trailing: _LanguagePill(
                    label: isId ? 'Indonesia' : 'English',
                    code: isId ? 'ID' : 'EN',
                  ),
                  onTap: () => _pickLanguage(context, settings),
                ),
                _SwitchRow(
                  icon: Icons.vibration_outlined,
                  title: 'Umpan balik haptik',
                  value: settings.hapticFeedback,
                  onChanged: settings.setHapticFeedback,
                ),
                _SwitchRow(
                  icon: Icons.spellcheck_outlined,
                  title: 'Koreksi ejaan otomatis',
                  value: settings.spellCorrection,
                  onChanged: settings.setSpellCorrection,
                ),
                _NavRow(
                  icon: Icons.restart_alt,
                  title: 'Reset Riwayat Chat',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _confirmResetChat(context, chat),
                ),
                _SwitchRow(
                  icon: Icons.volume_up_outlined,
                  title: 'Efek Suara',
                  value: settings.soundEffects,
                  onChanged: settings.setSoundEffects,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _GroupHeader('Akun'),
            const SizedBox(height: 8),
            _SurfaceCard(
              children: [
                _NavRow(
                  icon: Icons.badge_outlined,
                  title: 'Profil',
                  trailing: _ProfilePill(name: effectiveName, handle: handle),
                  onTap: () => _showEditProfile(context),
                ),
                if (!auth.isLoggedIn)
                  _NavRow(
                    icon: Icons.login,
                    title: 'Login / Register',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                  )
                else
                  _NavRow(
                    icon: Icons.logout,
                    title: 'Logout',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      auth.logout();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Anda keluar.')),
                      );
                    },
                  ),
                _NavRow(
                  icon: Icons.person_outline,
                  title: 'Edit Profil',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showEditProfile(context),
                ),
                if (auth.isLoggedIn)
                  _NavRow(
                    icon: Icons.lock_outline,
                    title: 'Ganti Kata Sandi',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showChangePassword(context),
                  )
                else
                  const SizedBox.shrink(),
                if (auth.isAdmin)
                  _NavRow(
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'Admin Panel',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AdminPage()),
                      );
                    },
                  )
                else
                  const SizedBox.shrink(),
                _NavRow(
                  icon: Icons.info_outline,
                  title: 'Tentang Aplikasi',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showAbout(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Versi 1.0.0',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfilePill extends StatelessWidget {
  const _ProfilePill({required this.name, required this.handle});
  final String name;
  final String handle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        Text(
          handle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: cs.surface.withValues(alpha: 0.82),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: _withDividers(children)),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.title,
    required this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class _LanguagePill extends StatelessWidget {
  const _LanguagePill({required this.label, required this.code});
  final String label;
  final String code;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: cs.primary.withValues(alpha: 0.12),
            border: Border.all(color: cs.primary.withValues(alpha: 0.20)),
          ),
          child: Text(
            code,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
      ],
    );
  }
}

List<Widget> _withDividers(List<Widget> children) {
  final out = <Widget>[];
  for (var i = 0; i < children.length; i++) {
    out.add(children[i]);
    if (i != children.length - 1) {
      out.add(const Divider(height: 1));
    }
  }
  return out;
}

Future<void> _pickLanguage(BuildContext context, dynamic settings) async {
  final current = settings.appLanguage as String;
  final picked = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: RadioGroup<String>(
        groupValue: current,
        onChanged: (v) => Navigator.of(context).pop(v),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            ListTile(title: Text('Bahasa')),
            RadioListTile<String>(value: 'Indonesia', title: Text('Indonesia')),
            RadioListTile<String>(value: 'English', title: Text('English')),
            SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
  if (picked != null) {
    await settings.setAppLanguage(picked);
  }
}

Future<void> _confirmResetChat(BuildContext context, dynamic chat) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Reset riwayat chat?'),
      content: const Text('Semua percakapan akan dihapus dari perangkat ini.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Reset'),
        ),
      ],
    ),
  );
  if (ok == true) {
    chat.clearAllConversations();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Riwayat chat sudah di-reset.')),
    );
  }
}

Future<void> _showEditProfile(BuildContext context) async {
  final auth = AppStateScope.of(context).auth;
  final settings = AppStateScope.of(context).settings;

  final effectiveName =
      settings.profileName.isNotEmpty ? settings.profileName : auth.displayName;
  final handleBase =
      settings.username.isNotEmpty ? settings.username : auth.email.split('@').first;

  final nameController = TextEditingController(text: effectiveName);
  final userController = TextEditingController(text: handleBase);

  final result = await showDialog<Object?>(
    context: context,
    builder: (context) {
      var newAvatar = settings.avatarBase64;
      return StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Edit profil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _AvatarEditor(
                initials: _initialsOf(effectiveName),
                avatarBase64: newAvatar,
                onPick: () async {
                  final picker = ImagePicker();
                  final image = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 512,
                    imageQuality: 85,
                  );
                  if (image == null) return;
                  final bytes = await image.readAsBytes();
                  setStateDialog(() => newAvatar = _encodeImage(bytes));
                },
                onRemove: () => setStateDialog(() => newAvatar = ''),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: userController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(newAvatar),
              child: const Text('Simpan'),
            ),
          ],
        ),
      );
    },
  );

  if (result is String) {
    await settings.setProfile(
      name: nameController.text,
      username: userController.text,
    );
    await settings.setAvatarBase64(result);
  }
}

Future<void> _showChangePassword(BuildContext context) async {
  final auth = AppStateScope.of(context).auth;
  if (!auth.isLoggedIn) {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
    return;
  }

  final oldC = TextEditingController();
  final newC = TextEditingController();
  final confirmC = TextEditingController();

  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Ganti kata sandi'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: oldC,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Kata sandi lama'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: newC,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Kata sandi baru'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: confirmC,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Konfirmasi kata sandi baru'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            final oldPass = oldC.text;
            final newPass = newC.text;
            if (newPass.isEmpty || newPass != confirmC.text) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Konfirmasi kata sandi tidak cocok.')),
              );
              return;
            }
            final ok = auth.changePassword(
              email: auth.email,
              oldPassword: oldPass,
              newPassword: newPass,
            );
            if (!ok) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kata sandi lama salah.')),
              );
              return;
            }
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kata sandi berhasil diperbarui.')),
            );
          },
          child: const Text('Simpan'),
        ),
      ],
    ),
  );
}

Future<void> _showAbout(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tentang POLA',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Text(
              'POLA (Polibatam Assistant) membantu menjawab pertanyaan seputar Polibatam '
              'seperti beasiswa, akademik, jurusan, laboratorium, dan magang.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Versi 1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}

class _AvatarEditor extends StatelessWidget {
  const _AvatarEditor({
    required this.initials,
    required this.avatarBase64,
    required this.onPick,
    required this.onRemove,
  });

  final String initials;
  final String avatarBase64;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final bytes = _tryDecodeImage(avatarBase64);
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 38,
              backgroundColor: cs.primary.withValues(alpha: 0.14),
              backgroundImage: bytes == null ? null : MemoryImage(bytes),
              child: bytes != null
                  ? null
                  : Text(
                      initials,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: IconButton.filledTonal(
                tooltip: 'Ganti foto',
                onPressed: onPick,
                icon: const Icon(Icons.photo_camera_outlined),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: avatarBase64.isEmpty ? null : onRemove,
          child: const Text('Hapus foto'),
        ),
      ],
    );
  }
}

String _initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  final letters = parts.take(2).map((p) => p.characters.first).toList();
  if (letters.isEmpty) return 'P';
  return letters.join().toUpperCase();
}

String _encodeImage(List<int> bytes) =>
    'data:image/jpeg;base64,${base64Encode(bytes)}';

Uint8List? _tryDecodeImage(String base64DataUrl) {
  if (base64DataUrl.isEmpty) return null;
  try {
    final idx = base64DataUrl.indexOf('base64,');
    final payload = idx == -1
        ? base64DataUrl
        : base64DataUrl.substring(idx + 'base64,'.length);
    return base64Decode(payload);
  } catch (_) {
    return null;
  }
}
