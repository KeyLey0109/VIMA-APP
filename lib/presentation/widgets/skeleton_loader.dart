import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_constants.dart';
import 'glass_card.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = AppConstants.borderRadiusSmall,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  static Widget transactionItem() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        borderRadius: AppConstants.borderRadiusSmall,
        child: Row(
          children: [
            const SkeletonLoader(width: 44, height: 44, borderRadius: 12),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader(width: 100, height: 14),
                  const SizedBox(height: 6),
                  SkeletonLoader(width: 60, height: 10),
                ],
              ),
            ),
            const SkeletonLoader(width: 70, height: 14),
          ],
        ),
      ),
    );
  }

  static Widget summaryCard() {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonLoader(width: 30, height: 30, borderRadius: 8),
            const SizedBox(height: 12),
            SkeletonLoader(width: 60, height: 12),
            const SizedBox(height: 8),
            SkeletonLoader(width: 80, height: 20),
          ],
        ),
      ),
    );
  }
}
