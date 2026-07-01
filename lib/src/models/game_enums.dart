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
