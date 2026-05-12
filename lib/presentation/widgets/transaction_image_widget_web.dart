import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

/// Web image thumbnail - shows receipt icon (no file system on web)
/// imagePath on web is a logical key, actual bytes are not persisted cross-session
class TransactionImageThumbnail extends StatelessWidget {
  final String imagePath;

  const TransactionImageThumbnail({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: const Icon(
        Icons.receipt_rounded,
        size: 16,
        color: AppColors.primary,
      ),
    );
  }
}
