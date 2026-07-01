import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SpaceShortApp());
}

class SpaceShortApp extends StatelessWidget {
  const SpaceShortApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Space Short',
      theme: ThemeData.dark(useMaterial3: true),
      home: const MainMenuPage(),
    );
  }
}

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  int coins = 0;
  int diamonds = 0;
  int bestLevel = 1;
  int healthLevel = 0;
  int fireRateLevel = 0;
  int shieldLevel = 0;
  WeaponType weapon = WeaponType.vulcan;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      coins = prefs.getInt('coins') ?? 0;
      diamonds = prefs.getInt('diamonds') ?? 0;
      bestLevel = prefs.getInt('bestLevel') ?? 1;
      healthLevel = prefs.getInt('healthLevel') ?? 0;
      fireRateLevel = prefs.getInt('fireRateLevel') ?? 0;
      shieldLevel = prefs.getInt('shieldLevel') ?? 0;
      weapon = WeaponType.values[prefs.getInt('weapon') ?? 0];
    });
  }

  Future<void> _upgrade(String key, int value, int cost) async {
    if (coins < cost || value >= 6) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', coins - cost);
    await prefs.setInt(key, value + 1);
    await _load();
  }

  Future<void> _equipWeapon(WeaponType type) async {
    final prefs = await SharedPreferences.getInstance();
    if (type == WeaponType.spread && weapon != type && coins >= 2800) {
      await prefs.setInt('coins', coins - 2800);
    } else if (type == WeaponType.laser && weapon != type && diamonds >= 650) {
      await prefs.setInt('diamonds', diamonds - 650);
    } else if (type == WeaponType.homing && weapon != type && diamonds >= 900) {
      await prefs.setInt('diamonds', diamonds - 900);
    } else if (type != WeaponType.vulcan && weapon != type) {
      return;
    }
    await prefs.setInt('weapon', type.index);
    await _load();
  }

  void _play() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => GamePage(
              weapon: weapon,
              healthLevel: healthLevel,
              fireRateLevel: fireRateLevel,
              shieldLevel: shieldLevel,
            ),
          ),
        )
        .then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF050018), Color(0xFF0A123D), Color(0xFF02040A)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'SPACE SHORT',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: 3),
                ),
                const SizedBox(height: 10),
                Text('🪙 $coins    💎 $diamonds    Recorde: Setor $bestLevel', textAlign: TextAlign.center),
                const Spacer(),
                FilledButton(onPressed: _play, child: const Text('JOGAR')),
                const SizedBox(height: 10),
                _UpgradeButton(label: 'Vida', level: healthLevel, cost: 450 + healthLevel * 350, onTap: () => _upgrade('healthLevel', healthLevel, 450 + healthLevel * 350)),
                _UpgradeButton(label: 'Taxa de Tiro', level: fireRateLevel, cost: 500 + fireRateLevel * 380, onTap: () => _upgrade('fireRateLevel', fireRateLevel, 500 + fireRateLevel * 380)),
                _UpgradeButton(label: 'Escudo', level: shieldLevel, cost: 520 + shieldLevel * 390, onTap: () => _upgrade('shieldLevel', shieldLevel, 520 + shieldLevel * 390)),
                const SizedBox(height: 12),
                const Text('Arsenal', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8,
                  alignment: WrapAlignment.center,
                  children: WeaponType.values.map((type) {
                    return ChoiceChip(label: Text(type.label), selected: weapon == type, onSelected: (_) => _equipWeapon(type));
                  }).toList(),
                ),
                const SizedBox(height: 8),
                const Text('Spread: 2800 moedas • Laser: 650 diamantes • Homing: 900 diamantes', textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UpgradeButton extends StatelessWidget {
  const _UpgradeButton({required this.label, required this.level, required this.cost, required this.onTap});

  final String label;
  final int level;
  final int cost;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton(onPressed: level >= 6 ? null : onTap, child: Text('$label  Nv. $level/6  •  $cost 🪙')),
    );
  }
}

class GamePage extends StatelessWidget {
  const GamePage({super.key, required this.weapon, required this.healthLevel, required this.fireRateLevel, required this.shieldLevel});

