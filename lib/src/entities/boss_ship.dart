import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/space_short_game.dart';
import 'enemy_bullet.dart';

class BossShip extends PositionComponent with HasGameReference<SpaceShortGame> {
  BossShip({required this.level}) : super(size: Vector2(118, 76), anchor: Anchor.center);

  final int level;
  double health = 500;
  double shootTimer = 1.1;
  double moveDir = 1;

  @override
  void update(double dt) {
    if (health < 150) {
      position.x += moveDir * 120 * dt;
      if (position.x < 70 || position.x > game.size.x - 70) moveDir *= -1;
    }
    shootTimer -= dt;
    if (shootTimer <= 0) {
      shootTimer = max(0.45, 1.25 - level * 0.04);
      _attack(game.rng.nextInt(9));
    }
  }

  void _attack(int pattern) {
    final playerDir = (game.player.position - position).normalized();
    switch (pattern) {
      case 0:
        _circle(12 + level, 150, const Color(0xFFFFD166));
      case 1:
        _fan(7, 210, const Color(0xFFFF4D6D));
      case 2:
        for (var i = 0; i < 3; i++) {
          game.add(EnemyBullet(position: position + Vector2(0, i * 10), velocity: playerDir * (220 + i * 35), color: Colors.white));
        }
      case 3:
        _circle(16, 135, const Color(0xFF63FFDA), phase: game.runTime * 3);
      case 4:
        for (var i = 0; i < 8; i++) {
          game.add(EnemyBullet(position: Vector2(30 + i * (game.size.x - 60) / 7, position.y), velocity: Vector2(0, 170 + i * 10), color: const Color(0xFFB517FF)));
        }
      case 5:
        for (var x = -2; x <= 2; x++) {
          for (var y = 0; y < 2; y++) {
            game.add(EnemyBullet(position: position + Vector2(x * 22, y * 16), velocity: Vector2(0, 185), color: Colors.red));
          }
        }
      case 6:
        for (var s = 0; s < 5; s++) {
          game.add(EnemyBullet(position: position.clone(), velocity: playerDir * (140 + s * 35), color: const Color(0xFF00B4D8)));
        }
      case 7:
        _circle(8, 185, Colors.white);
      default:
        _circle(10, 120, const Color(0xFF9D4EDD));
        _circle(10, 210, const Color(0xFF9D4EDD), phase: 0.3);
    }
  }

  void _circle(int count, double speed, Color color, {double phase = 0}) {
    for (var i = 0; i < count; i++) {
      final angle = phase + i * pi * 2 / count;
      game.add(EnemyBullet(position: position.clone(), velocity: Vector2(cos(angle), sin(angle)) * speed, color: color));
    }
  }

  void _fan(int count, double speed, Color color) {
    for (var i = 0; i < count; i++) {
      final angle = pi / 2 + (i - (count - 1) / 2) * 0.18;
      game.add(EnemyBullet(position: position.clone(), velocity: Vector2(cos(angle), sin(angle)) * speed, color: color));
    }
  }

  void takeDamage(double amount) {
    health -= amount;
    if (health <= 0) {
      removeFromParent();
      game.bossDefeated();
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(18)), Paint()..color = const Color(0xFF2A2356));
    canvas.drawRect(Rect.fromLTWH(10, 10, (size.x - 20) * (health / 500).clamp(0, 1).toDouble(), 8), Paint()..color = const Color(0xFFFF4D6D));
  }
}
