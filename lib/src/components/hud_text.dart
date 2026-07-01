import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/space_short_game.dart';
import '../models/game_enums.dart';

class HudText extends TextComponent with HasGameReference<SpaceShortGame> {
  HudText() : super(position: Vector2(12, 12), textRenderer: TextPaint(style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)));

  @override
  void update(double dt) {
    final phase = switch (game.phase) { GamePhase.running => 'Combate', GamePhase.bossWarning => '⚠ CHEFE', GamePhase.bossFight => 'BOSS', GamePhase.completed => 'Concluído', GamePhase.gameOver => 'Game Over' };
    text = 'HP ${game.player.health.toInt()}/${game.player.maxHealth.toInt()}  ESC ${game.player.shield.toInt()}\nTiro Nv.${game.shotLevel}  $phase  ${game.runTime.toInt()}s\nScore ${game.score}  🪙${game.coinsEarned} 💎${game.diamondsEarned}';
  }
}
