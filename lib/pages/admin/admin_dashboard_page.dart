import 'package:flutter/material.dart';

import '../../app/app_state_scope.dart';
import '../../services/admin_kb_store.dart';
import '../../ui/theme/pola_colors.dart';
import '../../widgets/pola_logo.dart';
import '../profile/chat_history_page.dart';
import '../login_page.dart';

/// Dashboard admin POLA — FAQ, monitoring, dan kelola admin.
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  static const _store = AdminKbStore();

  late final TabController _tabs;
  bool _loading = true;
  List<AdminKbEntry> _entries = const [];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
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
                  decoration: const InputDecoration(labelText: 'Pertanyaan'),
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: a,
                  decoration: const InputDecoration(labelText: 'Jawaban'),
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
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus FAQ?'),
        content: const Text('Entri FAQ ini akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _entries = _entries.where((e) => e.id != id).toList());
    await _save();
  }

  Future<void> _grantAdmin() async {
    final auth = AppStateScope.of(context).auth;
    final controller = TextEditingController();
    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Admin'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Email pengguna',
            hintText: 'nama@polibatam.ac.id',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Grant Admin'),
          ),
        ],
      ),
    );
    if (email == null || email.isEmpty) return;
    await auth.grantAdmin(email);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Admin diberikan ke $email')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = AppStateScope.of(context).auth;
    final chat = AppStateScope.of(context).chat;
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: Listenable.merge([auth, chat]),
      builder: (context, _) {
        if (!auth.isAdmin) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline, size: 48, color: cs.error),
                    const SizedBox(height: 12),
                    const Text(
                      'Akses Admin Ditolak',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Silakan login dengan akun admin.',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (_) => const LoginPage(),
                        ),
                      ),
                      child: const Text('Masuk lewat Login / Daftar'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final messageCount = chat.conversations.fold<int>(
          0,
          (sum, c) => sum + c.messages.length,
        );

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverAppBar(
                expandedHeight: 168,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [PolaColors.primary, PolaColors.secondary],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const PolaLogo(size: 44),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Admin Dashboard',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 20,
                                        ),
                                      ),
                                      Text(
                                        auth.email,
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.9),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Keluar Admin',
                                  onPressed: () async {
                                    await auth.logout();
                                    if (!context.mounted) return;
                                    Navigator.of(context).pop();
                                  },
                                  icon: const Icon(Icons.logout_rounded,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              'Implementasi Chatbot AI — POLA Mobile',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                bottom: TabBar(
                  controller: _tabs,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: const [
                    Tab(text: 'Ringkasan'),
                    Tab(text: 'FAQ'),
                    Tab(text: 'Riwayat Chat'),
                    Tab(text: 'Kelola Admin'),
                  ],
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabs,
              children: [
                _OverviewTab(
                  conversationCount: chat.conversations.length,
                  messageCount: messageCount,
                  faqCount: _entries.length,
                ),
                _FaqTab(
                  loading: _loading,
                  entries: _entries,
                  onAdd: () => _addOrEdit(),
                  onEdit: (e) => _addOrEdit(existing: e),
                  onDelete: _delete,
                ),
                const ChatHistoryPage(),
                _AdminManageTab(onGrant: _grantAdmin),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.conversationCount,
    required this.messageCount,
    required this.faqCount,
  });

  final int conversationCount;
  final int messageCount;
  final int faqCount;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.forum_outlined,
                label: 'Percakapan',
                value: '$conversationCount',
                color: PolaColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: Icons.chat_bubble_outline,
                label: 'Pesan',
                value: '$messageCount',
                color: PolaColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _StatCard(
          icon: Icons.quiz_outlined,
          label: 'FAQ Admin',
          value: '$faqCount',
          color: PolaColors.success,
          fullWidth: true,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tugas Admin',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 10),
                const _TaskRow(
                  icon: Icons.library_books_outlined,
                  text: 'Kelola FAQ / Knowledge Base chatbot',
                ),
                const _TaskRow(
                  icon: Icons.history_rounded,
                  text: 'Pantau riwayat percakapan pengguna',
                ),
                const _TaskRow(
                  icon: Icons.admin_panel_settings_outlined,
                  text: 'Tambah admin baru berdasarkan email',
                ),
                const _TaskRow(
                  icon: Icons.settings_suggest_outlined,
                  text: 'Konfigurasi sistem via backend & Supabase',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.fullWidth = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: PolaColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _FaqTab extends StatelessWidget {
  const _FaqTab({
    required this.loading,
    required this.entries,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final bool loading;
  final List<AdminKbEntry> entries;
  final VoidCallback onAdd;
  final void Function(AdminKbEntry) onEdit;
  final void Function(String) onDelete;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Manajemen FAQ (${entries.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Tambah'),
              ),
            ],
          ),
        ),
        Expanded(
          child: entries.isEmpty
              ? const Center(child: Text('Belum ada FAQ admin.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final e = entries[i];
                    return Card(
                      child: ListTile(
                        title: Text(
                          e.question,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(
                          e.answer,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == 'edit') onEdit(e);
                            if (v == 'delete') onDelete(e.id);
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(value: 'delete', child: Text('Hapus')),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _AdminManageTab extends StatelessWidget {
  const _AdminManageTab({required this.onGrant});

  final VoidCallback onGrant;

  @override
  Widget build(BuildContext context) {
    final auth = AppStateScope.of(context).auth;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: PolaColors.primary.withValues(alpha: 0.12),
              child: const Icon(Icons.person, color: PolaColors.primary),
            ),
            title: Text(auth.displayName),
            subtitle: Text('${auth.email} · Admin aktif'),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tambah Admin Baru',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Masukkan email pengguna yang sudah terdaftar. '
                  'Pengguna tersebut akan mendapat role admin.',
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: onGrant,
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: const Text('Grant Admin'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          color: PolaColors.primary.withValues(alpha: 0.06),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Akun Demo (Mode Lokal)',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 8),
                Text('Email: admin@pola.app'),
                Text('Password: admin12345'),
                SizedBox(height: 8),
                Text('Akun Supabase: admin@polibatam.ac.id / AdminPola2026!'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
