import 'package:flutter/material.dart';

import '../models/note_model.dart';
import '../services/notes_service.dart';
import 'add_note_view.dart';

class NoteDetailView extends StatefulWidget {
  final int noteId;

  const NoteDetailView({super.key, required this.noteId});

  @override
  State<NoteDetailView> createState() => _NoteDetailViewState();
}

class _NoteDetailViewState extends State<NoteDetailView> {
  NoteModel? _note;
  bool _loading = true;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final note = await NotesService.instance.fetchNote(widget.noteId);
      if (mounted) {
        setState(() {
          _note = note;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _edit() async {
    final note = _note;
    if (note == null) return;

    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddNoteView(existing: note)),
    );
    if (saved == true) {
      _changed = true;
      await _load();
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete note?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await NotesService.instance.deleteNote(widget.noteId);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final note = _note;
    if (note == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Note not found')),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_changed);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Note'),
          leading: BackButton(
            onPressed: () => Navigator.of(context).pop(_changed),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.edit), onPressed: _edit),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Chip(label: Text(note.category)),
              const SizedBox(height: 20),
              Text(
                note.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              _MetaRow(
                label: 'Created',
                value: _formatDateTime(note.createdAt),
              ),
              const SizedBox(height: 8),
              _MetaRow(
                label: 'Updated',
                value: _formatDateTime(note.updatedAt),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDateTime(DateTime dt) {
    final local = dt.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} $h:$m';
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        Text(value, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
