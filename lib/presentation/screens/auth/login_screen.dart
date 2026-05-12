import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/di/injection_container.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/animated_input_field.dart';
import '../../widgets/animated_rainbow.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/particles_background.dart';
import '../../widgets/premium_button.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AuthBloc _authBloc;

  bool _obscurePassword = true;
  bool _isLoading = false;

  // Animation controllers
  late AnimationController _logoController;
  late AnimationController _formController;
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late AnimationController _brandColorController;

  // Animations
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _formSlide;
  late Animation<double> _formFade;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<Color?> _brandColorAnimation;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>();

    // Logo bounce-in animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );
    _logoRotation = Tween<double>(begin: -0.5, end: 0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutBack,
      ),
    );

    // Form slide-up animation
    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _formSlide = Tween<double>(begin: 60, end: 0).animate(
      CurvedAnimation(
        parent: _formController,
        curve: Curves.easeOutCubic,
      ),
    );
    _formFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _formController,
        curve: Curves.easeOut,
      ),
    );

    // Pulse animation for logo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
    _pulseController.repeat(reverse: true);

    // Shake animation for errors
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.elasticIn,
      ),
    );

    // Dynamic Brand Color Animation
    _brandColorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );
    _brandColorAnimation = ColorTween(
      begin: AppColors.brand,
      end: AppColors.accent,
    ).animate(_brandColorController);
    _brandColorController.repeat(reverse: true);

    // Start animations cascade
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _formController.forward();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _authBloc.close();
    _logoController.dispose();
    _formController.dispose();
    _pulseController.dispose();
    _shakeController.dispose();
    _brandColorController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      _authBloc.add(LoginRequested(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      ));
    }
  }

  void _shakeForm() {
    _shakeController.reset();
    _shakeController.forward();
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const RegisterScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          setState(() => _isLoading = state is AuthLoading);

          if (state is Authenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const HomeScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                      child: child,
                    ),
                  );
                },
                transitionDuration: const Duration(milliseconds: 600),
              ),
              (route) => false,
            );
          } else if (state is AuthError) {
            _shakeForm();
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
              // ─── Gradient Background ─────────────
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
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

              // ─── Animated Particles ──────────────
              const ParticlesBackground(particleCount: 35),

              // ─── Decorative Orbs ─────────────────
              Positioned(
                top: -80,
                right: -60,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.15),
                        AppColors.primary.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -100,
                left: -80,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accent.withValues(alpha: 0.1),
                        AppColors.accent.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── Main Content ────────────────────
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        _buildLogo(),
                        const SizedBox(height: 24),
                        _buildForm(),
                        const SizedBox(height: 24),
                        _buildFooter(),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    final rainbowAnim = RainbowProvider.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([_logoController, _pulseController, rainbowAnim]),
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScale.value * _pulseAnimation.value,
          child: Transform.rotate(
            angle: _logoRotation.value,
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          // Premium Glassy Logo Container with Animated Rainbow Glow
          AnimatedBuilder(
            animation: rainbowAnim ?? _pulseController, // Fallback if provider not ready
            builder: (context, child) {
              final animValue = rainbowAnim?.value ?? 0.0;
              final currentColor = Color.lerp(
                AppColors.accent,
                AppColors.brand,
                (sin(animValue * 2 * pi) + 1) / 2,
              )!;

              return Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      currentColor.withValues(alpha: 0.5),
                      AppColors.primaryDark.withValues(alpha: 0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: currentColor.withValues(alpha: 0.3),
                      blurRadius: 40,
                      spreadRadius: 5,
                    ),
                  ],
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.2)
                        : AppColors.primary.withValues(alpha: 0.1),
                    width: 2,
                  ),
                ),
                child: child,
              );
            },
            child: Center(
              child: AnimatedRainbow(
                child: Text(
                  'V',
                  style: AppTextStyles.heading1.copyWith(
                    fontSize: 48,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedRainbow(
            child: Text(
              'VIMA',
              style: AppTextStyles.heading1.copyWith(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : AppColors.primary,
                letterSpacing: 12.0,
              ),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedRainbow(
            child: Text(
              'FINANCIAL ASSISTANT',
              style: AppTextStyles.caption.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : AppColors.primaryLight,
                letterSpacing: 4.0,
                fontWeight: FontWeight.w700,
              ),
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
          child: Opacity(
            opacity: _formFade.value,
            child: child,
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          final shakeOffset =
              sin(_shakeAnimation.value * pi * 4) * 8 * (1 - _shakeAnimation.value);
          return Transform.translate(
            offset: Offset(shakeOffset, 0),
            child: child,
          );
        },
        child: GlassCard(
          padding: const EdgeInsets.all(28),
          borderRadius: 32,
          hasGlow: true,
          blur: 24,
          child: AnimatedBuilder(
            animation: _brandColorAnimation,
            builder: (context, _) {
              final currentColor = _brandColorAnimation.value ?? AppColors.accent;
              
              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'Đăng nhập',
                      style: AppTextStyles.heading2.copyWith(
                        fontSize: 24,
                        color: currentColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Chào mừng bạn quay lại!',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Username field
                    AnimatedInputField(
                      controller: _usernameController,
                      label: 'Tên đăng nhập',
                      hintText: 'Nhập tên đăng nhập...',
                      prefixIcon: Icons.person_rounded,
                      animationDelay: 600,
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
                    const SizedBox(height: 20),

                    // Password field
                    AnimatedInputField(
                      controller: _passwordController,
                      label: 'Mật khẩu',
                      hintText: 'Nhập mật khẩu...',
                      prefixIcon: Icons.lock_rounded,
                      obscureText: _obscurePassword,
                      animationDelay: 800,
                      accentColor: currentColor,
                      suffixIcon: IconButton(
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) {
                            return RotationTransition(
                              turns: animation,
                              child: child,
                            );
                          },
                          child: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            key: ValueKey(_obscurePassword),
                            color: AppColors.textHint,
                            size: 22,
                          ),
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
                    const SizedBox(height: 32),

                    // Login button
                    _buildLoginButton(currentColor),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(Color currentColor) {
    return PremiumButton(
      text: 'Đăng nhập',
      icon: Icons.login_rounded,
      onTap: _login,
      isLoading: _isLoading,
      gradient: LinearGradient(
        colors: [
          currentColor,
          currentColor.withValues(alpha: 0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  Widget _buildFooter() {
    return AnimatedBuilder(
      animation: _formController,
      builder: (context, child) {
        return Opacity(
          opacity: _formFade.value,
          child: child,
        );
      },
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: AppColors.surfaceLight.withValues(alpha: 0.5),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'hoặc',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: AppColors.surfaceLight.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Register button - Glass style
          GestureDetector(
            onTap: _navigateToRegister,
            child: GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 16),
              borderRadius: AppConstants.borderRadiusSmall,
              blur: 8,
              child: Center(
                child: AnimatedBuilder(
                  animation: _brandColorAnimation,
                  builder: (context, _) => RichText(
                    text: TextSpan(
                      text: 'Chưa có tài khoản? ',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: 'Đăng ký ngay',
                          style: AppTextStyles.body.copyWith(
                            color: _brandColorAnimation.value,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
