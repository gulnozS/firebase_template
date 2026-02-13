import 'package:firebase_template/features/notes/domain/repositories/note_repository.dart';

class DeleteNoteUseCase {
  const DeleteNoteUseCase(this._repository);

  final NoteRepository _repository;

  Future<void> call({
    required String userId,
    required String noteId,
    String? imageUrl,
  }) {
    return _repository.deleteNote(
      userId: userId,
      noteId: noteId,
      imageUrl: imageUrl,
    );
  }
}
