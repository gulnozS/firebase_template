import 'dart:typed_data';

import 'package:firebase_template/core/error/error_mapper.dart';
import 'package:firebase_template/core/logging/app_logger.dart';
import 'package:firebase_template/features/notes/data/datasources/note_remote_data_source.dart';
import 'package:firebase_template/features/notes/domain/entities/note.dart';
import 'package:firebase_template/features/notes/domain/repositories/note_repository.dart';

class NoteRepositoryImpl implements NoteRepository {
  NoteRepositoryImpl({
    required NoteRemoteDataSource remoteDataSource,
    required ErrorMapper errorMapper,
    required AppLogger logger,
  }) : _remoteDataSource = remoteDataSource,
       _errorMapper = errorMapper,
       _logger = logger;

  final NoteRemoteDataSource _remoteDataSource;
  final ErrorMapper _errorMapper;
  final AppLogger _logger;

  @override
  Stream<List<Note>> watchNotes({required String userId}) async* {
    try {
      yield* _remoteDataSource.watchNotes(userId: userId);
    } catch (error, stackTrace) {
      _logger.error('watchNotes failed', error: error, stackTrace: stackTrace);
      throw _errorMapper.map(
        error,
        stackTrace: stackTrace,
        fallbackMessage: 'Unable to load notes.',
      );
    }
  }

  @override
  Future<void> createNote({
    required String userId,
    required Note note,
    Uint8List? imageBytes,
  }) async {
    try {
      await _remoteDataSource.createNote(
        userId: userId,
        note: note,
        imageBytes: imageBytes,
      );
    } catch (error, stackTrace) {
      _logger.error('createNote failed', error: error, stackTrace: stackTrace);
      throw _errorMapper.map(
        error,
        stackTrace: stackTrace,
        fallbackMessage: 'Unable to create note.',
      );
    }
  }

  @override
  Future<void> updateNote({
    required String userId,
    required Note note,
    Uint8List? imageBytes,
  }) async {
    try {
      await _remoteDataSource.updateNote(
        userId: userId,
        note: note,
        imageBytes: imageBytes,
      );
    } catch (error, stackTrace) {
      _logger.error('updateNote failed', error: error, stackTrace: stackTrace);
      throw _errorMapper.map(
        error,
        stackTrace: stackTrace,
        fallbackMessage: 'Unable to update note.',
      );
    }
  }

  @override
  Future<void> deleteNote({
    required String userId,
    required String noteId,
    String? imageUrl,
  }) async {
    try {
      await _remoteDataSource.deleteNote(
        userId: userId,
        noteId: noteId,
        imageUrl: imageUrl,
      );
    } catch (error, stackTrace) {
      _logger.error('deleteNote failed', error: error, stackTrace: stackTrace);
      throw _errorMapper.map(
        error,
        stackTrace: stackTrace,
        fallbackMessage: 'Unable to delete note.',
      );
    }
  }
}
