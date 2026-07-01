import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/space_short_game.dart';
import '../models/game_enums.dart';
import 'enemy_bullet.dart';

class EnemyShip extends PositionComponent with HasGameReference<SpaceShortGame> {
  EnemyShip({required this.kind, required this.level}) : super(size: Vector2(38, 38), anchor: Anchor.center);

  final EnemyKind kind;
  final int level;
  late double health;
  double shootTimer = 1.0;

  @override
  Future<void> onLoad() async {
    health = (kind == EnemyKind.elite ? 42 : 32) + level * 3;
  }

  @override
  void update(double dt) {
    position.y += (kind == EnemyKind.elite ? 95 : 80) * dt;
    shootTimer -= dt;
    if (shootTimer <= 0) {
      shootTimer = kind == EnemyKind.pink ? 1.25 : kind == EnemyKind.green ? 1.55 : 1.15;
      shoot();
    }
    if (position.y > game.size.y + 50) removeFromParent();
  }

  void shoot() {
    final dir = (game.player.position - position).normalized();
    final count = kind == EnemyKind.pink ? 1 : kind == EnemyKind.green ? 2 : 3;
    for (var i = 0; i < count; i++) {
      final angle = (i - (count - 1) / 2) * 0.18;
      final velocity = Vector2(dir.x * cos(angle) - dir.y * sin(angle), dir.x * sin(angle) + dir.y * cos(angle)) * 180;
      game.add(EnemyBullet(position: position.clone(), velocity: velocity));
    }
  }

  void takeDamage(double amount) {
    health -= amount;
    if (health <= 0) {
      game.enemyKilled(this);
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final color = switch (kind) { EnemyKind.pink => const Color(0xFFFF4FD8), EnemyKind.green => const Color(0xFF4DFF88), EnemyKind.elite => const Color(0xFFFF884D) };
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(10)), Paint()..color = color);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 6, Paint()..color = Colors.black54);
  }
}
