import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_template/core/di/app_providers.dart';
import 'package:firebase_template/core/error/app_failure.dart';
import 'package:firebase_template/core/services/firebase_storage_service.dart';
import 'package:firebase_template/core/services/storage_service.dart';
import 'package:firebase_template/features/notes/data/datasources/note_remote_data_source.dart';
import 'package:firebase_template/features/notes/data/repositories/note_repository_impl.dart';
import 'package:firebase_template/features/notes/domain/entities/note.dart';
import 'package:firebase_template/features/notes/domain/repositories/note_repository.dart';
import 'package:firebase_template/features/notes/domain/usecases/create_note_use_case.dart';
import 'package:firebase_template/features/notes/domain/usecases/delete_note_use_case.dart';
import 'package:firebase_template/features/notes/domain/usecases/update_note_use_case.dart';
import 'package:firebase_template/features/notes/domain/usecases/watch_notes_use_case.dart';

// Notes module DI wiring stays local to this feature and composes core
// dependencies rather than pulling Firebase directly into presentation.
final storageServiceProvider = Provider<StorageService>((ref) {
  return FirebaseStorageService(
    storage: ref.watch(firebaseStorageProvider),
    errorMapper: ref.watch(errorMapperProvider),
    logger: ref.watch(appLoggerProvider),
  );
});

final noteRemoteDataSourceProvider = Provider<NoteRemoteDataSource>((ref) {
  return NoteRemoteDataSourceImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
    storageService: ref.watch(storageServiceProvider),
  );
});

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl(
    remoteDataSource: ref.watch(noteRemoteDataSourceProvider),
    errorMapper: ref.watch(errorMapperProvider),
    logger: ref.watch(appLoggerProvider),
  );
});

final watchNotesUseCaseProvider = Provider<WatchNotesUseCase>((ref) {
  return WatchNotesUseCase(ref.watch(noteRepositoryProvider));
});

final createNoteUseCaseProvider = Provider<CreateNoteUseCase>((ref) {
  return CreateNoteUseCase(ref.watch(noteRepositoryProvider));
});

final updateNoteUseCaseProvider = Provider<UpdateNoteUseCase>((ref) {
  return UpdateNoteUseCase(ref.watch(noteRepositoryProvider));
});

final deleteNoteUseCaseProvider = Provider<DeleteNoteUseCase>((ref) {
  return DeleteNoteUseCase(ref.watch(noteRepositoryProvider));
});

final notesStreamProvider = StreamProvider.family<List<Note>, String>((
  ref,
  userId,
) {
  return ref.watch(watchNotesUseCaseProvider).call(userId: userId);
});

final noteActionControllerProvider =
    AutoDisposeAsyncNotifierProvider<NoteActionController, void>(
      NoteActionController.new,
    );

class NoteActionController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> createNote({
    required String userId,
    required Note note,
    Uint8List? imageBytes,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(createNoteUseCaseProvider)
          .call(userId: userId, note: note, imageBytes: imageBytes);
    });
  }

  Future<void> updateNote({
    required String userId,
    required Note note,
    Uint8List? imageBytes,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(updateNoteUseCaseProvider)
          .call(userId: userId, note: note, imageBytes: imageBytes);
    });
  }

  Future<void> deleteNote({
    required String userId,
    required String noteId,
    String? imageUrl,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(deleteNoteUseCaseProvider)
          .call(userId: userId, noteId: noteId, imageUrl: imageUrl);
    });
  }

  String? errorMessage() {
    final error = state.asError?.error;
    if (error is AppFailure) {
      return error.message;
    }
    return error?.toString();
  }
}
