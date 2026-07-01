import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/meta_item.dart';
import 'wallet_service.dart';

class MissionsService {
  MissionsService._();

  static Future<List<MissionItem>> load() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('missionsDay') != _today()) await _resetDaily(prefs);
    if (prefs.getString('missionsWeek') != _weekKey()) await _resetWeekly(prefs);
    return [
      ..._decode(prefs.getString('dailyMissions')),
      ..._decode(prefs.getString('weeklyMissions')),
    ];
  }

  static Future<void> addProgress({int kills = 0, int coins = 0, int bosses = 0}) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await load();
    final updated = all.map((mission) {
      final gain = switch (mission.id) {
        'daily_kills' => kills,
        'daily_coins' => coins,
        'daily_boss' => bosses,
        'weekly_kills' => kills,
        'weekly_coins' => coins,
        'weekly_bosses' => bosses,
        _ => 0,
      };
      return mission.copyWith(progress: (mission.progress + gain).clamp(0, mission.target));
    }).toList();
    await _saveSplit(prefs, updated);
  }

  static Future<bool> claim(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await load();
    final index = all.indexWhere((mission) => mission.id == id);
    if (index < 0) return false;
    final mission = all[index];
    if (!mission.completed || mission.claimed) return false;
    await WalletService.add(coins: mission.rewardCoins, diamonds: mission.rewardDiamonds);
    all[index] = mission.copyWith(claimed: true);
    await _saveSplit(prefs, all);
    return true;
  }

  static Future<void> _resetDaily(SharedPreferences prefs) async {
    await prefs.setString('missionsDay', _today());
    await prefs.setString('dailyMissions', jsonEncode([
      const MissionItem(id: 'daily_kills', title: 'Abata 20 inimigos', target: 20, progress: 0, rewardCoins: 500, rewardDiamonds: 5, isWeekly: false, claimed: false).toJson(),
      const MissionItem(id: 'daily_coins', title: 'Colete 250 moedas', target: 250, progress: 0, rewardCoins: 300, rewardDiamonds: 8, isWeekly: false, claimed: false).toJson(),
      const MissionItem(id: 'daily_boss', title: 'Enfrente 1 boss', target: 1, progress: 0, rewardCoins: 700, rewardDiamonds: 10, isWeekly: false, claimed: false).toJson(),
    ]));
  }

  static Future<void> _resetWeekly(SharedPreferences prefs) async {
    await prefs.setString('missionsWeek', _weekKey());
    await prefs.setString('weeklyMissions', jsonEncode([
      const MissionItem(id: 'weekly_kills', title: 'Semanal: abata 150 inimigos', target: 150, progress: 0, rewardCoins: 3500, rewardDiamonds: 40, isWeekly: true, claimed: false).toJson(),
      const MissionItem(id: 'weekly_coins', title: 'Semanal: colete 3000 moedas', target: 3000, progress: 0, rewardCoins: 2500, rewardDiamonds: 55, isWeekly: true, claimed: false).toJson(),
      const MissionItem(id: 'weekly_bosses', title: 'Semanal: derrote 5 bosses', target: 5, progress: 0, rewardCoins: 5000, rewardDiamonds: 80, isWeekly: true, claimed: false).toJson(),
    ]));
  }

  static Future<void> _saveSplit(SharedPreferences prefs, List<MissionItem> all) async {
    final daily = all.where((mission) => !mission.isWeekly).map((mission) => mission.toJson()).toList();
    final weekly = all.where((mission) => mission.isWeekly).map((mission) => mission.toJson()).toList();
    await prefs.setString('dailyMissions', jsonEncode(daily));
    await prefs.setString('weeklyMissions', jsonEncode(weekly));
  }

  static List<MissionItem> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((item) => MissionItem.fromJson(item as Map<String, dynamic>)).toList();
  }

  static String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  static String _weekKey() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    return '${start.year}-${start.month}-${start.day}';
  }
}
