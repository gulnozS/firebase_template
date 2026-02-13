import 'dart:typed_data';

import 'package:firebase_template/features/notes/domain/entities/note.dart';

abstract class NoteRepository {
  Stream<List<Note>> watchNotes({required String userId});

  Future<void> createNote({
    required String userId,
    required Note note,
    Uint8List? imageBytes,
  });

  Future<void> updateNote({
    required String userId,
    required Note note,
    Uint8List? imageBytes,
  });

  Future<void> deleteNote({
    required String userId,
    required String noteId,
    String? imageUrl,
  });
}
