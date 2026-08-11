/// Emoji 悬浮绘制 — 在 AR 层上绘制 Emoji 装饰

import 'dart:math';

import 'package:flutter/material.dart';

import 'package:arphoto/shared/types.dart';

/// Emoji 绘制器 Widget
class EmojiPainter extends StatefulWidget {
  final List<EmojiConfig> emojis;

  const EmojiPainter({super.key, required this.emojis});

  @override
  State<EmojiPainter> createState() => _EmojiPainterState();
}

class _EmojiPainterState extends State<EmojiPainter>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return CustomPaint(
          painter: _EmojiCustomPainter(
            emojis: widget.emojis,
            animationValue: _animController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

/// Emoji 自定义绘制器
class _EmojiCustomPainter extends CustomPainter {
  final List<EmojiConfig> emojis;
  final double animationValue;

  _EmojiCustomPainter({
    required this.emojis,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (emojis.isEmpty) {
      _drawDefaultEmojis(canvas, size);
      return;
    }

    for (final emoji in emojis) {
      _drawEmoji(
        canvas,
        emoji: emoji.emoji,
        x: emoji.x * size.width,
        y: emoji.y * size.height + _bounceOffset(emoji.y),
        scale: emoji.scale,
        rotation: emoji.rotation,
        opacity: emoji.opacity,
      );
    }
  }

  void _drawDefaultEmojis(Canvas canvas, Size size) {
    const defaultEmojis = ['✨', '🌟', '💫', '⭐', '🎉'];
    const count = 5;

    for (int i = 0; i < count; i++) {
      final x = size.width * (0.1 + i * 0.2);
      final y = size.height * (0.2 + (i.isEven ? 0.0 : 0.3));
      final bounce = sin(animationValue * 2 * pi + i * 1.2) * 10;

      _drawEmoji(
        canvas,
        emoji: defaultEmojis[i],
        x: x,
        y: y + bounce,
        scale: 1.5,
        rotation: animationValue * 0.2 + i * 0.5,
        opacity: 0.8 + sin(animationValue * pi + i) * 0.2,
      );
    }
  }

  void _drawEmoji(
    Canvas canvas, {
    required String emoji,
    required double x,
    required double y,
    required double scale,
    required double rotation,
    required double opacity,
  }) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(rotation);
    canvas.scale(scale);

    final textPainter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(
          fontSize: 32,
          color: Colors.white.withOpacity(opacity),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
        canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
    canvas.restore();
  }

  double _bounceOffset(double baseY) {
    return sin(animationValue * 2 * pi + baseY * 10) * 8;
  }

  @override
  bool shouldRepaint(_EmojiCustomPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.emojis != emojis;
  }
}