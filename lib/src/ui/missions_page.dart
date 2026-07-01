import 'package:flutter/material.dart';

import '../models/meta_item.dart';
import '../services/missions_service.dart';

class MissionsPage extends StatefulWidget {
  const MissionsPage({super.key});

  @override
  State<MissionsPage> createState() => _MissionsPageState();
}

class _MissionsPageState extends State<MissionsPage> {
  List<MissionItem> missions = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await MissionsService.load();
    if (!mounted) return;
    setState(() => missions = loaded);
  }

  Future<void> _claim(String id) async {
    final success = await MissionsService.claim(id);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Recompensa coletada' : 'Missão ainda não disponível')));
  }

  Future<void> _testProgress() async {
    await MissionsService.addProgress(kills: 5, coins: 100, bosses: 1);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final daily = missions.where((mission) => !mission.isWeekly).toList();
    final weekly = missions.where((mission) => mission.isWeekly).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Missões'), actions: [IconButton(onPressed: _testProgress, icon: const Icon(Icons.bolt))]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Diárias', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ...daily.map(_missionCard),
          const SizedBox(height: 18),
          const Text('Semanais', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ...weekly.map(_missionCard),
        ],
      ),
    );
  }

  Widget _missionCard(MissionItem mission) {
    return Card(
      child: ListTile(
        title: Text(mission.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            LinearProgressIndicator(value: mission.target == 0 ? 0 : mission.progress / mission.target),
            const SizedBox(height: 4),
            Text('${mission.progress}/${mission.target} • ${mission.rewardCoins} 🪙 ${mission.rewardDiamonds} 💎'),
          ],
        ),
        trailing: FilledButton(
          onPressed: mission.completed && !mission.claimed ? () => _claim(mission.id) : null,
          child: Text(mission.claimed ? 'OK' : 'Coletar'),
        ),
      ),
    );
  }
}
