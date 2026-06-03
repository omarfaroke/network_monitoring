import 'dart:convert';

import 'package:equatable/equatable.dart';

class NoteModel with EquatableMixin {
  final int id;
  final String title;
  final String description;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NoteModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  NoteModel copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id];

  Map<String, dynamic> toMap() {
    return {
      NoteModelFields.id: id,
      NoteModelFields.title: title,
      NoteModelFields.description: description,
      NoteModelFields.category: category,
      NoteModelFields.createdAt: createdAt.toIso8601String(),
      NoteModelFields.updatedAt: updatedAt.toIso8601String(),
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map[NoteModelFields.id] as int,
      title: map[NoteModelFields.title] as String? ?? '',
      description: map[NoteModelFields.description] as String? ?? '',
      category: map[NoteModelFields.category] as String? ?? 'Personal',
      createdAt: DateTime.parse(map[NoteModelFields.createdAt] as String),
      updatedAt: DateTime.parse(map[NoteModelFields.updatedAt] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory NoteModel.fromJson(String source) =>
      NoteModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

abstract class NoteModelFields {
  static const id = 'id';
  static const title = 'title';
  static const description = 'description';
  static const category = 'category';
  static const createdAt = 'createdAt';
  static const updatedAt = 'updatedAt';
}
