import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/categories.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/budget_entity.dart';
import '../../../domain/entities/transaction_entity.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/notification_service.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/budget/budget_bloc.dart';
import '../../blocs/budget/budget_event.dart';
import '../../blocs/budget/budget_state.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/transaction/transaction_event.dart';
import '../../blocs/transaction/transaction_state.dart';
import '../../widgets/animated_rainbow.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/premium_button.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/spending_chart.dart';
import '../../widgets/transaction_grid_item.dart';
import '../add_transaction/add_transaction_screen.dart';
import '../auth/login_screen.dart';
import '../profile/history_screen.dart';
import 'widgets/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final TransactionBloc _transactionBloc;
  late final BudgetBloc _budgetBloc;
  late AnimationController _fadeController;
  int _currentIndex = 0;

  int get _currentMonth => DateTime.now().month;
  int get _currentYear => DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _transactionBloc = sl<TransactionBloc>();
    _budgetBloc = sl<BudgetBloc>();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _loadData();
  }

  void _loadData() {
    _transactionBloc.add(LoadDashboardData(_currentMonth, _currentYear));
    _budgetBloc.add(LoadBudget(_currentMonth, _currentYear));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _navigateToAddTransaction() async {
    final result = await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AddTransactionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }

  void _syncNotification() async {
    final transactionState = _transactionBloc.state;
    final budgetState = _budgetBloc.state;

    double spent = 0;
    double budget = 0;

    if (transactionState is TransactionLoaded) {
      spent = transactionState.totalSpendingMonth;
    }

    if (budgetState is BudgetLoaded && budgetState.budget != null) {
      budget = budgetState.budget!.amount;
    }

    if (budget > 0) {
      await NotificationService().updateDailyNotification(budget, spent);
    }
  }

  void _showSetBudgetDialog() {
    // Lấy số tiền ngân sách hiện tại từ dashboard (nếu có)
    String initialValue = '';
    if (_budgetBloc.state is BudgetLoaded) {
      final state = _budgetBloc.state as BudgetLoaded;
      if (state.budget != null) {
        initialValue = AppFormatters.formatNumber(state.budget!.amount);
      }
    }

    final controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      barrierColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black.withValues(alpha: 0.8)
          : Colors.black.withValues(alpha: 0.4),
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        content: GlassCard(
          padding: const EdgeInsets.all(32),
          borderRadius: 32,
          hasGlow: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'NGÂN SÁCH THÁNG',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  AnimatedRainbow(
                    child: Text(
                      '₫',
                      style: AppTextStyles.amountLarge.copyWith(
                        color: Colors.white,
                        fontSize: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: IntrinsicWidth(
                      child: AnimatedRainbow(
                        child: TextField(
                          controller: controller,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        autofocus: true,
                        style: AppTextStyles.amountHero.copyWith(
                          color: Colors.white,
                          height: 1.0,
                        ),
                        inputFormatters: [
                          CurrencyInputFormatter(),
                        ],
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: AppTextStyles.amountHero.copyWith(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                          filled: false,
                        ),
                      ),
                    ),
                  ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                AppFormatters.formatMonthYear(_currentMonth, _currentYear),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 40),
              PremiumButton(
                text: 'Lưu ngân sách',
                icon: Icons.check_rounded,
                onTap: () {
                  final amount = AppFormatters.parseCurrency(controller.text);
                  if (amount != null && amount > 0) {
                    _budgetBloc.add(SetBudget(BudgetEntity(
                      month: _currentMonth,
                      year: _currentYear,
                      amount: amount,
                    )));
                    Navigator.pop(context);
                    _loadData();
                  }
                },
                gradient: AppColors.brandGradient,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Bỏ qua',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textHint,
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

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _transactionBloc),
        BlocProvider.value(value: _budgetBloc),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is Unauthenticated) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
          BlocListener<TransactionBloc, TransactionState>(
            listener: (context, state) {
              if (state is TransactionLoaded) {
                _syncNotification();
              }
            },
          ),
          BlocListener<BudgetBloc, BudgetState>(
            listener: (context, state) {
              if (state is BudgetLoaded) {
                _syncNotification();
              }
            },
          ),
        ],
        child: Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: [
              _buildDashboard(),
              const ProfileTab(),
            ],
          ),
          floatingActionButton: _buildFAB(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: _buildBottomNav(),
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return SafeArea(
      child: FadeTransition(
        opacity: _fadeController,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── App Bar ─────────────────────────
            SliverToBoxAdapter(child: _buildAppBar()),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            // ─── Summary Cards ───────────────────
            SliverToBoxAdapter(child: _buildSummaryCards()),
            // ─── Budget Card ─────────────────────
            SliverToBoxAdapter(child: _buildBudgetCard()),
            // ─── Recent Transactions Header ──────
            SliverToBoxAdapter(child: _buildTransactionsHeader()),
            // ─── Transaction List ────────────────
            _buildTransactionList(),
            // ─── Bottom Spacing ──────────────────
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          // Avatar + User name (vertical)
          Expanded(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                String displayName = 'Bạn';
                String? avatarPath;
                if (state is Authenticated) {
                  displayName = state.user.displayName ?? state.user.username;
                  avatarPath = state.user.avatarPath;
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.brandGradient,
                      ),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.surface,
                        backgroundImage: avatarPath != null && avatarPath.isNotEmpty
                            ? (Uri.tryParse(avatarPath)?.hasScheme == true
                                ? NetworkImage(avatarPath)
                                : FileImage(File(avatarPath)) as ImageProvider)
                            : null,
                        child: avatarPath == null || avatarPath.isEmpty
                            ? AnimatedRainbow(
                                child: Text(
                                  displayName.isNotEmpty
                                      ? displayName[0].toUpperCase()
                                      : 'V',
                                  style: AppTextStyles.heading3.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Name
                    AnimatedRainbow(
                      child: Text(
                        displayName,
                        style: AppTextStyles.heading2.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Actions
          Row(
            children: [
              // Budget button
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.surfaceLight.withValues(alpha: 0.5)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadiusSmall),
                ),
                child: IconButton(
                  icon: const Icon(Icons.account_balance_wallet_rounded,
                      color: AppColors.primary),
                  onPressed: _showSetBudgetDialog,
                  tooltip: 'Đặt ngân sách',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoaded) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SpendingChart(
              transactions: state.transactions,
              month: _currentMonth,
              year: _currentYear,
            ),
          );
        }
        return const SizedBox(height: 220);
      },
    );
  }

  Widget _buildSummaryCards() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoading) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                SkeletonLoader.summaryCard(),
                const SizedBox(width: 12),
                SkeletonLoader.summaryCard(),
              ],
            ),
          );
        }

        double totalToday = 0;
        double totalMonth = 0;
        if (state is TransactionLoaded) {
          totalToday = state.totalSpendingToday;
          totalMonth = state.totalSpendingMonth;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              // Today spending
              Expanded(
                child: AnimatedBuilder(
                  animation: RainbowProvider.of(context)!,
                  builder: (context, child) {
                    final animValue = RainbowProvider.of(context)!.value;
                    // Create a shifting rainbow gradient for the card
                    final color1 = Color.lerp(AppColors.primary, AppColors.accent, (math.sin(animValue * 2 * math.pi) + 1) / 2)!;
                    final color2 = Color.lerp(AppColors.accent, AppColors.brand, (math.sin(animValue * 2 * math.pi + math.pi / 2) + 1) / 2)!;
                    final color3 = Color.lerp(AppColors.brand, AppColors.primary, (math.sin(animValue * 2 * math.pi + math.pi) + 1) / 2)!;

                    return GlassCard(
                      hasGlow: true,
                      gradient: LinearGradient(
                        colors: [color1, color2, color3],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      padding: const EdgeInsets.all(20),
                      borderRadius: 24,
                      child: child!,
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.bolt_rounded,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Hôm nay',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: AnimatedRainbow(
                          child: Text(
                            AppFormatters.formatCurrency(totalToday),
                            style: AppTextStyles.amountHero.copyWith(
                              fontSize: 26,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Month spending
              Expanded(
                child: AnimatedBuilder(
                  animation: RainbowProvider.of(context)!,
                  builder: (context, child) {
                    final animValue = RainbowProvider.of(context)!.value;
                    // Offset the animation to make the rainbow "flow" from the first card
                    final offsetValue = animValue + 0.25;
                    final color1 = Color.lerp(AppColors.primary, AppColors.accent, (math.sin(offsetValue * 2 * math.pi) + 1) / 2)!;
                    final color2 = Color.lerp(AppColors.accent, AppColors.brand, (math.sin(offsetValue * 2 * math.pi + math.pi / 2) + 1) / 2)!;
                    final color3 = Color.lerp(AppColors.brand, AppColors.primary, (math.sin(offsetValue * 2 * math.pi + math.pi) + 1) / 2)!;

                    return GlassCard(
                      hasGlow: true,
                      gradient: LinearGradient(
                        colors: [color1, color2, color3],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      padding: const EdgeInsets.all(20),
                      borderRadius: 24,
                      child: child!,
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.auto_graph_rounded,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tháng này',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: AnimatedRainbow(
                          child: Text(
                            AppFormatters.formatCurrency(totalMonth),
                            style: AppTextStyles.amountHero.copyWith(
                              fontSize: 26,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBudgetCard() {
    return BlocBuilder<BudgetBloc, BudgetState>(
      builder: (context, budgetState) {
        return BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, txState) {
            if (budgetState is BudgetLoading || txState is TransactionLoading) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: SkeletonLoader(width: double.infinity, height: 160),
              );
            }

            double budget = 0;
            double spent = 0;

            if (budgetState is BudgetLoaded && budgetState.budget != null) {
              budget = budgetState.budget!.amount;
            } else if (budgetState is BudgetSaved) {
              budget = budgetState.budget.amount;
            }

            if (txState is TransactionLoaded) {
              spent = txState.totalSpendingMonth;
            }

            if (budget <= 0) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: AnimatedBuilder(
                  animation: RainbowProvider.of(context)!,
                  builder: (context, child) {
                    final animValue = RainbowProvider.of(context)!.value;
                    // Slightly offset from the summary cards to create a vertical wave effect
                    final offsetValue = animValue + 0.5;
                    final color1 = Color.lerp(AppColors.primary, AppColors.accent, (math.sin(offsetValue * 2 * math.pi) + 1) / 2)!;
                    final color2 = Color.lerp(AppColors.accent, AppColors.brand, (math.sin(offsetValue * 2 * math.pi + math.pi / 2) + 1) / 2)!;
                    final color3 = Color.lerp(AppColors.brand, AppColors.primary, (math.sin(offsetValue * 2 * math.pi + math.pi) + 1) / 2)!;

                    return GlassCard(
                      onTap: _showSetBudgetDialog,
                      hasGlow: true,
                      gradient: LinearGradient(
                        colors: [color1, color2, color3],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      padding: const EdgeInsets.all(20),
                      borderRadius: 24,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add_rounded,
                                color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Đặt ngân sách tháng này',
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white.withValues(alpha: 0.5),
                            size: 14,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }

            final remaining = budget - spent;
            final progress = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
            final isOverBudget = remaining < 0;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: GlassCard(
                onTap: _showSetBudgetDialog,
                padding: const EdgeInsets.all(24),
                borderRadius: 28,
                hasGlow: progress > 0.8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ngân sách tháng',
                          style: AppTextStyles.subtitle.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isOverBudget
                                ? AppColors.brand.withValues(alpha: 0.2)
                                : AppColors.accent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isOverBudget
                                  ? AppColors.brand.withValues(alpha: 0.3)
                                  : AppColors.accent.withValues(alpha: 0.3),
                            ),
                          ),
                          child: AnimatedRainbow(
                            child: Text(
                              isOverBudget ? 'Vượt mức' : 'Trong mức',
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Progress bar
                    Stack(
                      children: [
                        Container(
                          height: 12,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        AnimatedBuilder(
                          animation: RainbowProvider.of(context)!,
                          builder: (context, _) {
                            final animValue = RainbowProvider.of(context)!.value;
                            final rainbowGradient = isOverBudget
                                ? LinearGradient(colors: [
                                    AppColors.brand,
                                    Color.lerp(AppColors.brand, Colors.white, (math.sin(animValue * 2 * math.pi) + 1) / 2)!,
                                    const Color(0xFFFDA4AF),
                                  ])
                                : LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      Color.lerp(AppColors.primary, AppColors.accent, (math.sin(animValue * 2 * math.pi) + 1) / 2)!,
                                      AppColors.accent,
                                    ],
                                  );
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 1000),
                              curve: Curves.easeOutCubic,
                              height: 12,
                              width: (MediaQuery.of(context).size.width - 88) *
                                  progress,
                              decoration: BoxDecoration(
                                gradient: rainbowGradient,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isOverBudget
                                            ? AppColors.brand
                                            : AppColors.primary)
                                        .withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Đã chi',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: AnimatedRainbow(
                                  child: Text(
                                    AppFormatters.formatCurrency(spent),
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                isOverBudget ? 'Vượt quá' : 'Còn lại',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.center,
                                child: AnimatedRainbow(
                                  child: Text(
                                    AppFormatters.formatCurrency(remaining.abs()),
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Ngân sách',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  AppFormatters.formatCurrency(budget),
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTransactionsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Bạn đã chi tiêu', style: AppTextStyles.heading3),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: _transactionBloc,
                    child: const HistoryScreen(),
                  ),
                ),
              );
            },
            child: AnimatedRainbow(
              child: Text(
                'Xem tất cả',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoading) {
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => SkeletonLoader.transactionItem(),
                childCount: 5,
              ),
            ),
          );
        }

        if (state is TransactionLoaded) {
          final transactions = state.transactions;

          if (transactions.isEmpty) {
            return SliverToBoxAdapter(
              child: _buildEmptyState(),
            );
          }

          // Show max 10 recent transactions
          final displayList = transactions.take(10).toList();

          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: AnimationLimiter(
              child: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tx = displayList[index];
                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 500),
                      columnCount: 3,
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: TransactionGridItem(
                            transaction: tx,
                            onDeleted: () {
                              Future.delayed(
                                const Duration(milliseconds: 300),
                                () => _loadData(),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: displayList.length,
                ),
              ),
            ),
          );
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              size: 40,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có giao dịch nào',
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn nút + để thêm chi tiêu mới',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return AnimatedBuilder(
      animation: RainbowProvider.of(context)!,
      builder: (context, child) {
        final animValue = RainbowProvider.of(context)!.value;
        // Create a shifting rainbow gradient for the FAB
        final color1 = Color.lerp(AppColors.accent, AppColors.brand, (math.sin(animValue * 2 * math.pi) + 1) / 2)!;
        final color2 = Color.lerp(AppColors.brand, AppColors.accentLight, (math.sin(animValue * 2 * math.pi + math.pi / 2) + 1) / 2)!;
        final color3 = Color.lerp(AppColors.accentLight, AppColors.accent, (math.sin(animValue * 2 * math.pi + math.pi) + 1) / 2)!;

        return Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [color1, color2, color3],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: color2.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: color1.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _navigateToAddTransaction,
              customBorder: const CircleBorder(),
              child: AnimatedRainbow(
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 85,
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        border: Border(
          top: BorderSide(
            color: AppColors.surfaceLight.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.dashboard_rounded, 'Tổng quan'),
          const SizedBox(width: 40), // Space for FAB
          _buildNavItem(1, Icons.person_rounded, 'Cá nhân'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accent.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: AnimatedRainbow(
              isStatic: !isSelected,
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textHint,
                size: 26,
              ),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedRainbow(
            isStatic: !isSelected,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isSelected ? Colors.white : AppColors.textHint,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
