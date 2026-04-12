import 'package:flutter/material.dart';

import '../app/app_state_scope.dart';
import 'admin_page.dart';
import 'copilot_page.dart';
import 'dashboard_page.dart';
import 'settings_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final chat = AppStateScope.of(context).chat;
    final auth = AppStateScope.of(context).auth;

    final pages = <Widget>[
      DashboardPage(
        onOpenCopilot: () => setState(() => _index = 1),
      ),
      const CopilotPage(),
      const SettingsPage(),
      if (auth.isAdmin) const AdminPage(),
    ];

    return AnimatedBuilder(
      animation: chat,
      builder: (context, _) {
        return Scaffold(
          body: SafeArea(
            child: IndexedStack(index: _index, children: pages),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: 'Dashboard',
              ),
              const NavigationDestination(
                icon: Icon(Icons.auto_awesome_outlined),
                selectedIcon: Icon(Icons.auto_awesome),
                label: 'Copilot',
              ),
              const NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
              if (auth.isAdmin)
                const NavigationDestination(
                  icon: Icon(Icons.admin_panel_settings_outlined),
                  selectedIcon: Icon(Icons.admin_panel_settings),
                  label: 'Admin',
                ),
            ],
          ),
        );
      },
    );
  }
}

