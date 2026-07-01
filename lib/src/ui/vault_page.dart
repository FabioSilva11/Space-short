import 'package:flutter/material.dart';

import '../services/vault_service.dart';

class VaultPage extends StatefulWidget {
  const VaultPage({super.key});

  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  VaultSnapshot snapshot = const VaultSnapshot(level: 1, storedCoins: 0, capacity: 1750, canOpen: false);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await VaultService.load();
    if (!mounted) return;
    setState(() => snapshot = loaded);
  }

  Future<void> _open() async {
    final success = await VaultService.openVault();
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Cofre aberto' : 'Cofre ainda não está cheio')));
  }

  Future<void> _upgrade() async {
    final success = await VaultService.upgradeVault();
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Cofre melhorado' : 'Diamantes insuficientes')));
  }

  @override
  Widget build(BuildContext context) {
    final progress = snapshot.capacity == 0 ? 0.0 : snapshot.storedCoins / snapshot.capacity;
    return Scaffold(
      appBar: AppBar(title: const Text('Cofre')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.savings, size: 80),
            const SizedBox(height: 16),
            Text('Cofre Nv. ${snapshot.level}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 8),
            Text('${snapshot.storedCoins}/${snapshot.capacity} moedas guardadas', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(onPressed: snapshot.canOpen ? _open : null, child: const Text('Abrir Cofre')),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: snapshot.level < 5 ? _upgrade : null, child: Text('Melhorar Cofre (${35 + snapshot.level * 25} 💎)')),
          ],
        ),
      ),
    );
  }
}
