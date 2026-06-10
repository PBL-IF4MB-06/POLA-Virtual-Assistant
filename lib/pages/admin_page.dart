import 'package:flutter/material.dart';

import '../app/app_state_scope.dart';
import '../services/admin_kb_store.dart';
import '../ui/theme/pola_tokens.dart';
import '../ui/widgets/pola_background.dart';
import '../widgets/pola_logo.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  static const _store = AdminKbStore();

  bool _loading = true;
  List<AdminKbEntry> _entries = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await _store.load();
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  Future<void> _save() async {
    await _store.save(_entries);
  }

  Future<void> _addOrEdit({AdminKbEntry? existing}) async {
    final q = TextEditingController(text: existing?.question ?? '');
    final a = TextEditingController(text: existing?.answer ?? '');
    final res = await showModalBottomSheet<AdminKbEntry>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  existing == null ? 'Tambah FAQ' : 'Edit FAQ',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: q,
                  decoration: const InputDecoration(
                    labelText: 'Pertanyaan (judul)',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: a,
                  decoration: const InputDecoration(
                    labelText: 'Jawaban (konten)',
                  ),
                  maxLines: 6,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          final qq = q.text.trim();
                          final aa = a.text.trim();
                          if (qq.isEmpty || aa.isEmpty) return;
                          Navigator.of(context).pop(
                            AdminKbEntry(
                              id: existing?.id ?? AdminKbStore.newId(),
                              question: qq,
                              answer: aa,
                            ),
                          );
                        },
                        child: const Text('Simpan'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || res == null) return;
    setState(() {
      final idx = _entries.indexWhere((e) => e.id == res.id);
      if (idx >= 0) {
        _entries = [..._entries]..[idx] = res;
      } else {
        _entries = [res, ..._entries];
      }
    });
    await _save();
  }

  Future<void> _delete(String id) async {
    setState(() => _entries = _entries.where((e) => e.id != id).toList());
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    final auth = AppStateScope.of(context).auth;
    final chat = AppStateScope.of(context).chat;
    final cs = Theme.of(context).colorScheme;

    if (!auth.isAdmin) {
      return Center(
        child: Padding(
          padding: PolaTokens.pagePadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 40, color: cs.onSurfaceVariant),
              const SizedBox(height: 10),
              Text(
                'Admin only',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                'Login sebagai admin untuk mengakses panel ini.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    return PolaBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          title: Row(
            children: [
              const PolaLogo(size: 40),
              const SizedBox(width: 10),
              const Text('Admin Panel'),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Tambah FAQ',
              onPressed: _loading ? null : () => _addOrEdit(),
              icon: const Icon(Icons.add_circle_outline),
            ),
            const SizedBox(width: 6),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: PolaTokens.pagePadding,
                children: [
                  _GlassCard(
                    child: Row(
                      children: [
                        Icon(Icons.monitor_heart_outlined, color: cs.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Monitoring: ${chat.conversations.length} percakapan tersimpan di perangkat ini.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _GlassCard(
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome, color: cs.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'FAQ yang kamu buat di sini akan jadi sumber lokal tambahan untuk Copilot.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Kelola Admin',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  _GlassCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Tambah admin baru dengan email',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final controller = TextEditingController();
                            final email = await showDialog<String>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Grant admin'),
                                content: TextField(
                                  controller: controller,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    hintText: 'nama@polibatam.ac.id',
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Batal'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.of(context)
                                        .pop(controller.text.trim()),
                                    child: const Text('Grant'),
                                  ),
                                ],
                              ),
                            );
                            if (email != null && email.trim().isNotEmpty) {
                              await auth.grantAdmin(email.trim());
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Admin granted.')),
                              );
                            }
                          },
                          icon: const Icon(Icons.admin_panel_settings_outlined),
                          label: const Text('Grant'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Konten Chatbot (FAQ)',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      Text(
                        '${_entries.length} item',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_entries.isEmpty)
                    Text(
                      'Belum ada FAQ admin.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  for (final e in _entries) ...[
                    const SizedBox(height: 10),
                    _GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  e.question,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Edit',
                                onPressed: () => _addOrEdit(existing: e),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                tooltip: 'Hapus',
                                onPressed: () => _delete(e.id),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            e.answer,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
      ),
    );
  }
}

// (moved to AdminKbStore)

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: cs.surface.withValues(alpha: 0.82),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
        boxShadow: PolaTokens.softShadow(Colors.black),
      ),
      child: child,
    );
  }
}

