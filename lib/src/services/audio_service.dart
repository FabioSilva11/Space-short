import 'package:flame_audio/flame_audio.dart';

import '../assets/space_short_assets.dart';

class SpaceShortAudio {
  SpaceShortAudio._();

  static bool enabled = true;

  static Future<void> preload() async {
    if (!enabled) return;
    try {
      await FlameAudio.audioCache.loadAll([
        SpaceShortAudioAssets.shot,
        SpaceShortAudioAssets.bossAlert,
        SpaceShortAudioAssets.powerUp,
        SpaceShortAudioAssets.gameOver,
        SpaceShortAudioAssets.levelPassed,
      ]);
    } catch (_) {
      // Assets são opcionais durante desenvolvimento; fallback silencioso.
    }
  }

  static Future<void> playShot() => _play(SpaceShortAudioAssets.shot, volume: 0.35);
  static Future<void> playBossAlert() => _play(SpaceShortAudioAssets.bossAlert, volume: 0.8);
  static Future<void> playPowerUp() => _play(SpaceShortAudioAssets.powerUp, volume: 0.7);
  static Future<void> playGameOver() => _play(SpaceShortAudioAssets.gameOver, volume: 0.8);
  static Future<void> playLevelPassed() => _play(SpaceShortAudioAssets.levelPassed, volume: 0.8);

  static Future<void> _play(String file, {double volume = 1}) async {
    if (!enabled) return;
    try {
      await FlameAudio.play(file, volume: volume);
    } catch (_) {
      // Evita crash caso o asset ainda não tenha sido importado.
    }
  }
}
