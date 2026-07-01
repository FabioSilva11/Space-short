import 'dart:math';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../components/background_star.dart';
import '../components/center_message.dart';
import '../components/collect_star.dart';
import '../components/floating_text.dart';
import '../components/hud_text.dart';
import '../entities/boss_ship.dart';
import '../entities/enemy_bullet.dart';
import '../entities/enemy_ship.dart';
import '../entities/player_bullet.dart';
import '../entities/player_ship.dart';
import '../entities/power_up.dart';
import '../models/game_enums.dart';
import '../services/player_progress.dart';

class SpaceShortGame extends FlameGame with PanDetector {
  SpaceShortGame({
    required this.weapon,
    required this.healthLevel,
    required this.fireRateLevel,
    required this.shieldLevel,
    required this.onExit,
  });

  final WeaponType weapon;
  final int healthLevel;
  final int fireRateLevel;
  final int shieldLevel;
  final VoidCallback onExit;
  final Random rng = Random();

  late PlayerShip player;
  GamePhase phase = GamePhase.running;
  double runTime = 0;
  double enemySpawnTimer = 0;
  double starTimer = 0;
  int level = 1;
  int score = 0;
  int coinsEarned = 0;
  int diamondsEarned = 0;
  int kills = 0;
  int shotLevel = 1;
  int killsSinceDrop = 0;

