import 'package:flutter/material.dart';

import '../app/shell_scope.dart';
import 'campus/campus_hub_page.dart';
import 'chat/chat_tab_page.dart';
import 'home/home_dashboard_page.dart';
import 'profile/profile_hub_page.dart';

/// Shell demo PBL: Beranda · Chatbot · Layanan · Profil
class AppShellV8 extends StatefulWidget {
  const AppShellV8({super.key});

  @override
  State<AppShellV8> createState() => _AppShellV8State();
}

class _AppShellV8State extends State<AppShellV8> {
  int _index = 0;
  String? _pendingChatPrompt;

  void _goToTab(ShellTab tab, {String? chatPrompt}) {
    final idx = switch (tab) {
      ShellTab.home => 0,
      ShellTab.chat => 1,
      ShellTab.campus => 2,
      ShellTab.profile => 3,
    };
    setState(() {
      _index = idx;
      if (chatPrompt != null && chatPrompt.trim().isNotEmpty) {
        _pendingChatPrompt = chatPrompt.trim();
      }
    });
  }

  void _consumeChatPrompt() {
    final prompt = _pendingChatPrompt;
    if (prompt == null) return;
    _pendingChatPrompt = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ChatTabPage.sendPrompt(context, prompt);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_index == 1 && _pendingChatPrompt != null) {
      _consumeChatPrompt();
    }

    return ShellScope(
      goToTab: _goToTab,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: IndexedStack(
          index: _index,
          children: [
            const HomeDashboardPage(),
            ChatTabPage(key: ChatTabPage.pageKey),
            const CampusHubPage(),
            const ProfileHubPage(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(Icons.smart_toy_outlined),
              selectedIcon: Icon(Icons.smart_toy_rounded),
              label: 'Chatbot',
            ),
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view_rounded),
              label: 'Layanan',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
