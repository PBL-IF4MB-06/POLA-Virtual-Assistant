import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/app_state_scope.dart';
import '../../services/backend_health_service.dart';
import '../../ui/theme/pola_colors.dart';
import '../chat_page.dart';
import '../profile/chat_history_page.dart';

class ChatTabPage extends StatefulWidget {
  const ChatTabPage({super.key});

  /// Key global agar shell bisa kirim prompt meski context di atas IndexedStack.
  static final GlobalKey pageKey = GlobalKey();

  static void sendPrompt(BuildContext context, String prompt) {
    final state = pageKey.currentState;
    if (state is _ChatTabPageState) {
      state._sendPrompt(prompt);
      return;
    }
    context.findAncestorStateOfType<_ChatTabPageState>()?._sendPrompt(prompt);
  }

  @override
  State<ChatTabPage> createState() => _ChatTabPageState();
}

class _ChatTabPageState extends State<ChatTabPage> {
  bool? _backendOnline;
  Timer? _healthTimer;

  @override
  void initState() {
    super.initState();
    _checkBackend();
    _healthTimer = Timer.periodic(const Duration(seconds: 30), (_) => _checkBackend());
  }

  @override
  void dispose() {
    _healthTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkBackend() async {
    final online = await BackendHealthService.isOnline();
    if (mounted) setState(() => _backendOnline = online);
  }

  Future<void> _sendPrompt(String prompt) async {
    await AppStateScope.of(context).chat.sendUserMessage(prompt);
  }

  @override
  Widget build(BuildContext context) {
    final chat = AppStateScope.of(context).chat;
    final online = _backendOnline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SafeArea(
          bottom: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [PolaColors.primary, PolaColors.secondary],
                    ),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Chatbot POLA',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                if (online == false)
                  IconButton(
                    tooltip: 'Cek ulang koneksi',
                    onPressed: _checkBackend,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                IconButton(
                  tooltip: 'Chat baru',
                  onPressed: chat.startNewConversation,
                  icon: const Icon(Icons.add_comment_outlined),
                ),
                IconButton(
                  tooltip: 'Riwayat',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const ChatHistoryPage()),
                  ),
                  icon: const Icon(Icons.history_rounded),
                ),
              ],
            ),
          ),
        ),
        if (online == false)
          MaterialBanner(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            content: const Text(
              'Backend AI belum berjalan. Jalankan server/ di folder server.',
            ),
            leading: const Icon(Icons.cloud_off_outlined, size: 20),
            actions: [
              TextButton(onPressed: _checkBackend, child: const Text('Coba lagi')),
            ],
          ),
        const Expanded(child: ChatPage(showFeatureHeader: true)),
      ],
    );
  }
}
