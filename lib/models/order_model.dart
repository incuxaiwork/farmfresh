import 'cart_item_model.dart';
import 'product_model.dart';

class OrderModel {
  final String id;
  final String orderNumber;
  final DateTime date;
  final List<CartItemModel> items;
  final double total;
  final double deliveryFee;
  final double subtotal;
  final double discount;
  final String status;
  final String? paymentStatus;
  final String? address;
  final String? notes;
  final String? otpCode;

  OrderModel({
    required this.id,
    this.orderNumber = '',
    required this.date,
    required this.items,
    required this.total,
    this.deliveryFee = 0,
    this.subtotal = 0,
    this.discount = 0,
    required this.status,
    this.paymentStatus,
    this.address,
    this.notes,
    this.otpCode,
  });

  static double _toDouble(dynamic v, [double fallback = 0]) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: _toDouble(json['total']),
      deliveryFee: _toDouble(json['deliveryFee']),
      subtotal: _toDouble(json['subtotal']),
      discount: _toDouble(json['discount']),
      status: json['status'] as String,
      paymentStatus: json['paymentStatus'] as String?,
      address: json['address'] as String?,
      notes: json['notes'] as String?,
      otpCode: json['otpCode'] as String?,
    );
  }

  factory OrderModel.fromBackendJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String? ?? '',
      date: DateTime.parse(json['createdAt'] as String),
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) {
                final productJson = item['product'] as Map<String, dynamic>?;
                return CartItemModel(
                  product: productJson != null
                      ? ProductModel.fromBackendJson(productJson)
                      : ProductModel.fallback(
                          id: item['productId'] as String? ?? '',
                        ),
                  quantity: item['quantity'] as int,
                  unitPrice: _toDouble(item['price']),
                  totalPrice: _toDouble(item['total']),
                );
              })
              .toList()
          : [],
      total: _toDouble(json['total']),
      deliveryFee: _toDouble(json['deliveryFee']),
      subtotal: _toDouble(json['subtotal']),
      discount: _toDouble(json['discount']),
      status: json['status'] as String,
      paymentStatus: json['paymentStatus'] as String?,
      address: json['address'] as String?,
      notes: json['notes'] as String?,
      otpCode: json['otpCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'date': date.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'deliveryFee': deliveryFee,
      'subtotal': subtotal,
      'discount': discount,
      'status': status,
      if (paymentStatus != null) 'paymentStatus': paymentStatus,
      if (address != null) 'address': address,
      if (notes != null) 'notes': notes,
      if (otpCode != null) 'otpCode': otpCode,
    };
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    DateTime? date,
    List<CartItemModel>? items,
    double? total,
    double? deliveryFee,
    double? subtotal,
    double? discount,
    String? status,
    String? paymentStatus,
    String? address,
    String? notes,
    String? otpCode,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      date: date ?? this.date,
      items: items ?? this.items,
      total: total ?? this.total,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      otpCode: otpCode ?? this.otpCode,
    );
  }
}
