import 'package:image_picker/image_picker.dart';

import '../../core/network/api_paths.dart';
import '../../core/utils/parsing.dart';

/// Uploads images to `POST /uploads` and returns their public URL, which is
/// what equipment listings, avatars and ID submissions store.
class MediaRepository {
  MediaRepository(this._upload);

  final Future<dynamic> Function(
    String path, {
    required List<int> bytes,
    required String filename,
    String? mimeType,
    void Function(int sent, int total)? onProgress,
  }) _upload;

  Future<String> uploadImage(
    XFile file, {
    void Function(double progress)? onProgress,
  }) async {
    final List<int> bytes = await file.readAsBytes();
    final String name = file.name.isNotEmpty ? file.name : 'photo.jpg';
    final dynamic res = await _upload(
      ApiPaths.uploads,
      bytes: bytes,
      filename: name,
      mimeType: file.mimeType ?? _guessMime(name),
      onProgress: onProgress == null
          ? null
          : (int sent, int total) {
              if (total > 0) onProgress(sent / total);
            },
    );
    return asString(asMap(res)['url']);
  }

  static String _guessMime(String name) {
    final String lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic')) return 'image/heic';
    return 'image/jpeg';
  }
}
