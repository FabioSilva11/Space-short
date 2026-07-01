import 'package:flutter/material.dart';

import '../models/game_enums.dart';
import '../services/player_progress.dart';
import 'daily_reward_page.dart';
import 'game_page.dart';
import 'hangar_page.dart';
import 'missions_page.dart';
import 'offers_page.dart';
import 'shop_page.dart';
import 'vault_page.dart';
import 'wheel_page.dart';

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  PlayerProgress? progress;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await PlayerProgress.load();
    if (!mounted) return;
    setState(() => progress = loaded);
  }

  Future<void> _upgrade(String key, int value, int cost) async {
    final data = progress;
    if (data == null) return;
    await PlayerProgressStore.upgrade(key, value, cost, data.coins);
    await _load();
  }

  Future<void> _equipWeapon(WeaponType type) async {
    final data = progress;
    if (data == null) return;
    await PlayerProgressStore.equipWeapon(
      currentWeapon: data.weapon,
      targetWeapon: type,
      coins: data.coins,
      diamonds: data.diamonds,
    );
    await _load();
  }

  void _play() {
    final data = progress;
    if (data == null) return;
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => GamePage(
              weapon: data.weapon,
              healthLevel: data.healthLevel,
              fireRateLevel: data.fireRateLevel,
              shieldLevel: data.shieldLevel,
            ),
          ),
        )
        .then((_) => _load());
  }

  Future<void> _open(Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final data = progress;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF050018), Color(0xFF0A123D), Color(0xFF02040A)],
          ),
        ),
        child: SafeArea(
          child: data == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'SPACE SHORT',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: 3),
                      ),
                      const SizedBox(height: 10),
                      Text('🪙 ${data.coins}    💎 ${data.diamonds}    Recorde: Setor ${data.bestLevel}', textAlign: TextAlign.center),
                      const SizedBox(height: 18),
                      FilledButton(onPressed: _play, child: const Text('JOGAR')),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          _MenuButton(label: 'Loja', icon: Icons.store, onTap: () => _open(const ShopPage())),
                          _MenuButton(label: 'Hangar', icon: Icons.rocket_launch, onTap: () => _open(const HangarPage())),
                          _MenuButton(label: 'Missões', icon: Icons.flag, onTap: () => _open(const MissionsPage())),
                          _MenuButton(label: 'Diário', icon: Icons.calendar_month, onTap: () => _open(const DailyRewardPage())),
                          _MenuButton(label: 'Cofre', icon: Icons.savings, onTap: () => _open(const VaultPage())),
                          _MenuButton(label: 'Roleta', icon: Icons.casino, onTap: () => _open(const WheelPage())),
                          _MenuButton(label: 'Ofertas', icon: Icons.local_offer, onTap: () => _open(const OffersPage())),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _UpgradeButton(label: 'Vida', level: data.healthLevel, cost: 450 + data.healthLevel * 350, onTap: () => _upgrade('healthLevel', data.healthLevel, 450 + data.healthLevel * 350)),
                      _UpgradeButton(label: 'Taxa de Tiro', level: data.fireRateLevel, cost: 500 + data.fireRateLevel * 380, onTap: () => _upgrade('fireRateLevel', data.fireRateLevel, 500 + data.fireRateLevel * 380)),
                      _UpgradeButton(label: 'Escudo', level: data.shieldLevel, cost: 520 + data.shieldLevel * 390, onTap: () => _upgrade('shieldLevel', data.shieldLevel, 520 + data.shieldLevel * 390)),
                      const SizedBox(height: 12),
                      const Text('Arsenal', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Wrap(
                        spacing: 8,
                        alignment: WrapAlignment.center,
                        children: WeaponType.values.map((type) {
                          return ChoiceChip(label: Text(type.label), selected: data.weapon == type, onSelected: (_) => _equipWeapon(type));
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      const Text('Spread: 2800 moedas • Laser: 650 diamantes • Homing: 900 diamantes', textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 104,
      child: OutlinedButton.icon(onPressed: onTap, icon: Icon(icon, size: 18), label: Text(label)),
    );
  }
}

class _UpgradeButton extends StatelessWidget {
  const _UpgradeButton({required this.label, required this.level, required this.cost, required this.onTap});

  final String label;
  final int level;
  final int cost;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton(onPressed: level >= 6 ? null : onTap, child: Text('$label  Nv. $level/6  •  $cost 🪙')),
    );
  }
}
