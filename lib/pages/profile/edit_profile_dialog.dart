import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/app_state_scope.dart';

/// Dialog edit profil: foto, nama, username, program studi / institusi.
Future<void> showEditProfileDialog(BuildContext context) async {
  final auth = AppStateScope.of(context).auth;
  final settings = AppStateScope.of(context).settings;

  final effectiveName = settings.profileName.isNotEmpty
      ? settings.profileName
      : auth.displayName;
  final handleBase = settings.username.isNotEmpty
      ? settings.username
      : auth.email.split('@').first;

  final nameController = TextEditingController(text: effectiveName);
  final userController = TextEditingController(text: handleBase);
  final prodiController = TextEditingController(text: settings.programStudi);

  final result = await showDialog<Object?>(
    context: context,
    builder: (context) {
      var newAvatar = settings.avatarBase64;
      return StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Edit Profil'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _AvatarEditor(
                  initials: _initialsOf(effectiveName),
                  avatarBase64: newAvatar,
                  onPickGallery: () async {
                    await _pickAvatar(setStateDialog, (v) => newAvatar = v);
                  },
                  onPickCamera: () async {
                    await _pickAvatar(
                      setStateDialog,
                      (v) => newAvatar = v,
                      fromCamera: true,
                    );
                  },
                  onRemove: () => setStateDialog(() => newAvatar = ''),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: userController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: prodiController,
                  decoration: const InputDecoration(
                    labelText: 'Program Studi / Institusi',
                    hintText: 'Opsional',
                  ),
                ),
              ],
            ),
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
    await settings.setProgramStudi(prodiController.text);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui.')),
      );
    }
  }

  nameController.dispose();
  userController.dispose();
  prodiController.dispose();
}

Future<void> _pickAvatar(
  void Function(void Function()) setStateDialog,
  void Function(String) onResult, {
  bool fromCamera = false,
}) async {
  final picker = ImagePicker();
  final image = await picker.pickImage(
    source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    maxWidth: 512,
    imageQuality: 85,
  );
  if (image == null) return;
  final bytes = await image.readAsBytes();
  setStateDialog(() => onResult(_encodeImage(bytes)));
}

class _AvatarEditor extends StatelessWidget {
  const _AvatarEditor({
    required this.initials,
    required this.avatarBase64,
    required this.onPickGallery,
    required this.onPickCamera,
    required this.onRemove,
  });

  final String initials;
  final String avatarBase64;
  final VoidCallback onPickGallery;
  final VoidCallback onPickCamera;
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
              radius: 44,
              backgroundColor: cs.primary.withValues(alpha: 0.14),
              backgroundImage: bytes == null ? null : MemoryImage(bytes),
              child: bytes != null
                  ? null
                  : Text(
                      initials,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: onPickGallery,
              icon: const Icon(Icons.photo_library_outlined, size: 18),
              label: const Text('Galeri'),
            ),
            TextButton.icon(
              onPressed: onPickCamera,
              icon: const Icon(Icons.photo_camera_outlined, size: 18),
              label: const Text('Kamera'),
            ),
          ],
        ),
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
  final letters = parts.take(2).map((p) => p[0]).toList();
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
