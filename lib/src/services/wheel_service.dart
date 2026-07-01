import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/meta_catalog.dart';
import '../models/meta_item.dart';
import 'wallet_service.dart';

class WheelSpinResult {
  const WheelSpinResult({required this.reward, required this.free});

  final MetaItem reward;
  final bool free;
}

class WheelService {
  WheelService._();

  static final Random _rng = Random();

  static Future<bool> freeSpinReady() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('freeSpinDay') != _today();
  }

  static Future<WheelSpinResult?> spin() async {
    final prefs = await SharedPreferences.getInstance();
    final free = await freeSpinReady();
    if (!free) {
      final paid = await WalletService.spend(diamonds: 15);
      if (!paid) return null;
    }
    final pity = prefs.getInt('spinPity') ?? 0;
    final reward = pity >= 8 ? MetaCatalog.wheelRewards.last : MetaCatalog.wheelRewards[_rng.nextInt(MetaCatalog.wheelRewards.length)];
    await WalletService.add(coins: reward.rewardCoins, diamonds: reward.rewardDiamonds);
    await prefs.setInt('spinPity', reward.rewardDiamonds > 0 ? 0 : pity + 1);
    if (free) await prefs.setString('freeSpinDay', _today());
    return WheelSpinResult(reward: reward, free: free);
  }

  static String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }
}
