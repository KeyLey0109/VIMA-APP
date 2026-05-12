import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/transaction/transaction_event.dart';
import '../../blocs/transaction/transaction_state.dart';
import '../../widgets/transaction_grid_item.dart';
import '../../widgets/animated_rainbow.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/skeleton_loader.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    context.read<TransactionBloc>().add(LoadTransactions());
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedRainbow(
          child: Text(
            'LỊCH SỬ CHI TIÊU',
            style: AppTextStyles.heading3.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: FadeTransition(
        opacity: _fadeController,
        child: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, state) {
            if (state is TransactionLoading) {
              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: 8,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SkeletonLoader.transactionItem(),
                ),
              );
            }

            if (state is TransactionLoaded) {
              final transactions = state.transactions;

              if (transactions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.history_toggle_off_rounded,
                          size: 64,
                          color: AppColors.textHint.withValues(alpha: 0.4),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Chưa có dữ liệu chi tiêu',
                        style: AppTextStyles.subtitle.copyWith(
                          color: AppColors.textHint,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Thêm giao dịch để bắt đầu theo dõi',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textHint.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Sort transactions by date descending
              final sortedTransactions = List.from(transactions)
                ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

              // Calculate total
              final totalAmount = transactions.fold<double>(
                  0, (sum, tx) => sum + tx.amount);

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ─── Summary Card ──────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      child: _buildSummaryCard(
                        totalAmount: totalAmount,
                        transactionCount: transactions.length,
                      ),
                    ),
                  ),

                  // ─── Section Header ────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.accent
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.receipt_long_rounded,
                              color: AppColors.accent,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'TẤT CẢ GIAO DỊCH',
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: AppColors.textHint,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${sortedTransactions.length} mục',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ─── Transaction List ──────────────
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: AnimationLimiter(
                      child: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final tx = sortedTransactions[index];
                            return AnimationConfiguration.staggeredGrid(
                              position: index,
                              columnCount: 3,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: TransactionGridItem(
                                    transaction: tx,
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: sortedTransactions.length,
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                      child: SizedBox(height: 100)),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required double totalAmount,
    required int transactionCount,
  }) {
    return AnimatedBuilder(
      animation: RainbowProvider.of(context)!,
      builder: (context, child) {
        final animValue = RainbowProvider.of(context)!.value;
        final color1 = Color.lerp(
          AppColors.primary,
          AppColors.accent,
          (math.sin(animValue * 2 * math.pi) + 1) / 2,
        )!;
        final color2 = Color.lerp(
          AppColors.accent,
          AppColors.brand,
          (math.sin(animValue * 2 * math.pi + math.pi / 2) + 1) / 2,
        )!;
        final color3 = Color.lerp(
          AppColors.brand,
          AppColors.primary,
          (math.sin(animValue * 2 * math.pi + math.pi) + 1) / 2,
        )!;

        return GlassCard(
          hasGlow: true,
          gradient: LinearGradient(
            colors: [color1, color2, color3],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          padding: const EdgeInsets.all(24),
          borderRadius: 24,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TỔNG CHI TIÊU',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$transactionCount giao dịch',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedRainbow(
                child: Text(
                  AppFormatters.formatCurrency(totalAmount),
                  style: AppTextStyles.amount.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
