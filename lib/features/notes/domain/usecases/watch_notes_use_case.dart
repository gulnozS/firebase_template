import 'package:firebase_template/features/notes/domain/entities/note.dart';
import 'package:firebase_template/features/notes/domain/repositories/note_repository.dart';

class WatchNotesUseCase {
  const WatchNotesUseCase(this._repository);

  final NoteRepository _repository;

  Stream<List<Note>> call({required String userId}) {
    return _repository.watchNotes(userId: userId);
  }
}
