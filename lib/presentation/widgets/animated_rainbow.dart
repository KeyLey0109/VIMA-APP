import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// A provider that exposes the global rainbow animation heartbeat.
class RainbowProvider extends InheritedWidget {
  final Animation<double> animation;

  const RainbowProvider({
    super.key,
    required this.animation,
    required super.child,
  });

  static Animation<double>? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RainbowProvider>()?.animation;
  }

  @override
  bool updateShouldNotify(RainbowProvider oldWidget) => animation != oldWidget.animation;
}

/// A wrapper widget that manages the global rainbow animation controller.
class RainbowAnimationGroup extends StatefulWidget {
  final Widget child;
  const RainbowAnimationGroup({super.key, required this.child});

  @override
  State<RainbowAnimationGroup> createState() => _RainbowAnimationGroupState();
}

class _RainbowAnimationGroupState extends State<RainbowAnimationGroup> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RainbowProvider(
      animation: _controller,
      child: widget.child,
    );
  }
}

/// A widget that applies a synchronized moving brand gradient (rainbow effect)
/// to its child using a ShaderMask.
class AnimatedRainbow extends StatelessWidget {
  final Widget child;
  final Animation<double>? animation;
  final List<Color>? colors;
  final bool isStatic;

  const AnimatedRainbow({
    super.key,
    this.child = const SizedBox.shrink(),
    this.animation,
    this.colors,
    this.isStatic = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isStatic) return child;

    // Use provided animation or look it up from the provider
    final effectiveAnimation = animation ?? RainbowProvider.of(context);

    if (effectiveAnimation == null) return child;

    final rainbowColors = colors ?? [
      AppColors.accent,
      AppColors.brand,
      AppColors.accentLight,
      AppColors.accent,
    ];

    return AnimatedBuilder(
      animation: effectiveAnimation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: rainbowColors,
              stops: const [0.0, 0.4, 0.7, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: _GradientRotation(effectiveAnimation.value * 6.28), // 2*pi
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: child,
    );
  }
}

class _GradientRotation extends GradientTransform {
  final double radians;
  const _GradientRotation(this.radians);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final center = bounds.center;
    return Matrix4.identity()
      ..setTranslationRaw(center.dx, center.dy, 0.0)
      ..rotateZ(radians)
      ..setTranslationRaw(-center.dx, -center.dy, 0.0);
  }
}
