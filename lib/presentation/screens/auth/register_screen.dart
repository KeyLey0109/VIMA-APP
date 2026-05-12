import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/di/injection_container.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/animated_input_field.dart';
import '../../widgets/particles_background.dart';
import '../../widgets/premium_button.dart';
import '../../widgets/glass_card.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late final AuthBloc _authBloc;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  late AnimationController _headerController;
  late AnimationController _formController;
  late AnimationController _shakeController;
  late AnimationController _successController;
  late AnimationController _brandColorController;

  late Animation<double> _headerSlide;
  late Animation<double> _headerFade;
  late Animation<double> _formSlide;
  late Animation<double> _formFade;
  late Animation<double> _shakeAnimation;
  late Animation<double> _successScale;
  late Animation<Color?> _brandColorAnimation;

  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>();

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _headerSlide = Tween<double>(begin: -30, end: 0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic),
    );
    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );

    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _formSlide = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeOutCubic),
    );
    _formFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeOut),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _successScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );

    _brandColorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );
    _brandColorAnimation = ColorTween(
      begin: AppColors.brand,
      end: AppColors.accent,
    ).animate(_brandColorController);
    _brandColorController.repeat(reverse: true);

    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _formController.forward();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _authBloc.close();
    _headerController.dispose();
    _formController.dispose();
    _shakeController.dispose();
    _successController.dispose();
    _brandColorController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      _authBloc.add(RegisterRequested(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        displayName: _displayNameController.text.trim().isNotEmpty
            ? _displayNameController.text.trim()
            : null,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          setState(() => _isLoading = state is AuthLoading);

          if (state is RegisterSuccess) {
            setState(() => _showSuccess = true);
            _successController.forward();

            final navigator = Navigator.of(context);
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) navigator.pop();
            });
          } else if (state is AuthError) {
            _shakeController.reset();
            _shakeController.forward();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              // Background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: Theme.of(context).brightness == Brightness.dark
                        ? [
                            const Color(0xFF0A0A1A),
                            const Color(0xFF0F0F23),
                            const Color(0xFF1A0A2E),
                          ]
                        : [
                            const Color(0xFFF8FAFC),
                            const Color(0xFFF1F5F9),
                            const Color(0xFFE2E8F0),
                          ],
                  ),
                ),
              ),
              const ParticlesBackground(particleCount: 25),

              // Decorative orbs
              Positioned(
                top: -60,
                left: -80,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accent.withValues(alpha: 0.12),
                        AppColors.accent.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -80,
                right: -60,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.1),
                        AppColors.primary.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // Main content
              SafeArea(
                child: Column(
                  children: [
                    // App bar
                    _buildAppBar(),
                    // Form
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          children: [
                            const SizedBox(height: 4),
                            _buildHeader(),
                            const SizedBox(height: 16),
                            _buildForm(),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Success overlay
              if (_showSuccess) _buildSuccessOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: GlassCard(
              padding: const EdgeInsets.all(8),
              borderRadius: 12,
              blur: 4,
              child: Icon(Icons.arrow_back_ios_rounded,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textPrimary
                      : AppColors.primary,
                  size: 18),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _headerSlide.value),
          child: Opacity(opacity: _headerFade.value, child: child),
        );
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(Icons.person_add_rounded,
                size: 32,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : AppColors.primary),
          ),
          const SizedBox(height: 10),
          Text(
            'Tạo tài khoản',
            style: AppTextStyles.heading1.copyWith(
              fontSize: 24,
              color: _brandColorAnimation.value,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Đăng ký để bắt đầu quản lý chi tiêu',
            style: AppTextStyles.subtitle.copyWith(
              color: AppColors.textHint,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return AnimatedBuilder(
      animation: _formController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _formSlide.value),
          child: Opacity(opacity: _formFade.value, child: child),
        );
      },
      child: AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          final shakeOffset =
              sin(_shakeAnimation.value * pi * 4) *
                  8 *
                  (1 - _shakeAnimation.value);
          return Transform.translate(
            offset: Offset(shakeOffset, 0),
            child: child,
          );
        },
        child: GlassCard(
          padding: const EdgeInsets.all(20),
          borderRadius: 32,
          hasGlow: true,
          blur: 24,
          child: AnimatedBuilder(
            animation: _brandColorAnimation,
            builder: (context, _) {
              final currentColor =
                  _brandColorAnimation.value ?? AppColors.accent;
              return Form(
                key: _formKey,
                child: Column(
                  children: [
                    AnimatedInputField(
                      controller: _displayNameController,
                      label: 'Tên hiển thị',
                      hintText: 'Nhập tên của bạn...',
                      prefixIcon: Icons.badge_rounded,
                      animationDelay: 400,
                      accentColor: currentColor,
                    ),
                    const SizedBox(height: 12),

                    AnimatedInputField(
                      controller: _usernameController,
                      label: 'Tên đăng nhập',
                      hintText: 'Nhập tên đăng nhập...',
                      prefixIcon: Icons.person_rounded,
                      animationDelay: 550,
                      accentColor: currentColor,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên đăng nhập';
                        }
                        if (value.trim().length < 3) {
                          return 'Tên đăng nhập phải có ít nhất 3 ký tự';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    AnimatedInputField(
                      controller: _passwordController,
                      label: 'Mật khẩu',
                      hintText: 'Tạo mật khẩu...',
                      prefixIcon: Icons.lock_rounded,
                      obscureText: _obscurePassword,
                      animationDelay: 700,
                      accentColor: currentColor,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: AppColors.textHint,
                          size: 22,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu';
                        }
                        if (value.length < 4) {
                          return 'Mật khẩu phải có ít nhất 4 ký tự';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    AnimatedInputField(
                      controller: _confirmPasswordController,
                      label: 'Xác nhận mật khẩu',
                      hintText: 'Nhập lại mật khẩu...',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscureConfirm,
                      animationDelay: 850,
                      accentColor: currentColor,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: AppColors.textHint,
                          size: 22,
                        ),
                        onPressed: () {
                          setState(() => _obscureConfirm = !_obscureConfirm);
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng xác nhận mật khẩu';
                        }
                        if (value != _passwordController.text) {
                          return 'Mật khẩu không khớp';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    PremiumButton(
                      text: 'Tạo tài khoản',
                      icon: Icons.person_add_rounded,
                      onTap: _register,
                      isLoading: _isLoading,
                      gradient: LinearGradient(
                        colors: [
                          currentColor,
                          currentColor.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    return AnimatedBuilder(
      animation: _successController,
      builder: (context, child) {
        return Container(
          color: Colors.black.withValues(alpha: 0.7 * _successScale.value),
          child: Center(
            child: Transform.scale(
              scale: _successScale.value,
              child: child,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withValues(alpha: 0.3),
              blurRadius: 40,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.accent,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Đăng ký thành công!',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Đang chuyển về trang đăng nhập...',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
