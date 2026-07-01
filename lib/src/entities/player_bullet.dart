import 'dart:ui';

import 'package:flame/components.dart';

import '../game/space_short_game.dart';

class PlayerBullet extends CircleComponent with HasGameReference<SpaceShortGame> {
  PlayerBullet({required Vector2 position, required this.velocity, required this.damage, required Color color, this.pierce = false}) : super(position: position, radius: 4, anchor: Anchor.center, paint: Paint()..color = color);

  Vector2 velocity;
  final double damage;
  final bool pierce;

  @override
  void update(double dt) {
    position += velocity * dt;
    if (position.y < -20 || position.x < -20 || position.x > game.size.x + 20) removeFromParent();
  }
}
