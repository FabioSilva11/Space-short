import 'package:shared_preferences/shared_preferences.dart';

import 'wallet_service.dart';

class VaultSnapshot {
  const VaultSnapshot({required this.level, required this.storedCoins, required this.capacity, required this.canOpen});

  final int level;
  final int storedCoins;
  final int capacity;
  final bool canOpen;
}

class VaultService {
  VaultService._();

  static Future<VaultSnapshot> load() async {
    final prefs = await SharedPreferences.getInstance();
    final level = prefs.getInt('vaultLevel') ?? 1;
    final stored = prefs.getInt('vaultCoins') ?? 0;
    final capacity = 1000 + level * 750;
    return VaultSnapshot(level: level, storedCoins: stored.clamp(0, capacity), capacity: capacity, canOpen: stored >= capacity);
  }

  static Future<void> depositFromRun(int coinsEarned) async {
    final prefs = await SharedPreferences.getInstance();
    final snapshot = await load();
    final deposit = (coinsEarned * 0.25).round();
    final next = (snapshot.storedCoins + deposit).clamp(0, snapshot.capacity);
    await prefs.setInt('vaultCoins', next);
  }

  static Future<bool> openVault() async {
    final prefs = await SharedPreferences.getInstance();
    final snapshot = await load();
    if (!snapshot.canOpen) return false;
    await WalletService.add(coins: snapshot.storedCoins, diamonds: 10 + snapshot.level * 2);
    await prefs.setInt('vaultCoins', 0);
    return true;
  }

  static Future<bool> upgradeVault() async {
    final prefs = await SharedPreferences.getInstance();
    final snapshot = await load();
    if (snapshot.level >= 5) return false;
    final paid = await WalletService.spend(diamonds: 35 + snapshot.level * 25);
    if (!paid) return false;
    await prefs.setInt('vaultLevel', snapshot.level + 1);
    return true;
  }
}
