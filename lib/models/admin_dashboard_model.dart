class AdminDashboardModel {
  final Map<String, dynamic> stats;
  final List<dynamic> recentOrders;
  final List<dynamic> topSellingProducts;
  final List<dynamic> topFarmers;
  final List<dynamic> monthlyRevenue;
  final Map<String, dynamic> ordersByStatus;

  AdminDashboardModel({
    this.stats = const {},
    this.recentOrders = const [],
    this.topSellingProducts = const [],
    this.topFarmers = const [],
    this.monthlyRevenue = const [],
    this.ordersByStatus = const {},
  });

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) {
    return AdminDashboardModel(
      stats: json['stats'] as Map<String, dynamic>? ?? const {},
      recentOrders: json['recentOrders'] as List<dynamic>? ?? const [],
      topSellingProducts: json['topSellingProducts'] as List<dynamic>? ?? const [],
      topFarmers: json['topFarmers'] as List<dynamic>? ?? const [],
      monthlyRevenue: json['monthlyRevenue'] as List<dynamic>? ?? const [],
      ordersByStatus: json['ordersByStatus'] as Map<String, dynamic>? ?? const {},
    );
  }
}