  final WeaponType weapon;
  final int healthLevel;
  final int fireRateLevel;
  final int shieldLevel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: SpaceShortGame(
          weapon: weapon,
          healthLevel: healthLevel,
          fireRateLevel: fireRateLevel,
          shieldLevel: shieldLevel,
          onExit: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}

enum WeaponType { vulcan, spread, laser, homing }

extension WeaponTypeLabel on WeaponType {
  String get label => switch (this) {
        WeaponType.vulcan => 'Vulcan',
        WeaponType.spread => 'Spread',
        WeaponType.laser => 'Laser',
        WeaponType.homing => 'Homing',
      };
}

enum EnemyKind { pink, green, elite }

enum PowerUpType { weaponUp, life, bomb, instantLaser, shield }

enum GamePhase { running, bossWarning, bossFight, completed, gameOver }

class SpaceShortGame extends FlameGame with PanDetector, TapDetector, HasCollisionDetection {
  SpaceShortGame({required this.weapon, required this.healthLevel, required this.fireRateLevel, required this.shieldLevel, required this.onExit});

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
    add(ScreenHitbox());
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
        for (final bullet in children.whereType<EnemyBullet>()) {
          bullet.removeFromParent();
        }
        for (final enemy in children.whereType<EnemyShip>()) {
          enemy.takeDamage(85);
        }
        for (final boss in children.whereType<BossShip>()) {
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', (prefs.getInt('coins') ?? 0) + coinsEarned);
    await prefs.setInt('diamonds', (prefs.getInt('diamonds') ?? 0) + diamondsEarned);
    if (win) await prefs.setInt('bestLevel', max(prefs.getInt('bestLevel') ?? 1, level));
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (phase == GamePhase.completed || phase == GamePhase.gameOver) return;
    player.position += info.delta.global;
    player.position.x = player.position.x.clamp(28, size.x - 28).toDouble();
    player.position.y = player.position.y.clamp(60, size.y - 42).toDouble();
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (phase == GamePhase.completed || phase == GamePhase.gameOver) onExit();
  }
}

class PlayerShip extends PositionComponent with HasGameRef<SpaceShortGame>, CollisionCallbacks {
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
    add(RectangleHitbox());
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
    final level = gameRef.shotLevel;
    if (instantLaserTimer > 0 || weapon == WeaponType.laser) {
      final count = min(3, 1 + level ~/ 2);
      for (var i = 0; i < count; i++) {
        gameRef.add(PlayerBullet(position: position + Vector2((i - (count - 1) / 2) * 14, -28), velocity: Vector2(0, -560), damage: instantLaserTimer > 0 ? 16 : 22, color: const Color(0xFF35F6FF), pierce: true));
      }
      return;
    }
    if (weapon == WeaponType.homing) {
      for (var i = 0; i < min(4, level); i++) {
        gameRef.add(HomingBullet(position: position + Vector2((i - (level - 1) / 2) * 12, -24)));
      }
      return;
    }
    final count = weapon == WeaponType.spread ? min(7, 2 + level) : min(7, 1 + level);
    for (var i = 0; i < count; i++) {
      final center = (count - 1) / 2;
      final angle = (i - center) * (weapon == WeaponType.spread ? 0.18 : 0.08);
      gameRef.add(PlayerBullet(position: position + Vector2((i - center) * 8, -24), velocity: Vector2(sin(angle) * 420, -520 * cos(angle)), damage: weapon == WeaponType.spread ? 8 : 10, color: const Color(0xFFFFE66D)));
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

class EnemyShip extends PositionComponent with HasGameRef<SpaceShortGame>, CollisionCallbacks {
  EnemyShip({required this.kind, required this.level}) : super(size: Vector2(38, 38), anchor: Anchor.center);

  final EnemyKind kind;
  final int level;
  late double health;
  double shootTimer = 1.0;

  @override
  Future<void> onLoad() async {
    health = (kind == EnemyKind.elite ? 42 : 32) + level * 3;
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    position.y += (kind == EnemyKind.elite ? 95 : 80) * dt;
    shootTimer -= dt;
    if (shootTimer <= 0) {
      shootTimer = kind == EnemyKind.pink ? 1.25 : kind == EnemyKind.green ? 1.55 : 1.15;
      shoot();
    }
    if (position.y > gameRef.size.y + 50) removeFromParent();
  }

  void shoot() {
    final dir = (gameRef.player.position - position).normalized();
    final count = kind == EnemyKind.pink ? 1 : kind == EnemyKind.green ? 2 : 3;
    for (var i = 0; i < count; i++) {
      final angle = (i - (count - 1) / 2) * 0.18;
      final velocity = Vector2(dir.x * cos(angle) - dir.y * sin(angle), dir.x * sin(angle) + dir.y * cos(angle)) * 180;
      gameRef.add(EnemyBullet(position: position.clone(), velocity: velocity));
    }
  }

  void takeDamage(double amount) {
    health -= amount;
    if (health <= 0) {
      gameRef.enemyKilled(this);
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

class BossShip extends PositionComponent with HasGameRef<SpaceShortGame>, CollisionCallbacks {
  BossShip({required this.level}) : super(size: Vector2(118, 76), anchor: Anchor.center);

  final int level;
  double health = 500;
  double shootTimer = 1.1;
  double moveDir = 1;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    if (health < 150) {
      position.x += moveDir * 120 * dt;
      if (position.x < 70 || position.x > gameRef.size.x - 70) moveDir *= -1;
    }
    shootTimer -= dt;
    if (shootTimer <= 0) {
      shootTimer = max(0.45, 1.25 - level * 0.04);
      _attack(gameRef.rng.nextInt(9));
    }
  }

  void _attack(int pattern) {
    final playerDir = (gameRef.player.position - position).normalized();
    switch (pattern) {
      case 0:
        _circle(12 + level, 150, const Color(0xFFFFD166));
      case 1:
        _fan(7, 210, const Color(0xFFFF4D6D));
      case 2:
        for (var i = 0; i < 3; i++) {
          gameRef.add(EnemyBullet(position: position + Vector2(0, i * 10), velocity: playerDir * (220 + i * 35), color: Colors.white));
        }
      case 3:
        _circle(16, 135, const Color(0xFF63FFDA), phase: gameRef.runTime * 3);
      case 4:
        for (var i = 0; i < 8; i++) {
          gameRef.add(EnemyBullet(position: Vector2(30 + i * (gameRef.size.x - 60) / 7, position.y), velocity: Vector2(0, 170 + i * 10), color: const Color(0xFFB517FF)));
        }
      case 5:
        for (var x = -2; x <= 2; x++) {
          for (var y = 0; y < 2; y++) {
            gameRef.add(EnemyBullet(position: position + Vector2(x * 22, y * 16), velocity: Vector2(0, 185), color: Colors.red));
          }
        }
      case 6:
        for (var s = 0; s < 5; s++) {
          gameRef.add(EnemyBullet(position: position.clone(), velocity: playerDir * (140 + s * 35), color: const Color(0xFF00B4D8)));
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
      gameRef.add(EnemyBullet(position: position.clone(), velocity: Vector2(cos(angle), sin(angle)) * speed, color: color));
    }
  }

  void _fan(int count, double speed, Color color) {
    for (var i = 0; i < count; i++) {
      final angle = pi / 2 + (i - (count - 1) / 2) * 0.18;
      gameRef.add(EnemyBullet(position: position.clone(), velocity: Vector2(cos(angle), sin(angle)) * speed, color: color));
    }
  }

  void takeDamage(double amount) {
    health -= amount;
    if (health <= 0) {
      removeFromParent();
      gameRef.bossDefeated();
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(18)), Paint()..color = const Color(0xFF2A2356));
    canvas.drawRect(Rect.fromLTWH(10, 10, (size.x - 20) * (health / 500).clamp(0, 1).toDouble(), 8), Paint()..color = const Color(0xFFFF4D6D));
  }
}

class PlayerBullet extends CircleComponent with HasGameRef<SpaceShortGame>, CollisionCallbacks {
  PlayerBullet({required Vector2 position, required this.velocity, required this.damage, required Color color, this.pierce = false}) : super(position: position, radius: 4, anchor: Anchor.center, paint: Paint()..color = color);

  Vector2 velocity;
  final double damage;
  final bool pierce;

  @override
  void update(double dt) {
    position += velocity * dt;
    if (position.y < -20 || position.x < -20 || position.x > gameRef.size.x + 20) removeFromParent();
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    if (other is EnemyShip) {
      other.takeDamage(damage);
      if (!pierce) removeFromParent();
    }
    if (other is BossShip) {
      other.takeDamage(damage);
      if (!pierce) removeFromParent();
    }
  }
}

class HomingBullet extends PlayerBullet {
  HomingBullet({required super.position}) : super(velocity: Vector2(0, -430), damage: 14, color: const Color(0xFF7CFFCB));

  @override
  void update(double dt) {
    final targets = <PositionComponent>[...gameRef.children.whereType<EnemyShip>(), ...gameRef.children.whereType<BossShip>()];
    if (targets.isNotEmpty) {
      targets.sort((a, b) => a.position.distanceTo(position).compareTo(b.position.distanceTo(position)));
      final desired = (targets.first.position - position).normalized() * 430;
      velocity = velocity * 0.92 + desired * 0.08;
    }
    super.update(dt);
  }
}

class EnemyBullet extends CircleComponent with HasGameRef<SpaceShortGame>, CollisionCallbacks {
  EnemyBullet({required Vector2 position, required this.velocity, Color color = const Color(0xFFFF4444)}) : super(position: position, radius: 5, anchor: Anchor.center, paint: Paint()..color = color);

  final Vector2 velocity;

  @override
  void update(double dt) {
    position += velocity * dt;
    if (position.y > gameRef.size.y + 30 || position.y < -30 || position.x < -30 || position.x > gameRef.size.x + 30) removeFromParent();
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    if (other is PlayerShip) {
      other.takeDamage(5);
      removeFromParent();
    }
  }
}

class PowerUp extends CircleComponent with HasGameRef<SpaceShortGame>, CollisionCallbacks {
  PowerUp({required this.type}) : super(radius: 13, anchor: Anchor.center);

  final PowerUpType type;
  Vector2 velocity = Vector2(70, 90);

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    position += velocity * dt;
    if (position.x < 15 || position.x > gameRef.size.x - 15) velocity.x *= -1;
    if (position.y > gameRef.size.y + 20) removeFromParent();
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    if (other is PlayerShip) {
      gameRef.collectPowerUp(type);
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final color = switch (type) { PowerUpType.weaponUp => Colors.yellow, PowerUpType.life => Colors.greenAccent, PowerUpType.bomb => Colors.orange, PowerUpType.instantLaser => Colors.cyanAccent, PowerUpType.shield => Colors.blueAccent };
    canvas.drawCircle(Offset(radius, radius), radius, Paint()..color = color);
    final text = switch (type) { PowerUpType.weaponUp => 'W', PowerUpType.life => '+', PowerUpType.bomb => 'B', PowerUpType.instantLaser => 'L', PowerUpType.shield => 'S' };
    final painter = TextPainter(text: TextSpan(text: text, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, Offset(radius - painter.width / 2, radius - painter.height / 2));
  }
}

class CollectStar extends CircleComponent with HasGameRef<SpaceShortGame>, CollisionCallbacks {
  CollectStar({required Vector2 position, required this.velocity}) : super(position: position, radius: 3, anchor: Anchor.center, paint: Paint()..color = const Color(0xFFFFF3B0));

  Vector2 velocity;

  @override
  void update(double dt) {
    final distance = position.distanceTo(gameRef.player.position);
    if (distance < 130) velocity = (gameRef.player.position - position).normalized() * 260;
    position += velocity * dt;
    velocity.y += 45 * dt;
    if (position.y > gameRef.size.y + 20) removeFromParent();
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    if (other is PlayerShip) {
      gameRef.score += 10;
      gameRef.coinsEarned += 1;
      removeFromParent();
    }
  }
}

class BackgroundStar extends CircleComponent with HasGameRef<SpaceShortGame> {
  BackgroundStar({required super.position, required this.speed}) : super(radius: 1.2, paint: Paint()..color = Colors.white30);

  final double speed;

  @override
  void update(double dt) {
    position.y += speed * dt;
    if (position.y > gameRef.size.y + 5) removeFromParent();
  }
}

class HudText extends TextComponent with HasGameRef<SpaceShortGame> {
  HudText() : super(position: Vector2(12, 12), textRenderer: TextPaint(style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)));

  @override
  void update(double dt) {
    final g = gameRef;
    final phase = switch (g.phase) { GamePhase.running => 'Combate', GamePhase.bossWarning => '⚠ CHEFE', GamePhase.bossFight => 'BOSS', GamePhase.completed => 'Concluído', GamePhase.gameOver => 'Game Over' };
    text = 'HP ${g.player.health.toInt()}/${g.player.maxHealth.toInt()}  ESC ${g.player.shield.toInt()}\nTiro Nv.${g.shotLevel}  $phase  ${g.runTime.toInt()}s\nScore ${g.score}  🪙${g.coinsEarned} 💎${g.diamondsEarned}';
  }
}

class FloatingText extends TextComponent with HasGameRef<SpaceShortGame> {
  FloatingText(String text, Vector2 position) : super(text: text, position: position, anchor: Anchor.center, textRenderer: TextPaint(style: const TextStyle(color: Colors.white, fontSize: 12)));

  double life = 0.8;

  @override
  void update(double dt) {
    life -= dt;
    position.y -= 25 * dt;
    if (life <= 0) removeFromParent();
  }
}

class CenterMessage extends PositionComponent with HasGameRef<SpaceShortGame> {
  CenterMessage({required this.title, required this.subtitle, required this.action});

  final String title;
  final String subtitle;
  final String action;

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromCenter(center: Offset(gameRef.size.x / 2, gameRef.size.y / 2), width: gameRef.size.x - 48, height: 220);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(24)), Paint()..color = const Color(0xDD101633));
    _paint(canvas, title, rect.top + 40, 26, FontWeight.w900);
    _paint(canvas, subtitle, rect.top + 96, 16, FontWeight.w600);
    _paint(canvas, action, rect.top + 150, 13, FontWeight.w600);
  }

  void _paint(Canvas canvas, String text, double y, double size, FontWeight weight) {
    final painter = TextPainter(text: TextSpan(text: text, style: TextStyle(color: Colors.white, fontSize: size, fontWeight: weight)), textAlign: TextAlign.center, textDirection: TextDirection.ltr)..layout(maxWidth: gameRef.size.x - 80);
    painter.paint(canvas, Offset((gameRef.size.x - painter.width) / 2, y));
  }
}
