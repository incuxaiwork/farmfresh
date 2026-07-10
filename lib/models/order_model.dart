import 'cart_item_model.dart';
import 'product_model.dart';

class OrderModel {
  final String id;
  final DateTime date;
  final List<CartItemModel> items;
  final double total;
  final double deliveryFee;
  final String status; // 'Pending', 'Accepted', 'In Transit', 'Delivered'
  final String otp;

  OrderModel({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.deliveryFee,
    required this.status,
    required this.otp,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      status: json['status'] as String,
      otp: json['otp'] as String,
    );
  }

  factory OrderModel.fromBackendJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      date: DateTime.parse(json['createdAt'] as String),
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => CartItemModel(
                    product: ProductModel.fromBackendJson(item['product']),
                    quantity: item['quantity'] as int,
                  ))
              .toList()
          : [],
      total: (json['total'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      status: json['status'] as String,
      otp: json['otpCode'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'deliveryFee': deliveryFee,
      'status': status,
      'otp': otp,
    };
  }

  OrderModel copyWith({
    String? id,
    DateTime? date,
    List<CartItemModel>? items,
    double? total,
    double? deliveryFee,
    String? status,
    String? otp,
  }) {
    return OrderModel(
      id: id ?? this.id,
      date: date ?? this.date,
      items: items ?? this.items,
      total: total ?? this.total,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      status: status ?? this.status,
      otp: otp ?? this.otp,
    );
  }
}
