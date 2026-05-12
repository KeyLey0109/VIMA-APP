import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

/// Pick image from camera on web - returns logical key
Future<String?> pickImageFromCamera() async {
  // Web: use gallery picker (camera requires HTTPS and extra permissions)
  return await pickImageFromGallery();
}

/// Pick image from gallery on web - returns logical key
Future<String?> pickImageFromGallery() async {
  final picker = ImagePicker();
  final XFile? image = await picker.pickImage(
    source: ImageSource.gallery,
    maxWidth: 1024,
    maxHeight: 1024,
    imageQuality: 85,
  );
  if (image == null) return null;
  // On web, return a key (filename) - bytes are not stored persistently
  return 'web_receipt_${DateTime.now().millisecondsSinceEpoch}';
}

/// Web: no actual image preview (bytes not persisted to storage)
class ReceiptImagePreview extends StatelessWidget {
  final String imagePath;
  const ReceiptImagePreview({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    // On web, just show the filename key - no actual image display
    return const SizedBox.shrink();
  }
}
