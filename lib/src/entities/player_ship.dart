import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/space_short_game.dart';
import '../models/game_enums.dart';
import 'homing_bullet.dart';
import 'player_bullet.dart';

class PlayerShip extends PositionComponent with HasGameReference<SpaceShortGame> {
  PlayerShip({required this.maxHealth, required this.shield, required this.fireInterval, required this.weapon}) : super(size: Vector2(42, 54), anchor: Anchor.center);

  final double maxHealth;
  final double maxShield = 80;
  final double fireInterval;
  final WeaponType weapon;
  double health = 0;
  double shield;
  double fireTimer = 0;
  double instantLaserTimer = 0;

  @override
  Future<void> onLoad() async {
    health = maxHealth;
  }

  @override
  void update(double dt) {
    fireTimer -= dt;
    instantLaserTimer = max(0, instantLaserTimer - dt);
    if (fireTimer <= 0) {
      fireTimer = instantLaserTimer > 0 ? 0.09 : fireInterval;
      shoot();
    }
  }

  void shoot() {
    final shot = game.shotLevel;
    if (instantLaserTimer > 0 || weapon == WeaponType.laser) {
      final count = min(3, 1 + shot ~/ 2);
      for (var i = 0; i < count; i++) {
        game.add(PlayerBullet(position: position + Vector2((i - (count - 1) / 2) * 14, -28), velocity: Vector2(0, -560), damage: instantLaserTimer > 0 ? 16 : 22, color: const Color(0xFF35F6FF), pierce: true));
      }
      return;
    }
    if (weapon == WeaponType.homing) {
      final count = min(4, shot);
      for (var i = 0; i < count; i++) {
        game.add(HomingBullet(position: position + Vector2((i - (count - 1) / 2) * 12, -24)));
      }
      return;
    }
    final count = weapon == WeaponType.spread ? min(7, 2 + shot) : min(7, 1 + shot);
    for (var i = 0; i < count; i++) {
      final center = (count - 1) / 2;
      final angle = (i - center) * (weapon == WeaponType.spread ? 0.18 : 0.08);
      game.add(PlayerBullet(position: position + Vector2((i - center) * 8, -24), velocity: Vector2(sin(angle) * 420, -520 * cos(angle)), damage: weapon == WeaponType.spread ? 8 : 10, color: const Color(0xFFFFE66D)));
    }
  }

  void takeDamage(double amount) {
    if (shield > 0) {
      shield = max(0, shield - amount);
    } else {
      health -= amount;
    }
  }

  @override
  void render(Canvas canvas) {
    final path = Path()
      ..moveTo(size.x / 2, 0)
      ..lineTo(size.x, size.y)
      ..lineTo(size.x / 2, size.y * 0.78)
      ..lineTo(0, size.y)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF6C63FF));
    canvas.drawCircle(Offset(size.x / 2, size.y * 0.55), 7, Paint()..color = Colors.white);
  }
}
