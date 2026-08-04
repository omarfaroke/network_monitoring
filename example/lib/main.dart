import 'package:flutter/material.dart';
import 'package:network_monitoring/network_monitoring.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app.dart';
import 'config/app_config.dart';
import 'server/notes_server.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/note_seed_service.dart';
import 'views/unsupported_platform_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!AppConfig.isMobilePlatform) {
    runApp(const UnsupportedPlatformView());
    return;
  }

  NetworkMonitoring.initialize(
    config: NetworkMonitoringConfig(
      shareContent: (context, content) {
        SharePlus.instance.share(ShareParams(text: content));
      },
      openUrl: (url) async {
        final uri = Uri.parse(url);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      requiredTaps: AppConfig.devModeRequiredTaps,
      validatePasswordInput: (password) => password == AppConfig.devModePassword,
      brandColor: Colors.teal,
    ),
  );

  ApiClient.instance.configure();

  // Start local API server (JWT + notes CRUD) in the same process.
  await NotesServer.start();

  await NoteSeedService.instance.seedIfNeeded();
  await NotesServer.reloadFromCache();

  final session = await AuthService.instance.restoreSession();

  runApp(NotesApp(isLoggedIn: session != null));
}
