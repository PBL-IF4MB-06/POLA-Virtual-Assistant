import 'package:flutter/material.dart';

import '../ui/widgets/pola_background_v4.dart';
import 'copilot_v4_page.dart';
import 'home_v4_page.dart';
import 'settings_v4_page.dart';

class AppShellV4 extends StatefulWidget {
  const AppShellV4({super.key});

  @override
  State<AppShellV4> createState() => _AppShellV4State();
}

class _AppShellV4State extends State<AppShellV4> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      HomeV4Page(),
      CopilotV4Page(),
      SettingsV4Page(),
    ];

    return PolaBackgroundV4(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: IndexedStack(index: _index, children: pages),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble_rounded),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(Icons.tune_outlined),
              selectedIcon: Icon(Icons.tune),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

