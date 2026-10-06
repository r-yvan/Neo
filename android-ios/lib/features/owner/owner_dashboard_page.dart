import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OwnerDashboardPage extends ConsumerWidget {
  const OwnerDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Owner Dashboard')),
      body: const Center(
        child: Text('Owner Dashboard - Coming Soon'),
      ),
    );
  }
}
