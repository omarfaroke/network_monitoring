import 'package:flutter_test/flutter_test.dart';
import 'package:notes_example/models/note_model.dart';

void main() {
  test('NoteModel round-trip via map', () {
    final note = NoteModel(
      id: 1,
      title: 'Test',
      description: 'Body',
      category: 'Work',
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 2),
    );

    final restored = NoteModel.fromMap(note.toMap());
    expect(restored.id, note.id);
    expect(restored.title, note.title);
    expect(restored.category, note.category);
  });
}
