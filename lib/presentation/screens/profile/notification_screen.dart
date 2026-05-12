import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/formatters.dart';
import '../../blocs/budget/budget_bloc.dart';
import '../../blocs/budget/budget_event.dart';
import '../../blocs/budget/budget_state.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/transaction/transaction_state.dart';
import '../../widgets/animated_rainbow.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/premium_button.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _notificationEnabled = false;
  int _selectedHour = 20;
  int _selectedMinute = 0;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadBudgetData();
  }

  void _loadBudgetData() {
    final now = DateTime.now();
    context.read<BudgetBloc>().add(LoadBudget(now.month, now.year));
  }

  Future<void> _loadPreferences() async {
    final enabled = await NotificationService.isEnabled();
    final hour = await NotificationService.getHour();
    final minute = await NotificationService.getMinute();
    if (mounted) {
      setState(() {
        _notificationEnabled = enabled;
        _selectedHour = hour;
        _selectedMinute = minute;
      });
    }
  }

  Future<void> _toggleNotification(bool value) async {
    setState(() => _notificationEnabled = value);
    await NotificationService.setEnabled(value);

    if (value) {
      _scheduleNotification();
    } else {
      await NotificationService().cancelAll();
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _selectedHour, minute: _selectedMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.surface,
              hourMinuteColor: AppColors.surfaceLight,
              dayPeriodColor: AppColors.surfaceLight,
              dialBackgroundColor: AppColors.surfaceLight,
              entryModeIconColor: AppColors.accent,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedHour = picked.hour;
        _selectedMinute = picked.minute;
      });
      await NotificationService.setTime(picked.hour, picked.minute);
      if (_notificationEnabled) {
        _scheduleNotification();
      }
    }
  }

  void _scheduleNotification() {
    final budgetState = context.read<BudgetBloc>().state;
    final transactionState = context.read<TransactionBloc>().state;

    double budget = 0;
    double spent = 0;

    if (budgetState is BudgetLoaded && budgetState.budget != null) {
      budget = budgetState.budget!.amount;
    }
    if (transactionState is TransactionLoaded) {
      spent = transactionState.totalSpendingMonth;
    }

    NotificationService().scheduleDailyBudgetNotification(
      budgetAmount: budget,
      spentAmount: spent,
      hour: _selectedHour,
      minute: _selectedMinute,
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedRainbow(
          child: Text(
            'THÔNG BÁO CHI TIÊU',
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // ─── Budget Status Card ─────────────────
            _buildBudgetStatusCard(),
            const SizedBox(height: 28),

            // ─── Notification Settings ──────────────
            _buildSectionTitle('CÀI ĐẶT THÔNG BÁO'),
            const SizedBox(height: 14),

            // Toggle
            _buildNotificationToggle(),
            const SizedBox(height: 12),

            // Time picker
            _buildTimePicker(),
            const SizedBox(height: 24),

            // ─── Info Section ───────────────────────
            _buildSectionTitle('THÔNG BÁO SẼ BAO GỒM'),
            const SizedBox(height: 14),
            _buildInfoTile(
              icon: Icons.account_balance_wallet_rounded,
              title: 'Mức chi tiêu',
              subtitle: 'Ngân sách bạn đặt cho tháng này',
              color: AppColors.accent,
            ),
            const SizedBox(height: 10),
            _buildInfoTile(
              icon: Icons.savings_rounded,
              title: 'Còn lại bao nhiêu',
              subtitle: 'Số tiền còn có thể chi tiêu',
              color: const Color(0xFF6366F1),
            ),
            const SizedBox(height: 10),
            _buildInfoTile(
              icon: Icons.warning_amber_rounded,
              title: 'Cảnh báo vượt mức',
              subtitle: 'Thông báo khi chi tiêu vượt ngân sách',
              color: AppColors.error,
            ),

            const SizedBox(height: 28),



            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetStatusCard() {
    return BlocBuilder<BudgetBloc, BudgetState>(
      builder: (context, budgetState) {
        return BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, transactionState) {
            double budget = 0;
            double spent = 0;

            if (budgetState is BudgetLoaded && budgetState.budget != null) {
              budget = budgetState.budget!.amount;
            }
            if (transactionState is TransactionLoaded) {
              spent = transactionState.totalSpendingMonth;
            }

            final remaining = budget - spent;
            final isOverBudget = remaining < 0;
            final progress = budget > 0 ? (spent / budget).clamp(0.0, 1.5) : 0.0;

            return GlassCard(
              hasGlow: true,
              gradient: LinearGradient(
                colors: [
                  (isOverBudget ? AppColors.error : AppColors.accent)
                      .withValues(alpha: 0.2),
                  AppColors.surfaceLight.withValues(alpha: 0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              padding: const EdgeInsets.all(24),
              borderRadius: 24,
              child: Column(
                children: [
                  // Status icon & label
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (isOverBudget ? AppColors.error : AppColors.accent)
                          .withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isOverBudget
                          ? Icons.warning_rounded
                          : Icons.check_circle_rounded,
                      color: isOverBudget ? AppColors.error : AppColors.accent,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isOverBudget ? 'VƯỢT MỨC CHI TIÊU' : 'TRONG MỨC CHI TIÊU',
                    style: AppTextStyles.caption.copyWith(
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                      color: isOverBudget ? AppColors.error : AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Progress bar
                  if (budget > 0) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        backgroundColor: AppColors.surfaceLight,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isOverBudget ? AppColors.error : AppColors.accent,
                        ),
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(progress * 100).clamp(0, 999).toStringAsFixed(0)}%',
                          style: AppTextStyles.caption.copyWith(
                            color: isOverBudget
                                ? AppColors.error
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Mức: ${AppFormatters.formatCurrency(budget)}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Stats row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          label: 'Đã chi',
                          value: AppFormatters.formatCurrency(spent),
                          color: AppColors.brand,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppColors.textHint.withValues(alpha: 0.2),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          label: isOverBudget ? 'Vượt mức' : 'Còn lại',
                          value: AppFormatters.formatCurrency(remaining.abs()),
                          color: isOverBudget ? AppColors.error : AppColors.success,
                        ),
                      ),
                    ],
                  ),

                  if (budget == 0) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Hãy đặt mức chi tiêu ở trang Tổng quan để nhận thông báo',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textHint,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textHint,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w800,
            color: color,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: (_notificationEnabled ? AppColors.accent : AppColors.textHint)
              .withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (_notificationEnabled ? AppColors.accent : AppColors.textHint)
                      .withValues(alpha: 0.2),
                  (_notificationEnabled ? AppColors.accent : AppColors.textHint)
                      .withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _notificationEnabled
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_rounded,
              color: _notificationEnabled ? AppColors.accent : AppColors.textHint,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thông báo hàng ngày',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _notificationEnabled ? 'Đang bật' : 'Đang tắt',
                  style: AppTextStyles.caption.copyWith(
                    color: _notificationEnabled
                        ? AppColors.accent
                        : AppColors.textHint,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _notificationEnabled,
            activeTrackColor: AppColors.accent,
            onChanged: _toggleNotification,
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: _pickTime,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFF59E0B).withValues(alpha: 0.2),
                    const Color(0xFFF59E0B).withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.schedule_rounded,
                color: Color(0xFFF59E0B),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Giờ nhắc nhở',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Mỗi ngày lúc ${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}',
                    style: AppTextStyles.caption.copyWith(
                      color: const Color(0xFFF59E0B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}',
                style: AppTextStyles.body.copyWith(
                  color: const Color(0xFFF59E0B),
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.caption.copyWith(
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
