import 'package:flutter/material.dart';

import '../data/meta_catalog.dart';
import '../services/offers_service.dart';
import '../services/wallet_service.dart';
import 'widgets/wallet_header.dart';

class OffersPage extends StatefulWidget {
  const OffersPage({super.key});

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  WalletSnapshot wallet = const WalletSnapshot(coins: 0, diamonds: 0);
  List<String> claimed = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loadedWallet = await WalletService.load();
    final loadedClaimed = await OffersService.claimedOffers();
    if (!mounted) return;
    setState(() {
      wallet = loadedWallet;
      claimed = loadedClaimed;
    });
  }

  Future<void> _claim(String id) async {
    final offer = MetaCatalog.offers.firstWhere((item) => item.id == id);
    final success = await OffersService.claimOffer(offer);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Oferta resgatada' : 'Oferta indisponível ou sem diamantes')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ofertas')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          WalletHeader(wallet: wallet),
          const SizedBox(height: 12),
          ...MetaCatalog.offers.map((offer) {
            final used = claimed.contains(offer.id);
            return Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.local_offer)),
                title: Text(offer.title),
                subtitle: Text('${offer.description}\nPaga ${offer.diamondCost} 💎 e recebe ${offer.rewardCoins} 🪙 + ${offer.rewardDiamonds} 💎'),
                isThreeLine: true,
                trailing: FilledButton(onPressed: used ? null : () => _claim(offer.id), child: Text(used ? 'Usada' : 'Resgatar')),
              ),
            );
          }),
        ],
      ),
    );
  }
}
