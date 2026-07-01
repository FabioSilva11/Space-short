import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_enums.dart';

class PlayerProgress {
  const PlayerProgress({
    required this.coins,
    required this.diamonds,
    required this.bestLevel,
    required this.healthLevel,
    required this.fireRateLevel,
    required this.shieldLevel,
    required this.weapon,
  });

  final int coins;
  final int diamonds;
  final int bestLevel;
  final int healthLevel;
  final int fireRateLevel;
  final int shieldLevel;
  final WeaponType weapon;

  static Future<PlayerProgress> load() async {
    final prefs = await SharedPreferences.getInstance();
    return PlayerProgress(
      coins: prefs.getInt('coins') ?? 0,
      diamonds: prefs.getInt('diamonds') ?? 0,
      bestLevel: prefs.getInt('bestLevel') ?? 1,
      healthLevel: prefs.getInt('healthLevel') ?? 0,
      fireRateLevel: prefs.getInt('fireRateLevel') ?? 0,
      shieldLevel: prefs.getInt('shieldLevel') ?? 0,
      weapon: WeaponType.values[prefs.getInt('weapon') ?? 0],
    );
  }
}

class PlayerProgressStore {
  static Future<void> upgrade(String key, int value, int cost, int currentCoins) async {
    if (currentCoins < cost || value >= 6) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', currentCoins - cost);
    await prefs.setInt(key, value + 1);
  }

  static Future<bool> equipWeapon({
    required WeaponType currentWeapon,
    required WeaponType targetWeapon,
    required int coins,
    required int diamonds,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (targetWeapon == WeaponType.spread && currentWeapon != targetWeapon && coins >= 2800) {
      await prefs.setInt('coins', coins - 2800);
    } else if (targetWeapon == WeaponType.laser && currentWeapon != targetWeapon && diamonds >= 650) {
      await prefs.setInt('diamonds', diamonds - 650);
    } else if (targetWeapon == WeaponType.homing && currentWeapon != targetWeapon && diamonds >= 900) {
      await prefs.setInt('diamonds', diamonds - 900);
    } else if (targetWeapon != WeaponType.vulcan && currentWeapon != targetWeapon) {
      return false;
    }

    await prefs.setInt('weapon', targetWeapon.index);
    return true;
  }

  static Future<void> saveRun({
    required int coinsEarned,
    required int diamondsEarned,
    required int level,
    required bool win,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', (prefs.getInt('coins') ?? 0) + coinsEarned);
    await prefs.setInt('diamonds', (prefs.getInt('diamonds') ?? 0) + diamondsEarned);
    if (win) {
      await prefs.setInt('bestLevel', max(prefs.getInt('bestLevel') ?? 1, level));
    }
  }
}
