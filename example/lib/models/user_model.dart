import 'dart:convert';

import 'package:equatable/equatable.dart';

class UserModel with EquatableMixin {
  final int id;
  final String name;
  final String email;
  final String avatarAsset;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarAsset,
  });

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? avatarAsset,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarAsset: avatarAsset ?? this.avatarAsset,
    );
  }

  @override
  List<Object?> get props => [id];

  Map<String, dynamic> toMap() {
    return {
      UserModelFields.id: id,
      UserModelFields.name: name,
      UserModelFields.email: email,
      UserModelFields.avatarAsset: avatarAsset,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map[UserModelFields.id] as int,
      name: map[UserModelFields.name] as String? ?? '',
      email: map[UserModelFields.email] as String? ?? '',
      avatarAsset: map[UserModelFields.avatarAsset] as String? ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

abstract class UserModelFields {
  static const id = 'id';
  static const name = 'name';
  static const email = 'email';
  static const avatarAsset = 'avatarAsset';
}
