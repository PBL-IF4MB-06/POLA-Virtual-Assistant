import 'package:flutter/material.dart';

import '../app/app_state_scope.dart';
import 'admin_page.dart';
import 'dashboard_page.dart';
import 'settings_page.dart';
import 'chat_page.dart';

class AppShellV6 extends StatefulWidget {
  const AppShellV6({super.key});

  @override
  State<AppShellV6> createState() => _AppShellV6State();
}

class _AppShellV6State extends State<AppShellV6> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final auth = AppStateScope.of(context).auth;
    final chat = AppStateScope.of(context).chat;

    final pages = <Widget>[
      DashboardPage(
        onOpenCopilot: () => setState(() => _index = 1),
      ),
      const _CopilotFullPage(),
      const SettingsPage(),
      if (auth.isAdmin) const AdminPage(),
    ];

    return AnimatedBuilder(
      animation: chat,
      builder: (context, _) {
        return Scaffold(
          body: SafeArea(child: IndexedStack(index: _index, children: pages)),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
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

class _CopilotFullPage extends StatelessWidget {
  const _CopilotFullPage();

  @override
  Widget build(BuildContext context) {
    final chat = AppStateScope.of(context).chat;
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'POLA Copilot',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'New chat',
                onPressed: chat.startNewConversation,
                icon: const Icon(Icons.add),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Rename',
                onPressed: () async {
                  final controller = TextEditingController(
                    text: chat.activeConversation.title,
                  );
                  final title = await showDialog<String>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Rename chat'),
                      content: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          labelText: 'Judul chat',
                        ),
                        autofocus: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) =>
                            Navigator.of(context).pop(controller.text.trim()),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Batal'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(context)
                              .pop(controller.text.trim()),
                          child: const Text('Simpan'),
                        ),
                      ],
                    ),
                  );
                  if (title != null && title.trim().isNotEmpty) {
                    chat.renameConversation(chat.activeConversation.id, title);
                  }
                },
                icon: Icon(Icons.edit_outlined, color: cs.onSecondaryContainer),
              ),
            ],
          ),
        ),
        const Expanded(
          child: ChatPage(showFeatureHeader: true),
        ),
      ],
    );
  }
}

