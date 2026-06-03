import 'package:flutter/material.dart';

import '../models/note_model.dart';
import '../services/notes_service.dart';

class AddNoteView extends StatefulWidget {
  final NoteModel? existing;
  final VoidCallback? onSaved;

  const AddNoteView({super.key, this.existing, this.onSaved});

  @override
  State<AddNoteView> createState() => _AddNoteViewState();
}

class _AddNoteViewState extends State<AddNoteView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  static const _defaultCategories = ['Personal', 'Work', 'Ideas'];
  late String _category;
  bool _loading = false;
  bool _loadingCategories = true;
  List<String> _categories = _defaultCategories;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final note = widget.existing;
    _titleController = TextEditingController(text: note?.title ?? '');
    _descriptionController = TextEditingController(text: note?.description ?? '');
    _category = note?.category ?? _defaultCategories.first;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final fromApi = await NotesService.instance.fetchCategories();
      if (fromApi.isNotEmpty && mounted) {
        setState(() {
          _categories = fromApi;
          if (!_categories.contains(_category)) {
            _category = _categories.first;
          }
          _loadingCategories = false;
        });
        return;
      }
    } catch (_) {
      // use defaults
    }
    if (mounted) setState(() => _loadingCategories = false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      if (_isEditing) {
        final updated = widget.existing!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _category,
        );
        await NotesService.instance.updateNote(updated);
      } else {
        await NotesService.instance.createNote(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _category,
        );
      }

      widget.onSaved?.call();

      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      } else {
        _formKey.currentState!.reset();
        _titleController.clear();
        _descriptionController.clear();
        setState(() => _category = _categories.first);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note saved')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save note')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit note' : 'New note'),
      ),
      body: _loadingCategories
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Title is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 6,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Description is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: _category,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _category = v);
                      },
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _loading ? null : _save,
                      child: _loading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isEditing ? 'Update' : 'Create note'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
