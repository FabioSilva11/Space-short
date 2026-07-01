import 'package:shared_preferences/shared_preferences.dart';

import 'wallet_service.dart';

class DailyRewardSnapshot {
  const DailyRewardSnapshot({required this.ready, required this.streak, required this.nextText});

  final bool ready;
  final int streak;
  final String nextText;
}

class DailyRewardService {
  DailyRewardService._();

  static Future<DailyRewardSnapshot> load() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getString('dailyRewardDay') ?? '';
    final streak = prefs.getInt('dailyRewardStreak') ?? 0;
    final today = _today();
    return DailyRewardSnapshot(ready: last != today, streak: streak, nextText: last == today ? 'Volte amanhã' : 'Disponível agora');
  }

  static Future<bool> claim() async {
    final prefs = await SharedPreferences.getInstance();
    final snapshot = await load();
    if (!snapshot.ready) return false;
    final newStreak = snapshot.streak + 1;
    final coins = 300 + newStreak * 60;
    final diamonds = newStreak % 7 == 0 ? 25 : 5;
    await WalletService.add(coins: coins, diamonds: diamonds);
    await prefs.setString('dailyRewardDay', _today());
    await prefs.setInt('dailyRewardStreak', newStreak);
    return true;
  }

  static String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }
}
