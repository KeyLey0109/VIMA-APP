import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Helper class for picking and saving images on mobile/desktop
class ImageHelper {
  final ImagePicker _picker = ImagePicker();

  /// Pick image from camera
  Future<File?> pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image == null) return null;
    return await _saveImageLocally(File(image.path));
  }

  /// Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image == null) return null;
    return await _saveImageLocally(File(image.path));
  }

  /// Save image to app's local directory
  Future<File> _saveImageLocally(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final receiptsDir = Directory('${directory.path}/receipts');

    if (!await receiptsDir.exists()) {
      await receiptsDir.create(recursive: true);
    }

    final fileName =
        'receipt_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
    final savedImage = await imageFile.copy('${receiptsDir.path}/$fileName');

    return savedImage;
  }

  /// Delete image from local storage
  Future<void> deleteImage(String imagePath) async {
    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
