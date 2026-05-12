import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/transaction/transaction_event.dart';
import '../../blocs/transaction/transaction_state.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/transaction_grid_item.dart';
import '../../widgets/animated_rainbow.dart';
import '../../widgets/skeleton_loader.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _loadCalendarData();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _loadCalendarData() {
    context.read<TransactionBloc>().add(
          LoadCalendarData(_focusedDay.month, _focusedDay.year),
        );
  }

  List<TransactionEntity> _getEventsForDay(
    DateTime day,
    Map<DateTime, List<TransactionEntity>> grouped,
  ) {
    final key = DateTime(day.year, day.month, day.day);
    return grouped[key] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedRainbow(
          child: Text(
            'LỊCH CHI TIÊU',
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
            Map<DateTime, List<TransactionEntity>> grouped = {};
            List<TransactionEntity> selectedDayTransactions = [];
            double totalMonth = 0;

            if (state is TransactionLoaded) {
              grouped = state.groupedTransactions;
              totalMonth = state.totalSpendingMonth;
              if (_selectedDay != null) {
                selectedDayTransactions =
                    _getEventsForDay(_selectedDay!, grouped);
              }
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ─── Monthly Summary Badge ──────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: _buildMonthlySummary(totalMonth),
                  ),
                ),

                // ─── Calendar Card ─────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      borderRadius: 28,
                      child: TableCalendar<TransactionEntity>(
                        firstDay: DateTime(2020, 1, 1),
                        lastDay: DateTime(2030, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        calendarFormat: _calendarFormat,
                        onFormatChanged: (format) {
                          setState(() => _calendarFormat = format);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                          context.read<TransactionBloc>().add(
                                LoadCalendarData(
                                    focusedDay.month, focusedDay.year),
                              );
                        },
                        eventLoader: (day) =>
                            _getEventsForDay(day, grouped),
                        locale: 'vi_VN',

                        // ─── Calendar Style ────────────────
                        headerStyle: HeaderStyle(
                          formatButtonVisible: true,
                          titleCentered: true,
                          formatButtonDecoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.5),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          formatButtonTextStyle:
                              AppTextStyles.caption.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                          titleTextStyle: AppTextStyles.heading3.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          leftChevronIcon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.chevron_left_rounded,
                              color: AppColors.accent,
                              size: 20,
                            ),
                          ),
                          rightChevronIcon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.accent,
                              size: 20,
                            ),
                          ),
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                          weekendStyle: AppTextStyles.caption.copyWith(
                            color: AppColors.brand.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        calendarStyle: CalendarStyle(
                          outsideDaysVisible: false,
                          cellMargin: const EdgeInsets.all(4),
                          defaultTextStyle: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          weekendTextStyle: AppTextStyles.body.copyWith(
                            color: AppColors.brand.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                          todayDecoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  AppColors.accent.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                          todayTextStyle: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                          selectedDecoration: const BoxDecoration(
                            gradient: AppColors.brandGradient,
                            shape: BoxShape.circle,
                          ),
                          selectedTextStyle: AppTextStyles.body.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          markerDecoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                          markerSize: 6,
                          markersMaxCount: 3,
                          markerMargin:
                              const EdgeInsets.symmetric(horizontal: 1),
                        ),
                      ),
                    ),
                  ),
                ),

                // ─── Selected Day Header ──────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.event_note_rounded,
                            color: AppColors.accent,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedDay != null
                                    ? AppFormatters.formatRelativeDate(
                                        _selectedDay!)
                                    : 'Chọn ngày',
                                style: AppTextStyles.subtitle.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (selectedDayTransactions.isNotEmpty)
                                Text(
                                  '${selectedDayTransactions.length} giao dịch',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (selectedDayTransactions.isNotEmpty)
                          AnimatedRainbow(
                            child: Text(
                              AppFormatters.formatCurrency(
                                selectedDayTransactions.fold<double>(
                                    0, (sum, tx) => sum + tx.amount),
                              ),
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // ─── Transactions List ────────────────
                if (state is TransactionLoading)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: SkeletonLoader.transactionItem(),
                        ),
                        childCount: 5,
                      ),
                    ),
                  )
                else if (selectedDayTransactions.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight
                                  .withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.event_available_rounded,
                              size: 48,
                              color:
                                  AppColors.textHint.withValues(alpha: 0.4),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Không có giao dịch',
                            style: AppTextStyles.subtitle.copyWith(
                              color: AppColors.textHint,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Chọn ngày khác để xem chi tiêu',
                            style: AppTextStyles.caption.copyWith(
                              color:
                                  AppColors.textHint.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
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
                            final tx = selectedDayTransactions[index];
                            return AnimationConfiguration.staggeredGrid(
                              position: index,
                              columnCount: 3,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: TransactionGridItem(
                                    transaction: tx,
                                    onDeleted: () {
                                      Future.delayed(
                                        const Duration(milliseconds: 300),
                                        () => _loadCalendarData(),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: selectedDayTransactions.length,
                        ),
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMonthlySummary(double totalMonth) {
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
          padding: const EdgeInsets.all(20),
          borderRadius: 24,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TỔNG CHI THÁNG',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppFormatters.formatMonthYear(
                          _focusedDay.month, _focusedDay.year),
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedRainbow(
                child: Text(
                  AppFormatters.formatCurrency(totalMonth),
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
