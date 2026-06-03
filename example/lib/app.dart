import 'package:flutter/material.dart';
import 'package:network_monitoring/network_monitoring.dart';

import 'config/app_config.dart';
import 'views/login_view.dart';
import 'views/main_shell_view.dart';

class NotesApp extends StatelessWidget {
  final bool isLoggedIn;

  const NotesApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return NetworkMonitorOverlayWrapper(child: child!);
      },
      home: isLoggedIn ? const MainShellView() : const LoginView(),
    );
  }
}
