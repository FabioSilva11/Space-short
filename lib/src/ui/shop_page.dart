import 'package:flutter/material.dart';

import '../data/meta_catalog.dart';
import '../services/shop_service.dart';
import '../services/wallet_service.dart';
import 'widgets/wallet_header.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  WalletSnapshot wallet = const WalletSnapshot(coins: 0, diamonds: 0);
  List<String> owned = const [];
  String equipped = 'default';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loadedWallet = await WalletService.load();
    final loadedOwned = await ShopService.ownedSkins();
    final loadedEquipped = await ShopService.equippedSkin();
    if (!mounted) return;
    setState(() {
      wallet = loadedWallet;
      owned = loadedOwned;
      equipped = loadedEquipped;
    });
  }

  Future<void> _buy(String id) async {
    final item = MetaCatalog.skins.firstWhere((skin) => skin.id == id);
    final success = await ShopService.buyOrEquipSkin(item);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Skin equipada' : 'Recursos insuficientes')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loja')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          WalletHeader(wallet: wallet),
          const SizedBox(height: 12),
          ...MetaCatalog.skins.map((skin) {
            final isOwned = owned.contains(skin.id);
            final isEquipped = equipped == skin.id;
            return Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.rocket_launch)),
                title: Text(skin.title),
                subtitle: Text('${skin.description}\nCusto: ${skin.coinCost} 🪙  ${skin.diamondCost} 💎'),
                isThreeLine: true,
                trailing: FilledButton(
                  onPressed: () => _buy(skin.id),
                  child: Text(isEquipped ? 'Usando' : isOwned ? 'Equipar' : 'Comprar'),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
