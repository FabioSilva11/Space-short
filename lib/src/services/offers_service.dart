import 'package:shared_preferences/shared_preferences.dart';

import '../models/meta_item.dart';
import 'wallet_service.dart';

class OffersService {
  OffersService._();

  static Future<bool> claimOffer(MetaItem offer) async {
    final prefs = await SharedPreferences.getInstance();
    final claimed = prefs.getStringList('claimedOffers') ?? <String>[];
    if (claimed.contains(offer.id)) return false;
    final paid = await WalletService.spend(diamonds: offer.diamondCost);
    if (!paid) return false;
    await WalletService.add(coins: offer.rewardCoins, diamonds: offer.rewardDiamonds);
    claimed.add(offer.id);
    await prefs.setStringList('claimedOffers', claimed);
    return true;
  }

  static Future<List<String>> claimedOffers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('claimedOffers') ?? <String>[];
  }
}
