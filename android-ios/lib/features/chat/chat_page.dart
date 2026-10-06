import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatPage extends ConsumerWidget {
  const ChatPage({
    super.key,
    required this.peer,
    this.bookingId,
  });

  final dynamic peer;
  final String? bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: const Center(
        child: Text('Chat - Coming Soon'),
      ),
    );
  }
}
