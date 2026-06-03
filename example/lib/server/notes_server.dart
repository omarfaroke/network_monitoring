import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../models/note_model.dart';
import '../models/user_model.dart';

/// In-process HTTP server simulating a remote notes API with JWT auth.
class NotesServer {
  NotesServer._();

  static HttpServer? _server;

  static final _users = <String, Map<String, dynamic>>{
    AppConfig.defaultUsername: {
      UserModelFields.id: 1,
      UserModelFields.name: 'Demo User',
      UserModelFields.email: 'demo@notes.example',
      UserModelFields.avatarAsset: 'assets/images/avatar.png',
      'password': AppConfig.defaultPassword,
    },
  };

  static final List<Map<String, dynamic>> _notes = [];

  static int _nextNoteId = 1;

  static Future<void> start() async {
    if (_server != null) return;

    await _loadNotesFromCache();

    _server = await HttpServer.bind(
      InternetAddress.anyIPv4,
      AppConfig.serverPort,
      shared: true,
    );

    _server!.listen((request) {
      _dispatch(request);
    });
  }

  static void _dispatch(HttpRequest request) {
    final path = request.uri.path;
    final method = request.method;

    _addCors(request);

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.noContent;
      request.response.close();
      return;
    }

    try {
      if (path == '/api/auth/login' && method == 'POST') {
        _login(request);
        return;
      }

      final username = _usernameFromAuth(request);
      if (username == null) {
        _json(request, HttpStatus.unauthorized, {'error': 'Unauthorized'});
        return;
      }

      if (path == '/api/user/me' && method == 'GET') {
        _me(request, username);
        return;
      }
      if (path == '/api/categories' && method == 'GET') {
        _categories(request);
        return;
      }
      if (path == '/api/notes' && method == 'GET') {
        _listNotes(request);
        return;
      }
      if (path.startsWith('/api/notes/') && method == 'GET') {
        _getNote(request, path);
        return;
      }
      if (path == '/api/notes' && method == 'POST') {
        _createNote(request);
        return;
      }
      if (path.startsWith('/api/notes/') && method == 'PUT') {
        _updateNote(request, path);
        return;
      }
      if (path.startsWith('/api/notes/') && method == 'DELETE') {
        _deleteNote(request, path);
        return;
      }

      _json(request, HttpStatus.notFound, {'error': 'Not found'});
    } catch (e) {
      _json(request, HttpStatus.internalServerError, {'error': '$e'});
    }
  }

  static Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }

  static void _addCors(HttpRequest request) {
    request.response.headers
      ..add('Access-Control-Allow-Origin', '*')
      ..add('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
      ..add('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  }

  static Future<void> _login(HttpRequest request) async {
    final body = await _readJson(request);
    final username = body['username'] as String? ?? '';
    final password = body['password'] as String? ?? '';

    final user = _users[username];
    if (user == null || user['password'] != password) {
      _json(request, HttpStatus.unauthorized, {'error': 'Invalid credentials'});
      return;
    }

    final token = _issueToken(username);
    final userMap = Map<String, dynamic>.from(user)..remove('password');
    _json(request, HttpStatus.ok, {
      'token': token,
      'user': userMap,
    });
  }

  static void _me(HttpRequest request, String username) {
    final user = _users[username];
    if (user == null) {
      _json(request, HttpStatus.notFound, {'error': 'User not found'});
      return;
    }
    final userMap = Map<String, dynamic>.from(user)..remove('password');
    _json(request, HttpStatus.ok, userMap);
  }

  static void _categories(HttpRequest request) {
    final categories = _notes
        .map((n) => n[NoteModelFields.category] as String)
        .toSet()
        .toList()
      ..sort();
    _json(request, HttpStatus.ok, {'categories': categories});
  }

  static void _listNotes(HttpRequest request) {
    final category = request.uri.queryParameters['category'];
    final search = request.uri.queryParameters['search']?.toLowerCase();

    var result = List<Map<String, dynamic>>.from(_notes);

    if (category != null && category.isNotEmpty && category != 'All') {
      result = result
          .where((n) => n[NoteModelFields.category] == category)
          .toList();
    }

    if (search != null && search.isNotEmpty) {
      result = result.where((n) {
        final title = (n[NoteModelFields.title] as String).toLowerCase();
        final desc = (n[NoteModelFields.description] as String).toLowerCase();
        return title.contains(search) || desc.contains(search);
      }).toList();
    }

    result.sort(
      (a, b) => (b[NoteModelFields.updatedAt] as String).compareTo(
        a[NoteModelFields.updatedAt] as String,
      ),
    );

    _json(request, HttpStatus.ok, {'notes': result});
  }

  static void _getNote(HttpRequest request, String path) {
    final id = int.tryParse(path.split('/').last);
    final note = _findNote(id);
    if (note == null) {
      _json(request, HttpStatus.notFound, {'error': 'Note not found'});
      return;
    }
    _json(request, HttpStatus.ok, note);
  }

  static Future<void> _createNote(HttpRequest request) async {
    final body = await _readJson(request);
    final now = DateTime.now().toIso8601String();
    final note = {
      NoteModelFields.id: _nextNoteId++,
      NoteModelFields.title: body[NoteModelFields.title] ?? '',
      NoteModelFields.description: body[NoteModelFields.description] ?? '',
      NoteModelFields.category: body[NoteModelFields.category] ?? 'Personal',
      NoteModelFields.createdAt: now,
      NoteModelFields.updatedAt: now,
    };
    _notes.add(note);
    await _persistNotes();
    _json(request, HttpStatus.created, note);
  }

  static Future<void> _updateNote(HttpRequest request, String path) async {
    final id = int.tryParse(path.split('/').last);
    final index = _notes.indexWhere((n) => n[NoteModelFields.id] == id);
    if (index < 0) {
      _json(request, HttpStatus.notFound, {'error': 'Note not found'});
      return;
    }

    final body = await _readJson(request);
    final existing = _notes[index];
    _notes[index] = {
      ...existing,
      NoteModelFields.title: body[NoteModelFields.title] ?? existing[NoteModelFields.title],
      NoteModelFields.description:
          body[NoteModelFields.description] ?? existing[NoteModelFields.description],
      NoteModelFields.category:
          body[NoteModelFields.category] ?? existing[NoteModelFields.category],
      NoteModelFields.updatedAt: DateTime.now().toIso8601String(),
    };
    await _persistNotes();
    _json(request, HttpStatus.ok, _notes[index]);
  }

  static void _deleteNote(HttpRequest request, String path) {
    final id = int.tryParse(path.split('/').last);
    final index = _notes.indexWhere((n) => n[NoteModelFields.id] == id);
    if (index < 0) {
      _json(request, HttpStatus.notFound, {'error': 'Note not found'});
      return;
    }
    _notes.removeAt(index);
    unawaited(_persistNotes());
    _json(request, HttpStatus.ok, {'success': true});
  }

  static Future<void> _loadNotesFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(AppConfig.notesCacheKey);
    if (cached == null) return;

    final decoded = json.decode(cached) as List<dynamic>;
    _notes
      ..clear()
      ..addAll(
        decoded.map((e) => Map<String, dynamic>.from(e as Map)),
      );
    _nextNoteId = _notes.isEmpty
        ? 1
        : _notes
                .map((n) => n[NoteModelFields.id] as int)
                .reduce((a, b) => a > b ? a : b) +
            1;
  }

  static Future<void> _persistNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.notesCacheKey, json.encode(_notes));
  }

  /// Used after first-launch seeding to sync server memory with API creates.
  static Future<void> reloadFromCache() => _loadNotesFromCache();

  static Map<String, dynamic>? _findNote(int? id) {
    if (id == null) return null;
    for (final note in _notes) {
      if (note[NoteModelFields.id] == id) return note;
    }
    return null;
  }

  static String? _usernameFromAuth(HttpRequest request) {
    final header = request.headers.value(HttpHeaders.authorizationHeader);
    if (header == null || !header.startsWith('Bearer ')) return null;
    final token = header.substring(7);
    try {
      final jwt = JWT.verify(token, SecretKey(AppConfig.jwtSecret));
      return jwt.payload['sub'] as String?;
    } catch (_) {
      return null;
    }
  }

  static String _issueToken(String username) {
    final jwt = JWT(
      {
        'sub': username,
        'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      issuer: 'notes-example',
    );
    return jwt.sign(
      SecretKey(AppConfig.jwtSecret),
      expiresIn: const Duration(hours: 24),
    );
  }

  static Future<Map<String, dynamic>> _readJson(HttpRequest request) async {
    final content = await utf8.decoder.bind(request).join();
    if (content.isEmpty) return {};
    return json.decode(content) as Map<String, dynamic>;
  }

  static void _json(
    HttpRequest request,
    int status,
    Map<String, dynamic> body,
  ) {
    request.response
      ..statusCode = status
      ..headers.contentType = ContentType.json
      ..write(json.encode(body));
    request.response.close();
  }
}
