import 'package:shared_preferences/shared_preferences.dart';

import '../models/meta_item.dart';
import 'wallet_service.dart';

class HangarSnapshot {
  const HangarSnapshot({required this.ownedModules, required this.equippedModules, required this.moduleSlots});

  final List<String> ownedModules;
  final List<String> equippedModules;
  final int moduleSlots;
}

class HangarService {
  HangarService._();

  static Future<HangarSnapshot> load() async {
    final prefs = await SharedPreferences.getInstance();
    final owned = prefs.getStringList('ownedModules') ?? ['magnet_core'];
    final equipped = prefs.getStringList('equippedModules') ?? ['magnet_core'];
    final slots = prefs.getInt('moduleSlots') ?? 1;
    await prefs.setStringList('ownedModules', owned);
    await prefs.setStringList('equippedModules', equipped);
    await prefs.setInt('moduleSlots', slots);
    return HangarSnapshot(ownedModules: owned, equippedModules: equipped, moduleSlots: slots);
  }

  static Future<bool> buyModule(MetaItem module) async {
    final prefs = await SharedPreferences.getInstance();
    final snapshot = await load();
    final owned = [...snapshot.ownedModules];
    if (owned.contains(module.id)) return true;
    final paid = await WalletService.spend(coins: module.coinCost, diamonds: module.diamondCost);
    if (!paid) return false;
    owned.add(module.id);
    await prefs.setStringList('ownedModules', owned);
    return true;
  }

  static Future<bool> toggleModule(String moduleId) async {
    final prefs = await SharedPreferences.getInstance();
    final snapshot = await load();
    if (!snapshot.ownedModules.contains(moduleId)) return false;
    final equipped = [...snapshot.equippedModules];
    if (equipped.contains(moduleId)) {
      equipped.remove(moduleId);
    } else {
      if (equipped.length >= snapshot.moduleSlots) equipped.removeAt(0);
      equipped.add(moduleId);
    }
    await prefs.setStringList('equippedModules', equipped);
    return true;
  }

  static Future<bool> buyModuleSlot() async {
    final prefs = await SharedPreferences.getInstance();
    final snapshot = await load();
    if (snapshot.moduleSlots >= 3) return false;
    final cost = snapshot.moduleSlots == 1 ? 40 : 90;
    final paid = await WalletService.spend(diamonds: cost);
    if (!paid) return false;
    await prefs.setInt('moduleSlots', snapshot.moduleSlots + 1);
    return true;
  }
}
