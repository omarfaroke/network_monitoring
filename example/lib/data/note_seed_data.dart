import '../models/note_model.dart';

/// One row of seed content (no server id until persisted).
class NoteSeedItem {
  final String title;
  final String description;
  final String category;

  const NoteSeedItem({
    required this.title,
    required this.description,
    required this.category,
  });
}

/// Ten demo notes inserted on first app launch.
abstract class NoteSeedData {
  static const int seedCount = 10;

  static const List<NoteSeedItem> items = [
    NoteSeedItem(
      title: 'Welcome',
      description:
          'This note was created on first launch. Try editing or deleting it.',
      category: 'Personal',
    ),
    NoteSeedItem(
      title: 'Sprint planning',
      description: 'Review backlog and assign tasks for the week.',
      category: 'Work',
    ),
    NoteSeedItem(
      title: 'Book ideas',
      description: 'Sci-fi novel about a debugger that gains sentience.',
      category: 'Ideas',
    ),
    NoteSeedItem(
      title: 'Grocery list',
      description: 'Milk, eggs, coffee beans, avocados, pasta.',
      category: 'Personal',
    ),
    NoteSeedItem(
      title: 'API design sketch',
      description: 'Draft endpoints for notes CRUD and JWT login flow.',
      category: 'Work',
    ),
    NoteSeedItem(
      title: 'Weekend hike',
      description: 'Trail map, water, snacks, leave by 7am.',
      category: 'Personal',
    ),
    NoteSeedItem(
      title: 'Podcast topics',
      description: 'Flutter networking, local servers, and dev tooling.',
      category: 'Ideas',
    ),
    NoteSeedItem(
      title: 'Code review checklist',
      description: 'Tests, naming, error handling, and security review.',
      category: 'Work',
    ),
    NoteSeedItem(
      title: 'Birthday gift',
      description: 'Wireless earbuds or a nice notebook.',
      category: 'Personal',
    ),
    NoteSeedItem(
      title: 'Refactor notes service',
      description: 'Extract seeding and tighten Dio interceptor order.',
      category: 'Work',
    ),
  ];

  /// Builds server-ready maps with sequential ids and timestamps.
  static List<Map<String, dynamic>> toNoteMaps({
    DateTime? baseDate,
  }) {
    final base = baseDate ?? DateTime(2025, 1, 1);
    return List.generate(items.length, (index) {
      final item = items[index];
      final created = base.add(Duration(days: index));
      final updated = created.add(Duration(hours: index % 5));
      return {
        NoteModelFields.id: index + 1,
        NoteModelFields.title: item.title,
        NoteModelFields.description: item.description,
        NoteModelFields.category: item.category,
        NoteModelFields.createdAt: created.toIso8601String(),
        NoteModelFields.updatedAt: updated.toIso8601String(),
      };
    });
  }
}
