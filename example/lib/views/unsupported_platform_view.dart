import 'package:flutter/material.dart';

import '../config/app_config.dart';

/// Shown when the example is launched on a non-mobile platform.
class UnsupportedPlatformView extends StatelessWidget {
  const UnsupportedPlatformView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              '${AppConfig.appName} supports Android and iOS only.\n\n'
              'Run: flutter run -d <android|ios device>',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
      ),
    );
  }
}
