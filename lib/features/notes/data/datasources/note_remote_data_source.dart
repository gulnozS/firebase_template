import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_template/core/services/storage_service.dart';
import 'package:firebase_template/features/notes/data/models/note_model.dart';
import 'package:firebase_template/features/notes/domain/entities/note.dart';

/// Remote datasource contract for notes feature.
///
/// The implementation persists note documents in Firestore and images in
/// Firebase Storage. Storage URLs are saved in note documents.
abstract class NoteRemoteDataSource {
  /// Streams all notes for one user, newest first.
  Stream<List<NoteModel>> watchNotes({required String userId});

  /// Creates a note and optionally uploads an image.
  Future<void> createNote({
    required String userId,
    required Note note,
    Uint8List? imageBytes,
  });

  /// Updates note fields and optionally replaces image URL.
  Future<void> updateNote({
    required String userId,
    required Note note,
    Uint8List? imageBytes,
  });

  /// Deletes note and its associated image when present.
  Future<void> deleteNote({
    required String userId,
    required String noteId,
    String? imageUrl,
  });
}

/// Firestore + Storage implementation for note persistence.
class NoteRemoteDataSourceImpl implements NoteRemoteDataSource {
  NoteRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required StorageService storageService,
  }) : _firestore = firestore,
       _storageService = storageService;

  final FirebaseFirestore _firestore;
  final StorageService _storageService;

  /// Notes are scoped under user-owned collection for simple auth rules.
  CollectionReference<Map<String, dynamic>> _noteCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('notes');
  }

  @override
  Stream<List<NoteModel>> watchNotes({required String userId}) {
    return _noteCollection(
      userId,
    ).orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => NoteModel.fromFirestore(id: doc.id, json: doc.data()))
          .toList();
    });
  }

  @override
  Future<void> createNote({
    required String userId,
    required Note note,
    Uint8List? imageBytes,
  }) async {
    String? imageUrl = note.imageUrl;
    if (imageBytes != null) {
      // Upload first so we can store URL atomically with note data.
      imageUrl = await _storageService.uploadUserImage(
        userId: userId,
        fileName: '${note.id}.jpg',
        bytes: imageBytes,
      );
    }
    final model = NoteModel(
      id: note.id,
      title: note.title,
      description: note.description,
      createdAt: note.createdAt,
      imageUrl: imageUrl,
    );
    await _noteCollection(userId).doc(note.id).set(model.toFirestore());
  }

  @override
  Future<void> updateNote({
    required String userId,
    required Note note,
    Uint8List? imageBytes,
  }) async {
    String? imageUrl = note.imageUrl;
    if (imageBytes != null) {
      // Re-upload returns a new URL and replaces prior URL in document.
      imageUrl = await _storageService.uploadUserImage(
        userId: userId,
        fileName: '${note.id}.jpg',
        bytes: imageBytes,
      );
    }
    final model = NoteModel(
      id: note.id,
      title: note.title,
      description: note.description,
      createdAt: note.createdAt,
      imageUrl: imageUrl,
    );
    await _noteCollection(userId).doc(note.id).update(model.toFirestore());
  }

  @override
  Future<void> deleteNote({
    required String userId,
    required String noteId,
    String? imageUrl,
  }) async {
    await _noteCollection(userId).doc(noteId).delete();
    if (imageUrl != null && imageUrl.isNotEmpty) {
      await _storageService.deleteByUrl(imageUrl);
    }
  }
}
