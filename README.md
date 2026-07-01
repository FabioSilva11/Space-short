# Space Short

**Space Short** é um shooter espacial vertical feito em **Flutter + Flame Engine**.

## Estado atual

Este repositório já contém uma primeira versão jogável com:

- menu inicial;
- nave controlada por arrasto/toque;
- tiro automático;
- armas Vulcan, Spread, Laser e Homing;
- inimigos rosa, verde e elite;
- power-ups: Weapon Up, Life, Bomb, Instant Laser e Shield;
- boss com 9 padrões de ataque;
- setores de dificuldade cíclicos;
- moedas, diamantes e progresso salvo localmente;
- upgrades permanentes de vida, taxa de tiro e escudo;
- workflow do GitHub Actions para gerar APK em Release.

## Rodar localmente

```bash
flutter pub get
flutter run
```

## Gerar APK

```bash
flutter build apk --release
```

O arquivo final fica em:

```bash
build/app/outputs/flutter-apk/app-release.apk
```

## Release automática

Ao enviar código para a branch `main`, o GitHub Actions compila o APK e publica em **GitHub Releases** como:

```bash
space-short.apk
```

## Próximos passos

- adicionar sprites e efeitos sonoros reais;
- criar loja completa de skins;
- adicionar missões diárias e semanais;
- criar cofre/baús;
- criar roleta da sorte;
- implementar revive com anúncio recompensado;
- integrar AdMob ou outro sistema de anúncios.
