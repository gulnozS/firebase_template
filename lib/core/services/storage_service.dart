import 'dart:typed_data';

abstract class StorageService {
  Future<String> uploadUserImage({
    required String userId,
    required String fileName,
    required Uint8List bytes,
  });

  Future<void> deleteByUrl(String url);
}
