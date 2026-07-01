import 'dart:ui';

import 'package:flame/components.dart';

import '../game/space_short_game.dart';

class CollectStar extends CircleComponent with HasGameReference<SpaceShortGame> {
  CollectStar({required Vector2 position, required this.velocity}) : super(position: position, radius: 3, anchor: Anchor.center, paint: Paint()..color = const Color(0xFFFFF3B0));

  Vector2 velocity;

  @override
  void update(double dt) {
    final distance = position.distanceTo(game.player.position);
    if (distance < 130) velocity = (game.player.position - position).normalized() * 260;
    position += velocity * dt;
    velocity.y += 45 * dt;
    if (position.y > game.size.y + 20) removeFromParent();
  }
}
