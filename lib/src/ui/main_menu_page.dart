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
      backgroundColor: const Color(0xFF040716),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.75, -0.55),
            radius: 1.15,
            colors: [Color(0xFF1F3D83), Color(0xFF07142E), Color(0xFF02030A)],
          ),
        ),
        child: SafeArea(
          child: data == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TopHud(data: data),
                      const SizedBox(height: 18),
                      _HeroPanel(bestLevel: data.bestLevel, onPlay: _play),
                      const SizedBox(height: 16),
                      GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.75,
                        children: [
                          _FeatureCard(title: 'LOJA', icon: Icons.shopping_cart, color: const Color(0xFFFFD766), alert: true, onTap: () => _open(const ShopPage())),
                          _FeatureCard(title: 'HANGAR', icon: Icons.rocket_launch, color: const Color(0xFF60D7FF), alert: true, onTap: () => _open(const HangarPage())),
                          _FeatureCard(title: 'MISSÕES', icon: Icons.assignment_turned_in, color: const Color(0xFF71FFC8), alert: true, onTap: () => _open(const MissionsPage())),
                          _FeatureCard(title: 'DIÁRIO', icon: Icons.menu_book, color: const Color(0xFFC58CFF), onTap: () => _open(const DailyRewardPage())),
                          _FeatureCard(title: 'COFRE', icon: Icons.savings, color: const Color(0xFF67E8FF), onTap: () => _open(const VaultPage())),
                          _FeatureCard(title: 'ROLETA', icon: Icons.casino, color: const Color(0xFFFF65D8), alert: true, onTap: () => _open(const WheelPage())),
                          _FeatureCard(title: 'OFERTAS', icon: Icons.local_offer, color: const Color(0xFFFFB84D), alert: true, onTap: () => _open(const OffersPage())),
                          _FeatureCard(title: 'RECOMPENSA', icon: Icons.card_giftcard, color: const Color(0xFF62F3FF), onTap: () => _open(const DailyRewardPage())),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _UpgradePanel(
                        data: data,
                        onUpgrade: _upgrade,
                      ),
                      const SizedBox(height: 18),
                      _ArsenalPanel(
                        selected: data.weapon,
                        onSelect: _equipWeapon,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _TopHud extends StatelessWidget {
  const _TopHud({required this.data});

  final PlayerProgress data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [Color(0xFF7B3DFF), Color(0xFF1CE6FF)]),
            border: Border.all(color: Colors.white24),
            boxShadow: const [BoxShadow(color: Color(0xAA7B3DFF), blurRadius: 18)],
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 34),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PILOTO_07', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
              SizedBox(height: 4),
              LinearProgressIndicator(value: 0.45, minHeight: 5, color: Color(0xFFC05CFF), backgroundColor: Colors.white12),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _CurrencyPill(icon: '🪙', value: data.coins),
        const SizedBox(width: 8),
        _CurrencyPill(icon: '💎', value: data.diamonds),
      ],
    );
  }
}

class _CurrencyPill extends StatelessWidget {
  const _CurrencyPill({required this.icon, required this.value});

  final String icon;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xAA071022),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Text('$icon $value', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.bestLevel, required this.onPlay});

  final int bestLevel;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 315,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF6E7DFF).withValues(alpha: 0.45)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xDD080F26), Color(0x9916305F), Color(0x77020816)],
        ),
        boxShadow: const [BoxShadow(color: Color(0x663D66FF), blurRadius: 28)],
      ),
      child: Stack(
        children: [
          Positioned(right: -12, top: 42, child: _ShipIllustration()),
          Positioned(left: 0, top: 4, child: _TitleLogo()),
          Positioned(
            left: 0,
            top: 132,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xAA111A3D),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF8568FF).withValues(alpha: 0.55)),
              ),
              child: Text('🏅 RECORDE\nSETOR $bestLevel', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, height: 1.25)),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 8,
            child: SizedBox(
              height: 70,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC533),
                  foregroundColor: const Color(0xFF281600),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFFFFF0A4), width: 1.5)),
                  elevation: 10,
                ),
                onPressed: onPlay,
                icon: const Icon(Icons.play_arrow, size: 38),
                label: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('JOGAR', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    Text('INICIAR MISSÃO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TitleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SPACE', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: 2, height: 0.92)),
        Text('SHORT', style: TextStyle(color: Color(0xFFC062FF), fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: 2, height: 0.92)),
      ],
    );
  }
}

class _ShipIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 185,
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(width: 135, height: 135, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x331CE6FF), boxShadow: [BoxShadow(color: Color(0xAA1CE6FF), blurRadius: 60)])),
          Transform.rotate(
            angle: -0.18,
            child: CustomPaint(size: const Size(150, 150), painter: _ShipPainter()),
          ),
        ],
      ),
    );
  }
}

