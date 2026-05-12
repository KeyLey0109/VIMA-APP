import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

/// Mobile image thumbnail - uses dart:io File
class TransactionImageThumbnail extends StatelessWidget {
  final String imagePath;

  const TransactionImageThumbnail({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final file = File(imagePath);

    if (!file.existsSync()) {
      return _brokenIcon();
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        image: DecorationImage(
          image: FileImage(file),
          fit: BoxFit.cover,
          onError: (e, s) => debugPrint('Transaction Image Error: $e'),
        ),
      ),
    );
  }

  Widget _brokenIcon() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(
        Icons.broken_image_rounded,
        size: 16,
        color: AppColors.textHint,
      ),
    );
  }
}
