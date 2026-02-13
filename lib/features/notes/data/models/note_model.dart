import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_template/features/notes/domain/entities/note.dart';

class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.title,
    required super.description,
    required super.createdAt,
    super.imageUrl,
  });

  factory NoteModel.fromFirestore({
    required String id,
    required Map<String, dynamic> json,
  }) {
    final createdAt = json['createdAt'] as Timestamp?;
    return NoteModel(
      id: id,
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      createdAt: createdAt?.toDate() ?? DateTime.now(),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'imageUrl': imageUrl,
    };
  }
}