class _ShipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final body = Paint()..shader = const LinearGradient(colors: [Color(0xFFE9F4FF), Color(0xFF5A6B88), Color(0xFF251B55)]).createShader(Offset.zero & size);
    final glow = Paint()..color = const Color(0xFFB65CFF)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    final path = Path()
      ..moveTo(size.width * 0.5, 4)
      ..lineTo(size.width * 0.83, size.height * 0.84)
      ..lineTo(size.width * 0.5, size.height * 0.66)
      ..lineTo(size.width * 0.17, size.height * 0.84)
      ..close();
    canvas.drawPath(path.shift(const Offset(0, 5)), glow);
    canvas.drawPath(path, body);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.52), 12, Paint()..color = const Color(0xFF8CEAFF));
    canvas.drawLine(Offset(size.width * 0.5, size.height * 0.78), Offset(size.width * 0.5, size.height), Paint()..color = const Color(0xFFFF6CFF)..strokeWidth = 8..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.title, required this.icon, required this.color, required this.onTap, this.alert = false});

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xAA071022),
          border: Border.all(color: color.withValues(alpha: 0.5)),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.14), blurRadius: 18)],
        ),
        child: Stack(
          children: [
            Positioned(right: -16, top: -18, child: Icon(icon, color: color.withValues(alpha: 0.16), size: 96)),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 36),
                  const SizedBox(height: 8),
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ],
              ),
            ),
            if (alert)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(color: Color(0xFFFF4D5E), shape: BoxShape.circle),
                  child: const Center(child: Text('!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _UpgradePanel extends StatelessWidget {
  const _UpgradePanel({required this.data, required this.onUpgrade});

  final PlayerProgress data;
  final Future<void> Function(String key, int value, int cost) onUpgrade;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color(0xAA071022),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          _UpgradeRow(icon: Icons.favorite, title: 'VIDA', level: data.healthLevel, cost: 450 + data.healthLevel * 350, color: const Color(0xFFFF637D), onTap: () => onUpgrade('healthLevel', data.healthLevel, 450 + data.healthLevel * 350)),
          const Divider(color: Colors.white12),
          _UpgradeRow(icon: Icons.speed, title: 'TAXA DE TIRO', level: data.fireRateLevel, cost: 500 + data.fireRateLevel * 380, color: const Color(0xFF5FE4FF), onTap: () => onUpgrade('fireRateLevel', data.fireRateLevel, 500 + data.fireRateLevel * 380)),
          const Divider(color: Colors.white12),
          _UpgradeRow(icon: Icons.shield, title: 'ESCUDO', level: data.shieldLevel, cost: 520 + data.shieldLevel * 390, color: const Color(0xFF67FFD5), onTap: () => onUpgrade('shieldLevel', data.shieldLevel, 520 + data.shieldLevel * 390)),
        ],
      ),
    );
  }
}

class _UpgradeRow extends StatelessWidget {
  const _UpgradeRow({required this.icon, required this.title, required this.level, required this.cost, required this.color, required this.onTap});

  final IconData icon;
  final String title;
  final int level;
  final int cost;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(width: 12),
        Expanded(child: Text('$title\n$level/6', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, height: 1.25))),
        Text('$cost 🪙', style: const TextStyle(color: Color(0xFFFFD766), fontWeight: FontWeight.w900)),
        const SizedBox(width: 10),
        SizedBox(width: 44, height: 44, child: FilledButton(onPressed: level >= 6 ? null : onTap, style: FilledButton.styleFrom(padding: EdgeInsets.zero, backgroundColor: const Color(0xFF17223F)), child: const Icon(Icons.add))),
      ],
    );
  }
}

class _ArsenalPanel extends StatelessWidget {
  const _ArsenalPanel({required this.selected, required this.onSelect});

  final WeaponType selected;
  final Future<void> Function(WeaponType type) onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(color: const Color(0xFF4A1D80), borderRadius: BorderRadius.circular(12)),
          child: const Text('ARSENAL', style: TextStyle(color: Color(0xFFDCA6FF), fontWeight: FontWeight.w900, letterSpacing: 1)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 142,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, index) {
              final weapon = WeaponType.values[index];
              return _WeaponCard(type: weapon, selected: selected == weapon, onTap: () => onSelect(weapon));
            },
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: WeaponType.values.length,
          ),
        ),
        const SizedBox(height: 8),
        const Text('Spread: 2.800 moedas  •  Laser: 650 diamantes  •  Homing: 900 diamantes', style: TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

class _WeaponCard extends StatelessWidget {
  const _WeaponCard({required this.type, required this.selected, required this.onTap});

  final WeaponType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (type) {
      WeaponType.vulcan => const Color(0xFFFFD766),
      WeaponType.spread => const Color(0xFF5DFF9D),
      WeaponType.laser => const Color(0xFF5FE4FF),
      WeaponType.homing => const Color(0xFFFF6D6D),
    };
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: 128,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xAA071022),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? const Color(0xFFC05CFF) : Colors.white24, width: selected ? 2 : 1),
          boxShadow: selected ? const [BoxShadow(color: Color(0x99B65CFF), blurRadius: 20)] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? Icons.check_circle : Icons.lock_open, color: selected ? const Color(0xFF5DFF9D) : Colors.white38, size: 22),
            const Spacer(),
            Icon(Icons.rocket, color: color, size: 45),
            const Spacer(),
            Text(type.label.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}
