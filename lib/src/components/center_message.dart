import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/space_short_game.dart';

class CenterMessage extends PositionComponent with HasGameReference<SpaceShortGame> {
  CenterMessage({required this.title, required this.subtitle, required this.action});

  final String title;
  final String subtitle;
  final String action;

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromCenter(center: Offset(game.size.x / 2, game.size.y / 2), width: game.size.x - 48, height: 220);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(24)), Paint()..color = const Color(0xDD101633));
    _paint(canvas, title, rect.top + 40, 26, FontWeight.w900);
    _paint(canvas, subtitle, rect.top + 96, 16, FontWeight.w600);
    _paint(canvas, action, rect.top + 150, 13, FontWeight.w600);
  }

  void _paint(Canvas canvas, String text, double y, double size, FontWeight weight) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: Colors.white, fontSize: size, fontWeight: weight)),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: game.size.x - 80);
    painter.paint(canvas, Offset((game.size.x - painter.width) / 2, y));
  }
}
