import 'package:flutter/material.dart';

import '../data/meta_catalog.dart';
import '../services/hangar_service.dart';
import '../services/wallet_service.dart';
import 'widgets/wallet_header.dart';

class HangarPage extends StatefulWidget {
  const HangarPage({super.key});

  @override
  State<HangarPage> createState() => _HangarPageState();
}

class _HangarPageState extends State<HangarPage> {
  WalletSnapshot wallet = const WalletSnapshot(coins: 0, diamonds: 0);
  HangarSnapshot hangar = const HangarSnapshot(ownedModules: ['magnet_core'], equippedModules: ['magnet_core'], moduleSlots: 1);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loadedWallet = await WalletService.load();
    final loadedHangar = await HangarService.load();
    if (!mounted) return;
    setState(() {
      wallet = loadedWallet;
      hangar = loadedHangar;
    });
  }

  Future<void> _buyModule(String id) async {
    final module = MetaCatalog.modules.firstWhere((item) => item.id == id);
    final success = await HangarService.buyModule(module);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Módulo liberado' : 'Recursos insuficientes')));
  }

  Future<void> _toggle(String id) async {
    await HangarService.toggleModule(id);
    await _load();
  }

  Future<void> _slot() async {
    final success = await HangarService.buyModuleSlot();
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Slot liberado' : 'Não foi possível liberar slot')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hangar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          WalletHeader(wallet: wallet),
          Card(
            child: ListTile(
              title: Text('Slots de módulo: ${hangar.equippedModules.length}/${hangar.moduleSlots}'),
              subtitle: const Text('Você pode equipar até 3 módulos.'),
              trailing: FilledButton(onPressed: _slot, child: const Text('+ Slot')),
            ),
          ),
          const SizedBox(height: 12),
          ...MetaCatalog.modules.map((module) {
            final owned = hangar.ownedModules.contains(module.id);
            final equipped = hangar.equippedModules.contains(module.id);
            return Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.memory)),
                title: Text(module.title),
                subtitle: Text('${module.description}\nCusto: ${module.coinCost} 🪙  ${module.diamondCost} 💎'),
                isThreeLine: true,
                trailing: FilledButton(
                  onPressed: owned ? () => _toggle(module.id) : () => _buyModule(module.id),
                  child: Text(equipped ? 'Remover' : owned ? 'Equipar' : 'Comprar'),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
