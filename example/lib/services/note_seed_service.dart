import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../data/note_seed_data.dart';
import 'auth_service.dart';
import 'notes_service.dart';

/// Inserts [NoteSeedData.seedCount] seed notes on the first app launch.
class NoteSeedService {
  NoteSeedService._();

  static final NoteSeedService instance = NoteSeedService._();

  static const _seededKey = 'notes_seeded_v1';

  Future<void> seedIfNeeded() {
    return seedIfNeededWith(
      notesService: NotesService.instance,
      authService: AuthService.instance,
    );
  }

  Future<void> seedIfNeededWith({
    required NotesService notesService,
    required AuthService authService,
    SharedPreferences? prefs,
  }) async {
    final storage = prefs ?? await SharedPreferences.getInstance();
    if (storage.getBool(_seededKey) ?? false) return;

    if (authService.currentUser == null) {
      await authService.login(
        username: AppConfig.defaultUsername,
        password: AppConfig.defaultPassword,
      );
    }

    for (final item in NoteSeedData.items) {
      await notesService.createNote(
        title: item.title,
        description: item.description,
        category: item.category,
      );
    }

    await storage.setBool(_seededKey, true);
  }
}
