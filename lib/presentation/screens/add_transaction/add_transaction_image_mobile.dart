import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Pick image from camera on mobile - returns file path
Future<String?> pickImageFromCamera() async {
  final picker = ImagePicker();
  final XFile? image = await picker.pickImage(
    source: ImageSource.camera,
    maxWidth: 1024,
    maxHeight: 1024,
    imageQuality: 85,
  );
  if (image == null) return null;
  return await _saveLocally(File(image.path));
}

/// Pick image from gallery on mobile - returns file path
Future<String?> pickImageFromGallery() async {
  final picker = ImagePicker();
  final XFile? image = await picker.pickImage(
    source: ImageSource.gallery,
    maxWidth: 1024,
    maxHeight: 1024,
    imageQuality: 85,
  );
  if (image == null) return null;
  return await _saveLocally(File(image.path));
}

Future<String> _saveLocally(File imageFile) async {
  final directory = await getApplicationDocumentsDirectory();
  final receiptsDir = Directory('${directory.path}/receipts');
  if (!await receiptsDir.exists()) {
    await receiptsDir.create(recursive: true);
  }
  final fileName =
      'receipt_${DateTime.now().millisecondsSinceEpoch}${p.extension(imageFile.path)}';
  final saved = await imageFile.copy('${receiptsDir.path}/$fileName');
  return saved.path;
}

/// Mobile receipt image preview widget
class ReceiptImagePreview extends StatelessWidget {
  final String imagePath;
  const ReceiptImagePreview({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final file = File(imagePath);
    if (!file.existsSync()) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        file,
        width: double.infinity,
        height: 160,
        fit: BoxFit.cover,
      ),
    );
  }
}