  @override
  Color backgroundColor() => const Color(0xFF02040A);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    player = PlayerShip(
      maxHealth: 100 + healthLevel * 22,
      shield: shieldLevel * 16,
      fireInterval: max(0.12, 0.34 - fireRateLevel * 0.03),
      weapon: weapon,
    )..position = Vector2(size.x / 2, size.y - 90);
    add(player);
    add(HudText());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (phase == GamePhase.completed || phase == GamePhase.gameOver) return;
    runTime += dt;
    _spawnStars(dt);
    if (phase == GamePhase.running && runTime >= 112) phase = GamePhase.bossWarning;
    if (phase == GamePhase.bossWarning && runTime >= 120) _spawnBoss();
    if (phase == GamePhase.running || phase == GamePhase.bossWarning) _spawnEnemies(dt);
    _handleCollisions();
    if (player.health <= 0) _gameOver();
  }

  void _spawnStars(double dt) {
    starTimer -= dt;
    if (starTimer > 0) return;
    starTimer = 0.12;
    add(BackgroundStar(position: Vector2(rng.nextDouble() * size.x, -4), speed: 80 + rng.nextDouble() * 120));
  }

  void _spawnEnemies(double dt) {
    enemySpawnTimer -= dt;
    if (enemySpawnTimer > 0) return;
    enemySpawnTimer = 0.75 * _sectorSpawnModifier;
    final roll = rng.nextDouble();
    add(EnemyShip(kind: roll > 0.82 ? EnemyKind.elite : roll > 0.45 ? EnemyKind.green : EnemyKind.pink, level: level)..position = Vector2(32 + rng.nextDouble() * (size.x - 64), -30));
  }

  double get _sectorSpawnModifier => switch ((level - 1) % 4) { 1 => 0.72, 2 => 1.12, 3 => 0.82, _ => 1.0 };

  void _spawnBoss() {
    phase = GamePhase.bossFight;
    for (final enemy in children.whereType<EnemyShip>()) {
      enemy.removeFromParent();
    }
    add(BossShip(level: level)..position = Vector2(size.x / 2, 90));
  }

  void _handleCollisions() {
    for (final bullet in children.whereType<PlayerBullet>().toList()) {
      for (final enemy in children.whereType<EnemyShip>().toList()) {
        if (_touching(bullet.position, enemy.position, bullet.radius + 20)) {
          enemy.takeDamage(bullet.damage);
          if (!bullet.pierce) bullet.removeFromParent();
          break;
        }
      }
      for (final boss in children.whereType<BossShip>().toList()) {
        if (_touching(bullet.position, boss.position, bullet.radius + 48)) {
          boss.takeDamage(bullet.damage);
          if (!bullet.pierce) bullet.removeFromParent();
        }
      }
    }

    for (final bullet in children.whereType<EnemyBullet>().toList()) {
      if (_touching(bullet.position, player.position, bullet.radius + 18)) {
        player.takeDamage(5);
        bullet.removeFromParent();
      }
    }

    for (final enemy in children.whereType<EnemyShip>().toList()) {
      if (_touching(enemy.position, player.position, 34)) {
        player.takeDamage(enemy.kind == EnemyKind.elite ? 20 : 16);
        enemy.removeFromParent();
      }
    }

    for (final powerUp in children.whereType<PowerUp>().toList()) {
      if (_touching(powerUp.position, player.position, powerUp.radius + 20)) {
        collectPowerUp(powerUp.type);
        powerUp.removeFromParent();
      }
    }

    for (final star in children.whereType<CollectStar>().toList()) {
      if (_touching(star.position, player.position, star.radius + 20)) {
        score += 10;
        coinsEarned += 1;
        star.removeFromParent();
      }
    }
  }

  bool _touching(Vector2 a, Vector2 b, double distance) => a.distanceTo(b) <= distance;

  void enemyKilled(EnemyShip enemy) {
    kills++;
    score += 100;
    coinsEarned += 2;
    killsSinceDrop++;
    add(FloatingText('+100', enemy.position.clone()));
    for (var i = 0; i < 3; i++) {
      add(CollectStar(position: enemy.position.clone(), velocity: Vector2((rng.nextDouble() - 0.5) * 120, -80 - rng.nextDouble() * 80)));
    }
    final forcedDrop = killsSinceDrop >= 16;
    final dropChance = enemy.kind == EnemyKind.elite ? 0.28 : 0.14;
    if (forcedDrop || rng.nextDouble() < dropChance) {
      killsSinceDrop = 0;
      _dropPowerUp(enemy.position.clone());
    }
  }

  void _dropPowerUp(Vector2 position) {
    if (children.whereType<PowerUp>().length >= 5) return;
    final roll = rng.nextDouble();
    var type = roll < 0.48 ? PowerUpType.weaponUp : roll < 0.68 ? PowerUpType.life : roll < 0.83 ? PowerUpType.bomb : roll < 0.95 ? PowerUpType.instantLaser : PowerUpType.shield;
    if (type == PowerUpType.life && player.health >= player.maxHealth) type = PowerUpType.weaponUp;
    add(PowerUp(type: type)..position = position);
  }

  void collectPowerUp(PowerUpType type) {
    score += 100;
    coinsEarned += 10;
    switch (type) {
      case PowerUpType.weaponUp:
        shotLevel = min(5, shotLevel + 1);
      case PowerUpType.life:
        player.health = min(player.maxHealth, player.health + player.maxHealth * 0.1);
      case PowerUpType.bomb:
        for (final bullet in children.whereType<EnemyBullet>().toList()) {
          bullet.removeFromParent();
        }
        for (final enemy in children.whereType<EnemyShip>().toList()) {
          enemy.takeDamage(85);
        }
        for (final boss in children.whereType<BossShip>().toList()) {
          boss.takeDamage(85);
        }
      case PowerUpType.instantLaser:
        player.instantLaserTimer = 8;
      case PowerUpType.shield:
        player.shield = min(player.maxShield + 40, player.shield + 24);
    }
  }

  void bossDefeated() {
    phase = GamePhase.completed;
    score += 5000 * level;
    diamondsEarned += 2;
    level++;
    _saveRun(win: true);
    add(CenterMessage(title: 'FASE CONCLUÍDA', subtitle: '+$diamondsEarned 💎  +$coinsEarned 🪙', action: 'TOCAR PARA VOLTAR'));
  }

  void _gameOver() {
    phase = GamePhase.gameOver;
    _saveRun(win: false);
    add(CenterMessage(title: 'GAME OVER', subtitle: 'Abates: $kills • Score: $score', action: 'TOCAR PARA VOLTAR'));
  }

  Future<void> _saveRun({required bool win}) async {
    await PlayerProgressStore.saveRun(coinsEarned: coinsEarned, diamondsEarned: diamondsEarned, level: level, win: win);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (phase == GamePhase.completed || phase == GamePhase.gameOver) return;
    player.position += info.delta.global;
    player.position.x = player.position.x.clamp(28, size.x - 28).toDouble();
    player.position.y = player.position.y.clamp(60, size.y - 42).toDouble();
  }
}
