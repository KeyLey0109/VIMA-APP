import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

/// Result of a web image pick operation
class WebImageResult {
  final String? path; // stores a web-safe key (not a real file path)
  final Uint8List? bytes;

  const WebImageResult({this.path, this.bytes});

  bool get exists => bytes != null;
}

/// Helper class for picking images on web platform
/// Returns WebImageResult instead of File (which doesn't exist on web)
class ImageHelper {
  final ImagePicker _picker = ImagePicker();

  /// Pick image from camera (web: uses browser camera)
  Future<WebImageResult?> pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image == null) return null;
    final bytes = await image.readAsBytes();
    final key = 'web_img_${DateTime.now().millisecondsSinceEpoch}';
    return WebImageResult(path: key, bytes: bytes);
  }

  /// Pick image from gallery
  Future<WebImageResult?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image == null) return null;
    final bytes = await image.readAsBytes();
    final key = 'web_img_${DateTime.now().millisecondsSinceEpoch}';
    return WebImageResult(path: key, bytes: bytes);
  }

  /// No-op on web (no file system)
  Future<void> deleteImage(String imagePath) async {
    // No file system on web - nothing to delete
  }
}
