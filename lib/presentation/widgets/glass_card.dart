import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

/// Enhanced Glassmorphism-style card widget
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final LinearGradient? gradient;
  final double borderRadius;
  final bool hasGlow;
  final double blur;
  final Color? borderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.gradient,
    this.borderRadius = AppConstants.borderRadius,
    this.hasGlow = false,
    this.blur = 16.0, // Increased default blur
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: hasGlow
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: -10,
                  )
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(
              decoration: BoxDecoration(
                gradient: gradient ??
                    (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.glassGradient
                        : LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.7),
                              Colors.white.withValues(alpha: 0.4),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: borderColor ??
                      (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.12)
                          : AppColors.primary.withValues(alpha: 0.08)),
                  width: 1.2,
                ),
              ),
              child: Stack(
                children: [
                  // Subtle inner highlight
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.05),
                            Colors.transparent,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        padding ?? const EdgeInsets.all(AppConstants.padding),
                    child: child,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
