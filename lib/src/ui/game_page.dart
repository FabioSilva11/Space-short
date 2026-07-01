import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/space_short_game.dart';
import '../models/game_enums.dart';

class GamePage extends StatelessWidget {
  const GamePage({
    super.key,
    required this.weapon,
    required this.healthLevel,
    required this.fireRateLevel,
    required this.shieldLevel,
  });

  final WeaponType weapon;
  final int healthLevel;
  final int fireRateLevel;
  final int shieldLevel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: SpaceShortGame(
          weapon: weapon,
          healthLevel: healthLevel,
          fireRateLevel: fireRateLevel,
          shieldLevel: shieldLevel,
          onExit: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}
