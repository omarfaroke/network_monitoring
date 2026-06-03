import '../models/note_model.dart';
import 'api_client.dart';

class NotesService {
  NotesService._();

  static final NotesService instance = NotesService._();

  Future<List<NoteModel>> fetchNotes({
    String? category,
    String? search,
  }) async {
    final response = await ApiClient.instance.dio.get(
      '/api/notes',
      queryParameters: {
        if (category != null && category.isNotEmpty) 'category': category,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    final list = (response.data['notes'] as List<dynamic>)
        .map((e) => NoteModel.fromMap(e as Map<String, dynamic>))
        .toList();
    return list;
  }

  Future<NoteModel> fetchNote(int id) async {
    final response = await ApiClient.instance.dio.get('/api/notes/$id');
    return NoteModel.fromMap(response.data as Map<String, dynamic>);
  }

  Future<List<String>> fetchCategories() async {
    final response = await ApiClient.instance.dio.get('/api/categories');
    return (response.data['categories'] as List<dynamic>).cast<String>();
  }

  Future<NoteModel> createNote({
    required String title,
    required String description,
    required String category,
  }) async {
    final response = await ApiClient.instance.dio.post(
      '/api/notes',
      data: {
        NoteModelFields.title: title,
        NoteModelFields.description: description,
        NoteModelFields.category: category,
      },
    );
    return NoteModel.fromMap(response.data as Map<String, dynamic>);
  }

  Future<NoteModel> updateNote(NoteModel note) async {
    final response = await ApiClient.instance.dio.put(
      '/api/notes/${note.id}',
      data: note.toMap(),
    );
    return NoteModel.fromMap(response.data as Map<String, dynamic>);
  }

  Future<void> deleteNote(int id) async {
    await ApiClient.instance.dio.delete('/api/notes/$id');
  }
}
