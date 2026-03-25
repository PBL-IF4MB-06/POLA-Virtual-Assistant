import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../app/app_state_scope.dart';
import 'login_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AppStateScope.of(context).auth;
    final theme = AppStateScope.of(context).theme;
    final chat = AppStateScope.of(context).chat;
    final settings = AppStateScope.of(context).settings;
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: Listenable.merge([auth, settings, theme]),
      builder: (context, _) {
        final effectiveName =
            settings.profileName.isNotEmpty ? settings.profileName : auth.displayName;
        final handleBase = settings.username.isNotEmpty
            ? settings.username
            : (auth.email.split('@').first);
        final handle = '@$handleBase';

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          children: [
            _ProfileHeader(
              initials: _initialsOf(effectiveName),
              name: effectiveName,
              handle: handle,
              avatarBase64: settings.avatarBase64,
              onEdit: () async {
                final nameController = TextEditingController(text: effectiveName);
                final userController = TextEditingController(text: handleBase);
                final result = await showDialog<Object?>(
                  context: context,
                  builder: (context) {
                    var newAvatar = settings.avatarBase64;
                    return StatefulBuilder(
                      builder: (context, setStateDialog) {
                        return AlertDialog(
                          title: const Text('Edit profil'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: _AvatarEditor(
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
                                    setStateDialog(() {
                                      newAvatar = _encodeImage(bytes);
                                    });
                                  },
                                  onRemove: () => setStateDialog(() {
                                    newAvatar = '';
                                  }),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: nameController,
                                decoration:
                                    const InputDecoration(labelText: 'Nama'),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: userController,
                                decoration: const InputDecoration(
                                  labelText: 'Username',
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
                              onPressed: () {
                                Navigator.of(context).pop(newAvatar);
                              },
                              child: const Text('Simpan'),
                            ),
                          ],
                        );
                      },
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
              },
            ),
            const SizedBox(height: 18),
            _SectionTitle('Akun'),
            const SizedBox(height: 8),
            _SectionCard(
              children: [
                _ValueTile(
                  leading: Icons.email_outlined,
                  title: 'Email',
                  value: auth.email,
                  onTap: () async {
                    if (!auth.isLoggedIn) {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                      return;
                    }
                    _comingSoon(context, 'Kelola email');
                  },
                ),
                if (!auth.isLoggedIn)
                  _NavTile(
                    leading: Icons.login,
                    title: 'Login / Register',
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                  )
                else
                  _NavTile(
                    leading: Icons.logout,
                    title: 'Logout',
                    onTap: auth.logout,
                  ),
                _NavTile(
                  leading: Icons.verified_user_outlined,
                  title: 'Verifikasi usia',
                  onTap: () => _comingSoon(context, 'Verifikasi usia'),
                ),
                _ValueTile(
                  leading: Icons.card_membership_outlined,
                  title: 'Langganan',
                  value: 'Paket Free',
                  onTap: () => _comingSoon(context, 'Langganan'),
                ),
                _NavTile(
                  leading: Icons.workspace_premium_outlined,
                  title: 'Upgrade ke POLA Pro',
                  titleColor: colorScheme.primary,
                  onTap: () => _comingSoon(context, 'Upgrade'),
                ),
                _NavTile(
                  leading: Icons.restore_outlined,
                  title: 'Pulihkan pembelian',
                  onTap: () => _comingSoon(context, 'Pulihkan pembelian'),
                ),
                _NavTile(
                  leading: Icons.tune_outlined,
                  title: 'Personalisasi',
                  onTap: () => _comingSoon(context, 'Personalisasi'),
                ),
                _NavTile(
                  leading: Icons.notifications_outlined,
                  title: 'Notifikasi',
                  onTap: () => _comingSoon(context, 'Notifikasi'),
                ),
                _NavTile(
                  leading: Icons.grid_view_outlined,
                  title: 'Aplikasi',
                  onTap: () => _comingSoon(context, 'Aplikasi'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionTitle('Aplikasi'),
            const SizedBox(height: 8),
            _SectionCard(
              children: [
                _ValueTile(
                  leading: Icons.language_outlined,
                  title: 'Bahasa aplikasi',
                  value: settings.appLanguage,
                  onTap: () => _pickOne(
                    context,
                    title: 'Bahasa aplikasi',
                    current: settings.appLanguage,
                    options: const ['Indonesia', 'English'],
                    onSelected: settings.setAppLanguage,
                  ),
                ),
                _ValueTile(
                  leading: Icons.brightness_4_outlined,
                  title: 'Penampilan',
                  value: _themeLabel(theme.mode),
                  onTap: () => _pickThemeMode(context, theme),
                ),
                _ValueTile(
                  leading: Icons.palette_outlined,
                  title: 'Warna aksen',
                  value: _accentLabel(settings.accentIndex),
                  onTap: () => _pickAccent(context, settings, theme),
                ),
                _SwitchTile(
                  leading: Icons.vibration_outlined,
                  title: 'Umpan balik haptik',
                  value: settings.hapticFeedback,
                  onChanged: settings.setHapticFeedback,
                ),
                _SwitchTile(
                  leading: Icons.spellcheck_outlined,
                  title: 'Koreksi ejaan secara otomatis',
                  value: settings.spellCorrection,
                  onChanged: settings.setSpellCorrection,
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionTitle('Ucapan'),
            const SizedBox(height: 8),
            _SectionCard(
              children: [
                _ValueTile(
                  leading: Icons.record_voice_over_outlined,
                  title: 'Suara',
                  value: settings.voice,
                  onTap: () => _pickOne(
                    context,
                    title: 'Suara',
                    current: settings.voice,
                    options: const ['Arbor', 'Nova', 'Ember', 'Breeze'],
                    onSelected: settings.setVoice,
                  ),
                ),
                _SwitchTile(
                  leading: Icons.tune_outlined,
                  title: 'Mode pisah',
                  value: settings.splitMode,
                  onChanged: settings.setSplitMode,
                ),
                _SwitchTile(
                  leading: Icons.play_circle_outline,
                  title: 'Percakapan latar belakang',
                  value: settings.backgroundConversation,
                  onChanged: settings.setBackgroundConversation,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(
                    'Percakapan latar belakang menjaga percakapan tetap berlangsung '
                    'di aplikasi lain atau ketika layar Anda mati.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionTitle('Saran'),
            const SizedBox(height: 8),
            _SectionCard(
              children: [
                _SwitchTile(
                  leading: Icons.auto_awesome_outlined,
                  title: 'Selesai otomatis',
                  value: settings.autoFinish,
                  onChanged: settings.setAutoFinish,
                ),
                _SwitchTile(
                  leading: Icons.trending_up_outlined,
                  title: 'Pencarian sedang tren',
                  value: settings.trendingSearch,
                  onChanged: settings.setTrendingSearch,
                ),
                _SwitchTile(
                  leading: Icons.next_plan_outlined,
                  title: 'Saran tindak lanjut',
                  value: settings.followUpSuggestions,
                  onChanged: settings.setFollowUpSuggestions,
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionTitle('Tentang'),
            const SizedBox(height: 8),
            _SectionCard(
              children: [
                _NavTile(
                  leading: Icons.bug_report_outlined,
                  title: 'Laporkan bug',
                  onTap: () => _comingSoon(context, 'Laporkan bug'),
                ),
                _NavTile(
                  leading: Icons.help_outline,
                  title: 'Pusat Bantuan',
                  onTap: () => _comingSoon(context, 'Pusat Bantuan'),
                ),
                _NavTile(
                  leading: Icons.description_outlined,
                  title: 'Syarat Penggunaan',
                  onTap: () => _comingSoon(context, 'Syarat Penggunaan'),
                ),
                _NavTile(
                  leading: Icons.privacy_tip_outlined,
                  title: 'Kebijakan Privasi',
                  onTap: () => _comingSoon(context, 'Kebijakan Privasi'),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Text(
                    'POLA untuk Android/iOS • v1.0.0',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Hapus riwayat chat'),
                  onTap: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Hapus riwayat chat?'),
                        content: const Text(
                          'Semua percakapan akan dihapus dari perangkat ini.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Batal'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Hapus'),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) {
                      chat.clearAllConversations();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Riwayat chat dihapus.')),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              children: [
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Keluar'),
                  onTap: () {
                    auth.logout();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Anda keluar.')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 90),
          ],
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.initials,
    required this.name,
    required this.handle,
    required this.avatarBase64,
    required this.onEdit,
  });

  final String initials;
  final String name;
  final String handle;
  final String avatarBase64;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final imageBytes = _tryDecodeImage(avatarBase64);
    return Column(
      children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          backgroundImage:
              imageBytes == null ? null : MemoryImage(imageBytes),
          child: imageBytes != null
              ? null
              : Text(
                  initials,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          handle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: onEdit,
          child: const Text('Edit profil'),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(children: _withDividers(children)),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.leading,
    required this.title,
    required this.onTap,
    this.titleColor,
  });

  final IconData leading;
  final String title;
  final VoidCallback onTap;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(leading),
      title: Text(title, style: TextStyle(color: titleColor)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _ValueTile extends StatelessWidget {
  const _ValueTile({
    required this.leading,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData leading;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(leading),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.leading,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData leading;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(leading),
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }
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
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 38,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              backgroundImage: bytes == null ? null : MemoryImage(bytes),
              child: bytes != null
                  ? null
                  : Text(
                      initials,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
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

String _initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  final letters = parts.take(2).map((p) => p.characters.first).toList();
  if (letters.isEmpty) return 'P';
  return letters.join().toUpperCase();
}

String _themeLabel(ThemeMode mode) => switch (mode) {
      ThemeMode.system => 'Sistem',
      ThemeMode.light => 'Terang',
      ThemeMode.dark => 'Gelap',
    };

String _accentLabel(int idx) => switch (idx) {
      0 => 'Default',
      1 => 'Blue',
      2 => 'Green',
      3 => 'Purple',
      4 => 'Orange',
      _ => 'Default',
    };

Color _accentSeed(int idx) => switch (idx) {
      1 => const Color(0xFF2563EB),
      2 => const Color(0xFF16A34A),
      3 => const Color(0xFF7C3AED),
      4 => const Color(0xFFF97316),
      _ => const Color(0xFF005FB8),
    };

Future<void> _comingSoon(BuildContext context, String title) async {
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: const Text(
        'Pengaturan ini saat ini hanya tersedia sebagai preferensi lokal di aplikasi '
        'dan tidak terhubung ke layanan kampus. Nilai pilihan Anda akan tetap '
        'tersimpan di perangkat ini.',
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

Future<void> _pickOne(
  BuildContext context, {
  required String title,
  required String current,
  required List<String> options,
  required Future<void> Function(String) onSelected,
}) async {
  final picked = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(title: Text(title)),
          for (final o in options)
            RadioListTile<String>(
              value: o,
              groupValue: current,
              onChanged: (v) => Navigator.of(context).pop(v),
              title: Text(o),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (picked != null) {
    await onSelected(picked);
  }
}

Future<void> _pickThemeMode(BuildContext context, dynamic theme) async {
  final picked = await showModalBottomSheet<ThemeMode>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(title: Text('Penampilan')),
          RadioListTile<ThemeMode>(
            value: ThemeMode.system,
            groupValue: theme.mode,
            onChanged: (v) => Navigator.of(context).pop(v),
            title: const Text('Sistem'),
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.light,
            groupValue: theme.mode,
            onChanged: (v) => Navigator.of(context).pop(v),
            title: const Text('Terang'),
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.dark,
            groupValue: theme.mode,
            onChanged: (v) => Navigator.of(context).pop(v),
            title: const Text('Gelap'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (picked != null) {
    await theme.setMode(picked);
  }
}

Future<void> _pickAccent(
  BuildContext context,
  dynamic settings,
  dynamic theme,
) async {
  final picked = await showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(title: Text('Warna aksen')),
          for (final idx in const [0, 1, 2, 3, 4])
            RadioListTile<int>(
              value: idx,
              groupValue: settings.accentIndex,
              onChanged: (v) => Navigator.of(context).pop(v),
              title: Text(_accentLabel(idx)),
              secondary: CircleAvatar(
                radius: 10,
                backgroundColor: _accentSeed(idx),
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (picked != null) {
    await settings.setAccentIndex(picked);
    await theme.setSeedColor(_accentSeed(picked));
  }
}
