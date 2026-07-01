import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/space_short_game.dart';

class FloatingText extends TextComponent with HasGameReference<SpaceShortGame> {
  FloatingText(String text, Vector2 position) : super(text: text, position: position, anchor: Anchor.center, textRenderer: TextPaint(style: const TextStyle(color: Colors.white, fontSize: 12)));

  double life = 0.8;

  @override
  void update(double dt) {
    life -= dt;
    position.y -= 25 * dt;
    if (life <= 0) removeFromParent();
  }
}
