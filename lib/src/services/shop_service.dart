import 'package:shared_preferences/shared_preferences.dart';

import '../models/meta_item.dart';
import 'wallet_service.dart';

class ShopService {
  ShopService._();

  static Future<List<String>> ownedSkins() async {
    final prefs = await SharedPreferences.getInstance();
    final owned = prefs.getStringList('ownedSkins');
    if (owned != null) return owned;
    await prefs.setStringList('ownedSkins', ['default']);
    return ['default'];
  }

  static Future<String> equippedSkin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('equippedSkin') ?? 'default';
  }

  static Future<bool> buyOrEquipSkin(MetaItem skin) async {
    final prefs = await SharedPreferences.getInstance();
    final owned = await ownedSkins();
    if (!owned.contains(skin.id)) {
      final paid = await WalletService.spend(coins: skin.coinCost, diamonds: skin.diamondCost);
      if (!paid) return false;
      owned.add(skin.id);
      await prefs.setStringList('ownedSkins', owned);
    }
    await prefs.setString('equippedSkin', skin.id);
    return true;
  }
}
