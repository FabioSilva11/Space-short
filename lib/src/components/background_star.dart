import 'dart:ui';

import 'package:flame/components.dart';

import '../game/space_short_game.dart';

class BackgroundStar extends CircleComponent with HasGameReference<SpaceShortGame> {
  BackgroundStar({required super.position, required this.speed}) : super(radius: 1.2, paint: Paint()..color = const Color(0x55FFFFFF));

  final double speed;

  @override
  void update(double dt) {
    position.y += speed * dt;
    if (position.y > game.size.y + 5) removeFromParent();
  }
}
