import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PublicProfilePage extends ConsumerWidget {
  const PublicProfilePage({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Public Profile')),
      body: Center(
        child: Text('Public Profile for $userId - Coming Soon'),
      ),
    );
  }
}
