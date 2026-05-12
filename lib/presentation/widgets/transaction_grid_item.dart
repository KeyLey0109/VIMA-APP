import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/categories.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../blocs/transaction/transaction_bloc.dart';
import '../blocs/transaction/transaction_event.dart';
import 'animated_rainbow.dart';
import 'glass_card.dart';
import 'premium_button.dart';

class TransactionGridItem extends StatelessWidget {
  final TransactionEntity transaction;
  final VoidCallback? onDeleted;

  const TransactionGridItem({
    super.key,
    required this.transaction,
    this.onDeleted,
  });

  void _showTransactionDetails(BuildContext context) {
    final isExpense = transaction.category != 'Thu nhập';
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: GlassCard(
          padding: const EdgeInsets.all(24),
          borderRadius: 24,
          hasGlow: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (transaction.imagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(transaction.imagePath!),
                    fit: BoxFit.cover,
                  ),
                ),
              if (transaction.imagePath != null) const SizedBox(height: 16),
              Text(
                transaction.category,
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 8),
              AnimatedRainbow(
                child: Text(
                  (isExpense ? '-' : '+') + AppFormatters.formatCurrency(transaction.amount),
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppFormatters.formatDateTime(transaction.dateTime),
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              PremiumButton(
                text: 'Đóng',
                onTap: () => Navigator.pop(dialogContext),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  if (transaction.id != null) {
                    context.read<TransactionBloc>().add(DeleteTransaction(transaction.id!));
                    Navigator.pop(dialogContext);
                    onDeleted?.call();
                  }
                },
                child: Text(
                  'Xóa giao dịch',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackGridIcon(CategoryItem category) {
    return Container(
      color: category.color.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          category.icon,
          color: category.color,
          size: 28,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.category != 'Thu nhập';
    final category = AppCategories.getCategoryByName(transaction.category);

    return GestureDetector(
      onTap: () => _showTransactionDetails(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: transaction.imagePath != null
                  ? Image.file(
                      File(transaction.imagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildFallbackGridIcon(category),
                    )
                  : _buildFallbackGridIcon(category),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              color: AppColors.surface.withValues(alpha: 0.9),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedRainbow(
                    child: Text(
                      (isExpense ? '-' : '+') + AppFormatters.formatCurrency(transaction.amount),
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    transaction.category,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
