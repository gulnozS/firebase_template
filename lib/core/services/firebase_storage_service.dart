import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_template/core/error/error_mapper.dart';
import 'package:firebase_template/core/logging/app_logger.dart';
import 'package:firebase_template/core/services/storage_service.dart';

class FirebaseStorageService implements StorageService {
  FirebaseStorageService({
    required FirebaseStorage storage,
    required ErrorMapper errorMapper,
    required AppLogger logger,
  }) : _storage = storage,
       _errorMapper = errorMapper,
       _logger = logger;

  final FirebaseStorage _storage;
  final ErrorMapper _errorMapper;
  final AppLogger _logger;

  @override
  Future<String> uploadUserImage({
    required String userId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    try {
      final path =
          'users/$userId/notes/${DateTime.now().millisecondsSinceEpoch}'
          '_$fileName';
      final ref = _storage.ref(path);
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      final task = await ref.putData(bytes, metadata);
      final url = await task.ref.getDownloadURL();
      _logger.info('Image uploaded for user=$userId path=$path');
      return url;
    } catch (error, stackTrace) {
      _logger.error(
        'Image upload failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw _errorMapper.map(
        error,
        stackTrace: stackTrace,
        fallbackMessage: 'Unable to upload image right now.',
      );
    }
  }

  @override
  Future<void> deleteByUrl(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } catch (error, stackTrace) {
      _logger.error(
        'Image deletion failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw _errorMapper.map(
        error,
        stackTrace: stackTrace,
        fallbackMessage: 'Unable to delete image right now.',
      );
    }
  }
}
