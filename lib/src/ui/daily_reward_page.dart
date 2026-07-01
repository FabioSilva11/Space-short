import 'package:flutter/material.dart';

import '../services/daily_reward_service.dart';

class DailyRewardPage extends StatefulWidget {
  const DailyRewardPage({super.key});

  @override
  State<DailyRewardPage> createState() => _DailyRewardPageState();
}

class _DailyRewardPageState extends State<DailyRewardPage> {
  DailyRewardSnapshot snapshot = const DailyRewardSnapshot(ready: false, streak: 0, nextText: 'Carregando');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await DailyRewardService.load();
    if (!mounted) return;
    setState(() => snapshot = loaded);
  }

  Future<void> _claim() async {
    final success = await DailyRewardService.claim();
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Recompensa diária coletada' : 'Volte amanhã')));
  }

  @override
  Widget build(BuildContext context) {
    final rewardCoins = 300 + (snapshot.streak + 1) * 60;
    final rewardDiamonds = (snapshot.streak + 1) % 7 == 0 ? 25 : 5;
    return Scaffold(
      appBar: AppBar(title: const Text('Recompensa Diária')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_month, size: 64),
                const SizedBox(height: 16),
                Text('Sequência: ${snapshot.streak} dias', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(snapshot.nextText),
                const SizedBox(height: 16),
                Text('Próxima recompensa: $rewardCoins 🪙  $rewardDiamonds 💎'),
                const SizedBox(height: 20),
                FilledButton(onPressed: snapshot.ready ? _claim : null, child: const Text('Coletar')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
