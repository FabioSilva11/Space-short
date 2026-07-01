import '../models/game_enums.dart';

class SpaceShortImages {
  static const player = 'player_ship.png';
  static const boss = 'boss_ship.png';
  static const enemyPink = 'inimigo_ship1.png';
  static const enemyGreen = 'inimigo_ship2.png';
  static const enemyElite = 'inimigo_ship3.png';

  static const bomb = 'bomb.png';
  static const instant = 'instant.png';
  static const life = 'life.png';
  static const shield = 'shield.png';
  static const weaponUp = 'weapon_up.png';

  static const explosions = [
    'explosion_1.png',
    'explosion_2.png',
    'explosion_3.png',
    'explosion_4.png',
    'explosion_5.png',
    'explosion_6.png',
    'explosion_7.png',
    'explosion_8.png',
    'explosion_9.png',
    'explosion_10.png',
  ];

  static String enemy(EnemyKind kind) => switch (kind) {
        EnemyKind.pink => enemyPink,
        EnemyKind.green => enemyGreen,
        EnemyKind.elite => enemyElite,
      };

  static String powerUp(PowerUpType type) => switch (type) {
        PowerUpType.weaponUp => weaponUp,
        PowerUpType.life => life,
        PowerUpType.bomb => bomb,
        PowerUpType.instantLaser => instant,
        PowerUpType.shield => shield,
      };
}

class SpaceShortAudioAssets {
  static const shot = 'disparo.mp3';
  static const bossAlert = 'alerta_boss.mp3';
  static const purchase = 'compra_som.mp3';
  static const gameOver = 'game_over.mp3';
  static const levelPassed = 'level_passa.mp3';
  static const menu = 'menu_song.mp3';
  static const powerUp = 'power_up_get.mp3';
  static const background1 = 'som_fundo_1.mp3';
  static const background2 = 'som_fundo_2.mp3';
}
