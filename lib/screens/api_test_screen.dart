import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/status_provider.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<StatusProvider>().fetchStatuses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StatusProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Status API Test')),

      body: Builder(
        builder: (context) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error.isNotEmpty) {
            return Center(child: Text(provider.error));
          }

          if (provider.statuses.isEmpty) {
            return const Center(child: Text('No Status Found'));
          }

          return ListView.builder(
            itemCount: provider.statuses.length,
            itemBuilder: (context, index) {
              final status = provider.statuses[index];

              return Material(
                color: Colors.transparent,
                child: ListTile(
                  title: Text(status.name),
                  subtitle: Text('ID: ${status.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
