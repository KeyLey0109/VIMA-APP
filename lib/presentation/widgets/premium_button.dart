import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final IconData? icon;
  final LinearGradient? gradient;
  final bool isLoading;
  final double? width;
  final double height;

  const PremiumButton({
    super.key,
    required this.text,
    this.onTap,
    this.icon,
    this.gradient,
    this.isLoading = false,
    this.width,
    this.height = 56,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onTap != null && !widget.isLoading;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: isEnabled ? widget.onTap : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: isEnabled
                ? (widget.gradient ?? AppColors.brandGradient)
                : LinearGradient(
                    colors: [
                      AppColors.surfaceLight,
                      AppColors.surfaceLight.withValues(alpha: 0.5),
                    ],
                  ),
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: (widget.gradient?.colors.first ?? AppColors.accent)
                          .withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            child: Stack(
              children: [
                // Shimmer Overlay
                if (isEnabled)
                  AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (context, child) {
                      return Positioned.fill(
                        child: FractionallySizedBox(
                          widthFactor: 2,
                          alignment: Alignment(
                            -1.5 + (_shimmerController.value * 3),
                            0,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.0),
                                  Colors.white.withValues(alpha: 0.1),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                                stops: const [0.4, 0.5, 0.6],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                
                Center(
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(widget.icon, color: Colors.white, size: 22),
                              const SizedBox(width: 10),
                            ],
                            Text(
                              widget.text,
                              style: AppTextStyles.body.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
