import 'dart:ui';

import 'package:flame/components.dart';

import '../game/space_short_game.dart';

class EnemyBullet extends CircleComponent with HasGameReference<SpaceShortGame> {
  EnemyBullet({required Vector2 position, required this.velocity, Color color = const Color(0xFFFF4444)}) : super(position: position, radius: 5, anchor: Anchor.center, paint: Paint()..color = color);

  final Vector2 velocity;

  @override
  void update(double dt) {
    position += velocity * dt;
    if (position.y > game.size.y + 30 || position.y < -30 || position.x < -30 || position.x > game.size.x + 30) removeFromParent();
  }
}
