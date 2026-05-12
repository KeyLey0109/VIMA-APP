import 'dart:math';
import 'package:flutter/material.dart';

/// A floating particle data class
class _Particle {
  double x;
  double y;
  double radius;
  double speedX;
  double speedY;
  double opacity;
  Color color;

  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speedX,
    required this.speedY,
    required this.opacity,
    required this.color,
  });
}

/// Animated particles background - creates floating orbs effect
class ParticlesBackground extends StatefulWidget {
  final int particleCount;

  const ParticlesBackground({super.key, this.particleCount = 30});

  @override
  State<ParticlesBackground> createState() => _ParticlesBackgroundState();
}

class _ParticlesBackgroundState extends State<ParticlesBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final Random _random = Random();

  static const List<Color> _colors = [
    Color(0xFF6C63FF),
    Color(0xFF8B5CF6),
    Color(0xFF00D9A6),
    Color(0xFF06B6D4),
    Color(0xFFA78BFA),
    Color(0xFF3B82F6),
  ];

  @override
  void initState() {
    super.initState();
    _particles = List.generate(widget.particleCount, (_) => _createParticle());
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_updateParticles);
    _controller.repeat();
  }

  _Particle _createParticle() {
    return _Particle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      radius: _random.nextDouble() * 3 + 1,
      speedX: (_random.nextDouble() - 0.5) * 0.002,
      speedY: (_random.nextDouble() - 0.5) * 0.002,
      opacity: _random.nextDouble() * 0.5 + 0.1,
      color: _colors[_random.nextInt(_colors.length)],
    );
  }

  void _updateParticles() {
    for (var p in _particles) {
      p.x += p.speedX;
      p.y += p.speedY;

      // Wrap around edges
      if (p.x < -0.05) p.x = 1.05;
      if (p.x > 1.05) p.x = -0.05;
      if (p.y < -0.05) p.y = 1.05;
      if (p.y > 1.05) p.y = -0.05;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ParticlesPainter(_particles),
      size: Size.infinite,
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  final List<_Particle> particles;

  _ParticlesPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.radius * 2);

      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.radius,
        paint,
      );
    }

    // Draw connection lines between close particles
    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final dx = (particles[i].x - particles[j].x) * size.width;
        final dy = (particles[i].y - particles[j].y) * size.height;
        final dist = sqrt(dx * dx + dy * dy);

        if (dist < 100) {
          final opacity = (1 - dist / 100) * 0.15;
          final paint = Paint()
            ..color = particles[i].color.withValues(alpha: opacity)
            ..strokeWidth = 0.5;

          canvas.drawLine(
            Offset(particles[i].x * size.width, particles[i].y * size.height),
            Offset(particles[j].x * size.width, particles[j].y * size.height),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
