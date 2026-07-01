import 'package:flutter/material.dart';

import '../data/meta_catalog.dart';
import '../models/meta_item.dart';
import '../services/wheel_service.dart';

class WheelPage extends StatefulWidget {
  const WheelPage({super.key});

  @override
  State<WheelPage> createState() => _WheelPageState();
}

class _WheelPageState extends State<WheelPage> {
  bool freeReady = false;
  MetaItem? lastReward;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ready = await WheelService.freeSpinReady();
    if (!mounted) return;
    setState(() => freeReady = ready);
  }

  Future<void> _spin() async {
    final result = await WheelService.spin();
    await _load();
    if (!mounted) return;
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Diamantes insuficientes')));
      return;
    }
    setState(() => lastReward = result.reward);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Você ganhou: ${result.reward.title}')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Roleta')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(Icons.casino, size: 90),
          const SizedBox(height: 16),
          Text(freeReady ? 'Giro grátis disponível' : 'Próximo giro custa 15 💎', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          FilledButton(onPressed: _spin, child: const Text('Girar')),
          if (lastReward != null) Padding(padding: const EdgeInsets.all(16), child: Text('Último prêmio: ${lastReward!.title}', textAlign: TextAlign.center)),
          const Divider(),
          const Text('Prêmios possíveis', style: TextStyle(fontWeight: FontWeight.bold)),
          ...MetaCatalog.wheelRewards.map((reward) => ListTile(title: Text(reward.title), subtitle: Text(reward.description))),
        ],
      ),
    );
  }
}
