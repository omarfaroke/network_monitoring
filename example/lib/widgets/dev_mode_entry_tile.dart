import 'package:flutter/material.dart';
import 'package:network_monitoring/network_monitoring.dart';

/// Shown when dev mode is enabled; opens [DevModeOptionsView].
class DevModeEntryTile extends StatelessWidget {
  const DevModeEntryTile({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkMonitoringBuilder(
      listenTo: NetworkMonitorChanges.devMode,
      builder: (context, controller) {
        if (!controller.isDevModeEnabled) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Icon(
              Icons.developer_mode,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Network Dev Mode'),
            subtitle: const Text('Inspect HTTP traffic and breakpoints'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => DevModeOptionsView.push(context),
          ),
        );
      },
    );
  }
}
