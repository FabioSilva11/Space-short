import '../models/meta_item.dart';

class MetaCatalog {
  static const skins = [
    MetaItem(id: 'default', title: 'Nave Padrão', description: 'Modelo inicial da frota Space Short.', type: MetaItemType.skin),
    MetaItem(id: 'nova_red', title: 'Nova Red', description: 'Skin agressiva com visual vermelho.', type: MetaItemType.skin, coinCost: 1800),
    MetaItem(id: 'cyber_blue', title: 'Cyber Blue', description: 'Skin azul neon para pilotos velozes.', type: MetaItemType.skin, diamondCost: 80),
    MetaItem(id: 'gold_elite', title: 'Gold Elite', description: 'Skin premium dourada.', type: MetaItemType.skin, diamondCost: 180),
  ];

  static const modules = [
    MetaItem(id: 'magnet_core', title: 'Núcleo Magnético', description: 'Atrai estrelas e moedas de mais longe.', type: MetaItemType.module),
    MetaItem(id: 'shield_booster', title: 'Booster de Escudo', description: 'Começa a fase com escudo extra.', type: MetaItemType.module, coinCost: 1600),
    MetaItem(id: 'rapid_trigger', title: 'Gatilho Rápido', description: 'Reduz levemente o intervalo de tiro.', type: MetaItemType.module, diamondCost: 70),
    MetaItem(id: 'lucky_drop', title: 'Drop Sortudo', description: 'Aumenta chance de power-ups.', type: MetaItemType.module, diamondCost: 100),
  ];

  static const offers = [
    MetaItem(id: 'starter_pack', title: 'Pacote Inicial', description: 'Moedas e diamantes para evoluir rápido.', type: MetaItemType.offer, diamondCost: 20, rewardCoins: 2500, rewardDiamonds: 35),
    MetaItem(id: 'pilot_pack', title: 'Pacote Piloto', description: 'Reforço médio de recursos.', type: MetaItemType.offer, diamondCost: 60, rewardCoins: 8000, rewardDiamonds: 90),
    MetaItem(id: 'commander_pack', title: 'Pacote Comandante', description: 'Oferta grande para liberar itens.', type: MetaItemType.offer, diamondCost: 140, rewardCoins: 22000, rewardDiamonds: 210),
  ];

  static const wheelRewards = [
    MetaItem(id: 'coins_150', title: '150 moedas', description: 'Recompensa comum.', type: MetaItemType.wheelReward, rewardCoins: 150),
    MetaItem(id: 'coins_500', title: '500 moedas', description: 'Recompensa boa.', type: MetaItemType.wheelReward, rewardCoins: 500),
    MetaItem(id: 'diamonds_10', title: '10 diamantes', description: 'Recompensa rara.', type: MetaItemType.wheelReward, rewardDiamonds: 10),
    MetaItem(id: 'skin_ticket', title: 'Ticket de skin', description: 'Ganha 1200 moedas para comprar skins.', type: MetaItemType.wheelReward, rewardCoins: 1200),
  ];
}
