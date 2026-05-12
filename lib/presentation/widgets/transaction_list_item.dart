import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/categories.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/transaction_entity.dart';
import 'glass_card.dart';
import 'transaction_image_widget.dart';
import 'animated_rainbow.dart';

/// Single transaction list item widget (Web + Mobile safe)
class TransactionListItem extends StatelessWidget {
  final TransactionEntity transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDismissed;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final category = AppCategories.getCategoryByName(transaction.category);
    final isExpense = transaction.category != 'Thu nhập';

    return Dismissible(
      key: Key('transaction_${transaction.id ?? transaction.hashCode}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        ),
        child: const Icon(Icons.delete_sweep_rounded, color: AppColors.error),
      ),
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        borderRadius: AppConstants.borderRadiusSmall,
        child: Row(
          children: [
            // Category Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: category.color.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Icon(
                category.icon,
                color: category.color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    transaction.category,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppFormatters.formatDateTime(transaction.dateTime),
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Image Thumbnail (web-safe)
            if (transaction.imagePath != null)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Hero(
                  tag: 'tx_image_${transaction.id ?? transaction.hashCode}',
                  child: TransactionImageThumbnail(
                    imagePath: transaction.imagePath!,
                  ),
                ),
              ),
            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedRainbow(
                  child: Text(
                    (isExpense ? '-' : '+') +
                        AppFormatters.formatCurrency(transaction.amount),
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  isExpense ? 'Chi tiêu' : 'Thu nhập',
                  style: AppTextStyles.caption.copyWith(
                    color: isExpense
                        ? AppColors.brand.withValues(alpha: 0.8)
                        : AppColors.accent.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
