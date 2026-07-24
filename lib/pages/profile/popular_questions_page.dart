import 'package:flutter/material.dart';

import '../../app/shell_scope.dart';
import '../../data/popular_questions.dart';

class PopularQuestionsPage extends StatelessWidget {
  const PopularQuestionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pertanyaan Populer')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: PopularQuestions.all.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final q = PopularQuestions.all[i];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text('${i + 1}'),
              ),
              title: Text(q.question),
              subtitle: Text('${q.category} • ${q.askCount} kali ditanyakan'),
              trailing: const Icon(Icons.auto_awesome_outlined),
              onTap: () {
                ShellScope.of(context).goToTab(
                  ShellTab.chat,
                  chatPrompt: q.question,
                );
                Navigator.of(context).pop();
              },
            ),
          );
        },
      ),
    );
  }
}
