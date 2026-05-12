import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

/// Beautiful animated text field with glow effects
class AnimatedInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String label;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int animationDelay;
  final Color? accentColor;

  const AnimatedInputField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.label,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.animationDelay = 0,
    this.accentColor,
  });

  @override
  State<AnimatedInputField> createState() => _AnimatedInputFieldState();
}

class _AnimatedInputFieldState extends State<AnimatedInputField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _focusNode.addListener(() {
      if (mounted) {
        setState(() => _isFocused = _focusNode.hasFocus);
      }
    });

    Future.delayed(Duration(milliseconds: widget.animationDelay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              widget.label,
              style: AppTextStyles.bodySmall.copyWith(
                color: _isFocused
                    ? (widget.accentColor ?? AppColors.accent)
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(AppConstants.borderRadiusSmall),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: (widget.accentColor ?? AppColors.accent)
                            .withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              obscureText: widget.obscureText,
              validator: widget.validator,
              keyboardType: widget.keyboardType,
              style: AppTextStyles.body.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : AppColors.primary,
              ),
              cursorColor: widget.accentColor ?? AppColors.accent,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textHint.withValues(alpha: 0.5),
                ),
                prefixIcon: Icon(
                  widget.prefixIcon,
                  color: _isFocused
                      ? (widget.accentColor ?? AppColors.accent)
                      : AppColors.textHint,
                  size: 22,
                ),
                suffixIcon: widget.suffixIcon,
                filled: true,
                fillColor: _isFocused
                    ? (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.surfaceLight.withValues(alpha: 0.9)
                        : Colors.white)
                    : (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.surfaceLight.withValues(alpha: 0.4)
                        : Colors.grey.withValues(alpha: 0.1)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusSmall),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.1)
                        : AppColors.primary.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusSmall),
                  borderSide: BorderSide(
                    color: widget.accentColor ?? AppColors.accent,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusSmall),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusSmall),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 1.5,
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
