import 'dart:typed_data';

import 'package:firebase_template/features/notes/domain/entities/note.dart';
import 'package:firebase_template/features/notes/domain/repositories/note_repository.dart';

class CreateNoteUseCase {
  const CreateNoteUseCase(this._repository);

  final NoteRepository _repository;

  Future<void> call({
    required String userId,
    required Note note,
    Uint8List? imageBytes,
  }) {
    return _repository.createNote(
      userId: userId,
      note: note,
      imageBytes: imageBytes,
    );
  }
}
