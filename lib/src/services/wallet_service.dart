import 'package:shared_preferences/shared_preferences.dart';

class WalletSnapshot {
  const WalletSnapshot({required this.coins, required this.diamonds});

  final int coins;
  final int diamonds;
}

class WalletService {
  WalletService._();

  static Future<WalletSnapshot> load() async {
    final prefs = await SharedPreferences.getInstance();
    return WalletSnapshot(coins: prefs.getInt('coins') ?? 0, diamonds: prefs.getInt('diamonds') ?? 0);
  }

  static Future<bool> spend({int coins = 0, int diamonds = 0}) async {
    final prefs = await SharedPreferences.getInstance();
    final currentCoins = prefs.getInt('coins') ?? 0;
    final currentDiamonds = prefs.getInt('diamonds') ?? 0;
    if (currentCoins < coins || currentDiamonds < diamonds) return false;
    await prefs.setInt('coins', currentCoins - coins);
    await prefs.setInt('diamonds', currentDiamonds - diamonds);
    return true;
  }

  static Future<void> add({int coins = 0, int diamonds = 0}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', (prefs.getInt('coins') ?? 0) + coins);
    await prefs.setInt('diamonds', (prefs.getInt('diamonds') ?? 0) + diamonds);
  }
}
