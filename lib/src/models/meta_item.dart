enum CurrencyType { coins, diamonds }

enum MetaItemType { skin, module, offer, chestReward, wheelReward }

class MetaItem {
  const MetaItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.coinCost = 0,
    this.diamondCost = 0,
    this.rewardCoins = 0,
    this.rewardDiamonds = 0,
  });

  final String id;
  final String title;
  final String description;
  final MetaItemType type;
  final int coinCost;
  final int diamondCost;
  final int rewardCoins;
  final int rewardDiamonds;
}

class MissionItem {
  const MissionItem({
    required this.id,
    required this.title,
    required this.target,
    required this.progress,
    required this.rewardCoins,
    required this.rewardDiamonds,
    required this.isWeekly,
    required this.claimed,
  });

  final String id;
  final String title;
  final int target;
  final int progress;
  final int rewardCoins;
  final int rewardDiamonds;
  final bool isWeekly;
  final bool claimed;

  bool get completed => progress >= target;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'target': target,
        'progress': progress,
        'rewardCoins': rewardCoins,
        'rewardDiamonds': rewardDiamonds,
        'isWeekly': isWeekly,
        'claimed': claimed,
      };

  factory MissionItem.fromJson(Map<String, dynamic> json) => MissionItem(
        id: json['id'] as String,
        title: json['title'] as String,
        target: json['target'] as int,
        progress: json['progress'] as int,
        rewardCoins: json['rewardCoins'] as int,
        rewardDiamonds: json['rewardDiamonds'] as int,
        isWeekly: json['isWeekly'] as bool,
        claimed: json['claimed'] as bool,
      );

  MissionItem copyWith({int? progress, bool? claimed}) => MissionItem(
        id: id,
        title: title,
        target: target,
        progress: progress ?? this.progress,
        rewardCoins: rewardCoins,
        rewardDiamonds: rewardDiamonds,
        isWeekly: isWeekly,
        claimed: claimed ?? this.claimed,
      );
}
