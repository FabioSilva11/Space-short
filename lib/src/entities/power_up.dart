import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/space_short_game.dart';
import '../models/game_enums.dart';

class PowerUp extends CircleComponent with HasGameReference<SpaceShortGame> {
  PowerUp({required this.type}) : super(radius: 13, anchor: Anchor.center);

  final PowerUpType type;
  Vector2 velocity = Vector2(70, 90);

  @override
  void update(double dt) {
    position += velocity * dt;
    if (position.x < 15 || position.x > game.size.x - 15) velocity.x *= -1;
    if (position.y > game.size.y + 20) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final color = switch (type) { PowerUpType.weaponUp => Colors.yellow, PowerUpType.life => Colors.greenAccent, PowerUpType.bomb => Colors.orange, PowerUpType.instantLaser => Colors.cyanAccent, PowerUpType.shield => Colors.blueAccent };
    canvas.drawCircle(Offset(radius, radius), radius, Paint()..color = color);
    final label = switch (type) { PowerUpType.weaponUp => 'W', PowerUpType.life => '+', PowerUpType.bomb => 'B', PowerUpType.instantLaser => 'L', PowerUpType.shield => 'S' };
    final painter = TextPainter(text: TextSpan(text: label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, Offset(radius - painter.width / 2, radius - painter.height / 2));
  }
}
