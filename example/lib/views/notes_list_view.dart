import 'package:flutter/material.dart';
import 'package:network_monitoring/network_monitoring.dart';

import '../models/note_model.dart';
import '../services/notes_service.dart';
import '../widgets/note_card.dart';
import 'note_detail_view.dart';

class NotesListView extends StatefulWidget {
  const NotesListView({super.key});

  @override
  State<NotesListView> createState() => NotesListViewState();
}

class NotesListViewState extends State<NotesListView> {
  final _searchController = TextEditingController();
  List<NoteModel> _notes = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    reload();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final categories = await NotesService.instance.fetchCategories();
      final notes = await NotesService.instance.fetchNotes(
        category: _selectedCategory == 'All' ? null : _selectedCategory,
        search: _searchController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _categories = ['All', ...categories];
        _notes = notes;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load notes';
        _loading = false;
      });
    }
  }

  Future<void> _openDetail(NoteModel note) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => NoteDetailView(noteId: note.id)),
    );
    if (changed == true) reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          NetworkMonitoringBuilder(
            listenTo: NetworkMonitorChanges.devMode,
            builder: (context, controller) {
              if (!controller.isDevModeEnabled) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Dev Mode',
                icon: const Icon(Icons.developer_mode),
                onPressed: () => DevModeOptionsView.push(context),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : reload,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notes…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          reload();
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => reload(),
            ),
          ),
          if (_categories.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final selected = cat == _selectedCategory;
                  return FilterChip(
                    label: Text(cat),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _selectedCategory = cat);
                      reload();
                    },
                  );
                },
              ),
            ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 12),
            FilledButton(onPressed: reload, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_notes.isEmpty) {
      return const Center(child: Text('No notes found'));
    }

    return RefreshIndicator(
      onRefresh: reload,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _notes.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final note = _notes[index];
          return NoteCard(
            note: note,
            onTap: () => _openDetail(note),
          );
        },
      ),
    );
  }
}
