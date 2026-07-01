import 'package:flutter/material.dart';

import '../../services/wallet_service.dart';

class WalletHeader extends StatelessWidget {
  const WalletHeader({super.key, required this.wallet});

  final WalletSnapshot wallet;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('🪙 ${wallet.coins}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('💎 ${wallet.diamonds}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
