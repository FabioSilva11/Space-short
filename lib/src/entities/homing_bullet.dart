import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'boss_ship.dart';
import 'enemy_ship.dart';
import 'player_bullet.dart';

class HomingBullet extends PlayerBullet {
  HomingBullet({required super.position}) : super(velocity: Vector2(0, -430), damage: 14, color: const Color(0xFF7CFFCB));

  @override
  void update(double dt) {
    final targets = <PositionComponent>[...game.children.whereType<EnemyShip>(), ...game.children.whereType<BossShip>()];
    if (targets.isNotEmpty) {
      targets.sort((a, b) => a.position.distanceTo(position).compareTo(b.position.distanceTo(position)));
      final desired = (targets.first.position - position).normalized() * 430;
      velocity = velocity * 0.92 + desired * 0.08;
    }
    super.update(dt);
  }
}
