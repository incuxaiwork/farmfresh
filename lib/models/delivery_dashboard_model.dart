class DeliveryDashboardModel {
  final DeliveryStats stats;
  final List<DeliveryEarningsSummary> recentEarnings;
  final int unreadNotifications;

  DeliveryDashboardModel({
    required this.stats,
    required this.recentEarnings,
    required this.unreadNotifications,
  });

  factory DeliveryDashboardModel.fromJson(Map<String, dynamic> json) {
    return DeliveryDashboardModel(
      stats: DeliveryStats.fromJson(json['stats'] ?? {}),
      recentEarnings: (json['recentEarnings'] as List?)
              ?.map((e) => DeliveryEarningsSummary.fromJson(e))
              .toList() ??
          [],
      unreadNotifications: json['unreadNotifications'] ?? 0,
    );
  }
}

class DeliveryStats {
  final double todayEarnings;
  final double weeklyEarnings;
  final double monthlyEarnings;
  final int activeDeliveries;
  final int pendingDeliveries;
  final int completedToday;
  final int cancelledToday;
  final double averageRating;
  final int totalDeliveries;

  const DeliveryStats({
    this.todayEarnings = 0,
    this.weeklyEarnings = 0,
    this.monthlyEarnings = 0,
    this.activeDeliveries = 0,
    this.pendingDeliveries = 0,
    this.completedToday = 0,
    this.cancelledToday = 0,
    this.averageRating = 0,
    this.totalDeliveries = 0,
  });

  factory DeliveryStats.fromJson(Map<String, dynamic> json) {
    return DeliveryStats(
      todayEarnings: (json['todayEarnings'] ?? 0).toDouble(),
      weeklyEarnings: (json['weeklyEarnings'] ?? 0).toDouble(),
      monthlyEarnings: (json['monthlyEarnings'] ?? 0).toDouble(),
      activeDeliveries: json['activeDeliveries'] ?? 0,
      pendingDeliveries: json['pendingDeliveries'] ?? 0,
      completedToday: json['completedToday'] ?? 0,
      cancelledToday: json['cancelledToday'] ?? 0,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalDeliveries: json['totalDeliveries'] ?? 0,
    );
  }
}

class DeliveryEarningsSummary {
  final String period;
  final double amount;
  final int deliveries;

  DeliveryEarningsSummary({
    required this.period,
    required this.amount,
    required this.deliveries,
  });

  factory DeliveryEarningsSummary.fromJson(Map<String, dynamic> json) {
    return DeliveryEarningsSummary(
      period: json['period'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      deliveries: json['deliveries'] ?? 0,
    );
  }
}
