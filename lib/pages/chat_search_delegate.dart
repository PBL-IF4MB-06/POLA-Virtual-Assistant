import 'package:flutter/material.dart';

import '../models/chat_message.dart';

class ChatSearchDelegate extends SearchDelegate<ChatMessage?> {
  ChatSearchDelegate({required List<ChatMessage> messages})
      : _messages = messages.where((m) => m.text.trim().isNotEmpty).toList();

  final List<ChatMessage> _messages;

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            tooltip: 'Clear',
            onPressed: () => query = '',
            icon: const Icon(Icons.clear),
          ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        tooltip: 'Back',
        onPressed: () => close(context, null),
        icon: const Icon(Icons.arrow_back),
      );

  @override
  Widget buildResults(BuildContext context) => _results(context);

  @override
  Widget buildSuggestions(BuildContext context) => _results(context);

  Widget _results(BuildContext context) {
    final q = query.trim().toLowerCase();
    final hits = q.isEmpty
        ? const <ChatMessage>[]
        : _messages
            .where((m) => m.text.toLowerCase().contains(q))
            .take(30)
            .toList();

    if (q.isEmpty) {
      return const Center(child: Text('Ketik kata untuk mencari di chat.'));
    }
    if (hits.isEmpty) {
      return const Center(child: Text('Tidak ada hasil.'));
    }

    return ListView.separated(
      itemCount: hits.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final m = hits[i];
        return ListTile(
          leading: Icon(m.sender == Sender.user ? Icons.person : Icons.auto_awesome),
          title: Text(
            m.text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(m.createdAt.toLocal().toString()),
          onTap: () => close(context, m),
        );
      },
    );
  }
}

