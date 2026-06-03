import 'package:flutter_test/flutter_test.dart';
import 'package:notes_example/data/note_seed_data.dart';

void main() {
  test('NoteSeedData provides 10 seed notes', () {
    expect(NoteSeedData.seedCount, 10);
    expect(NoteSeedData.items.length, NoteSeedData.seedCount);
  });

  test('toNoteMaps returns one map per seed item', () {
    final maps = NoteSeedData.toNoteMaps(baseDate: DateTime(2025, 6, 1));
    expect(maps.length, 10);
    expect(maps.first['title'], NoteSeedData.items.first.title);
  });
}
