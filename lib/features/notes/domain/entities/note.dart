import 'package:equatable/equatable.dart';

class Note extends Equatable {
  const Note({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final String? imageUrl;

  Note copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    String? imageUrl,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => <Object?>[id, title, description, createdAt];
}
