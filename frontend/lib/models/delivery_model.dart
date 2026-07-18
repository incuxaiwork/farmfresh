import 'package:ecommerce_app/models/address_model.dart';

enum DeliveryOrderStatus {
  pending('PENDING'),
  accepted('ACCEPTED'),
  headingToPickup('HEADING_TO_PICKUP'),
  pickedUp('PICKED_UP'),
  outForDelivery('OUT_FOR_DELIVERY'),
  delivered('DELIVERED'),
  cancelled('CANCELLED'),
  rejected('REJECTED');

  final String apiValue;
  const DeliveryOrderStatus(this.apiValue);

  factory DeliveryOrderStatus.fromApiValue(String value) {
    return DeliveryOrderStatus.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => DeliveryOrderStatus.pending,
    );
  }
}

class DeliveryOrder {
  final String id;
  final String orderId;
  final String? orderNumber;
  final String? farmerId;
  final String? customerId;
  final DeliveryOrderStatus status;
  final String? orderStatus;
  final double? total;
  final String? assignedAt;
  final String? acceptedAt;
  final String? pickedUpAt;
  final String? deliveredAt;
  final String? estimatedDeliveryTime;
  final double? distance;
  final double? deliveryFee;
  final String? specialInstructions;
  final String? cancellationReason;
  final AddressModel? pickupAddress;
  final AddressModel? deliveryAddress;
  final DeliveryCustomerInfo? customer;
  final DeliveryFarmerInfo? farmer;
  final List<DeliveryItem>? items;
  final DeliveryOrderSummary? orderSummary;
  final double? rating;
  final String? feedback;
  final double? farmerLatitude;
  final double? farmerLongitude;
  final double? customerLatitude;
  final double? customerLongitude;

  DeliveryOrder({
    required this.id,
    required this.orderId,
    this.orderNumber,
    this.farmerId,
    this.customerId,
    required this.status,
    this.orderStatus,
    this.total,
    this.assignedAt,
    this.acceptedAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.estimatedDeliveryTime,
    this.distance,
    this.deliveryFee,
    this.specialInstructions,
    this.cancellationReason,
    this.pickupAddress,
    this.deliveryAddress,
    this.customer,
    this.farmer,
    this.items,
    this.orderSummary,
    this.rating,
    this.feedback,
    this.farmerLatitude,
    this.farmerLongitude,
    this.customerLatitude,
    this.customerLongitude,
  });

  factory DeliveryOrder.fromJson(Map<String, dynamic> json) {
    return DeliveryOrder(
      id: json['id'] ?? '',
      orderId: json['orderId'] ?? json['order_id'] ?? '',
      orderNumber: json['orderNumber'] ?? json['order_number'] ?? json['order']?['orderNumber'] ?? json['order']?['order_number'],
      farmerId: json['farmerId'] ?? json['farmer_id'],
      customerId: json['customerId'] ?? json['customer_id'],
      status: DeliveryOrderStatus.fromApiValue(json['status'] ?? 'PENDING'),
      orderStatus: json['orderStatus'] ?? json['order_status'] ?? json['order']?['status'],
      total: _parseDouble(json['total'] ?? json['order']?['total']),
      assignedAt: json['assignedAt'] ?? json['assigned_at'],
      acceptedAt: json['acceptedAt'] ?? json['accepted_at'],
      pickedUpAt: json['pickedUpAt'] ?? json['picked_up_at'],
      deliveredAt: json['deliveredAt'] ?? json['delivered_at'],
      estimatedDeliveryTime:
          json['estimatedDeliveryTime'] ?? json['estimated_delivery_time'],
      distance: _parseDouble(json['distance']),
      deliveryFee: _parseDouble(json['deliveryFee'] ?? json['deliveryCharge']),
      specialInstructions: json['specialInstructions'],
      cancellationReason: json['cancellationReason'],
      pickupAddress: json['pickupAddress'] != null
          ? AddressModel.fromJson(json['pickupAddress'])
          : null,
      deliveryAddress: json['deliveryAddress'] != null
          ? AddressModel.fromJson(json['deliveryAddress'])
          : null,
      customer: json['customer'] != null
          ? DeliveryCustomerInfo.fromJson(json['customer'])
          : null,
      farmer: json['farmer'] != null
          ? DeliveryFarmerInfo.fromJson(json['farmer'])
          : null,
      items: (json['items'] as List?)
          ?.map((e) => DeliveryItem.fromJson(e))
          .toList(),
      orderSummary: json['orderSummary'] != null
          ? DeliveryOrderSummary.fromJson(json['orderSummary'])
          : null,
      rating: _parseDouble(json['rating']),
      feedback: json['feedback'],
      farmerLatitude: _parseDouble(json['farmerLatitude'] ?? json['farmer_latitude']),
      farmerLongitude: _parseDouble(json['farmerLongitude'] ?? json['farmer_longitude']),
      customerLatitude: _parseDouble(json['customerLatitude'] ?? json['customer_latitude']),
      customerLongitude: _parseDouble(json['customerLongitude'] ?? json['customer_longitude']),
    );
  }

  DeliveryOrder copyWith({
    DeliveryOrderStatus? status,
    String? orderStatus,
    String? acceptedAt,
    String? pickedUpAt,
    String? deliveredAt,
    double? rating,
    String? feedback,
    double? farmerLatitude,
    double? farmerLongitude,
    double? customerLatitude,
    double? customerLongitude,
  }) {
    return DeliveryOrder(
      id: id,
      orderId: orderId,
      farmerId: farmerId,
      customerId: customerId,
      status: status ?? this.status,
      orderStatus: orderStatus ?? this.orderStatus,
      assignedAt: assignedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      estimatedDeliveryTime: estimatedDeliveryTime,
      distance: distance,
      deliveryFee: deliveryFee,
      specialInstructions: specialInstructions,
      cancellationReason: cancellationReason,
      pickupAddress: pickupAddress,
      deliveryAddress: deliveryAddress,
      customer: customer,
      farmer: farmer,
      items: items,
      orderSummary: orderSummary,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
      farmerLatitude: farmerLatitude ?? this.farmerLatitude,
      farmerLongitude: farmerLongitude ?? this.farmerLongitude,
      customerLatitude: customerLatitude ?? this.customerLatitude,
      customerLongitude: customerLongitude ?? this.customerLongitude,
    );
  }
}

class DeliveryCustomerInfo {
  final String id;
  final String name;
  final String phone;
  final String? email;

  DeliveryCustomerInfo({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
  });

  factory DeliveryCustomerInfo.fromJson(Map<String, dynamic> json) {
    return DeliveryCustomerInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
    );
  }
}

class DeliveryFarmerInfo {
  final String id;
  final String name;
  final String phone;
  final String? farmName;

  DeliveryFarmerInfo({
    required this.id,
    required this.name,
    required this.phone,
    this.farmName,
  });

  factory DeliveryFarmerInfo.fromJson(Map<String, dynamic> json) {
    return DeliveryFarmerInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      farmName: json['farmName'],
    );
  }
}

class DeliveryItem {
  final String id;
  final String name;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? imageUrl;

  DeliveryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.imageUrl,
  });

  factory DeliveryItem.fromJson(Map<String, dynamic> json) {
    return DeliveryItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: _parseDouble(json['unitPrice']) ?? 0.0,
      totalPrice: _parseDouble(json['totalPrice']) ?? 0.0,
      imageUrl: json['imageUrl'],
    );
  }
}

class DeliveryOrderSummary {
  final double subtotal;
  final double deliveryFee;
  final double total;

  DeliveryOrderSummary({
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });

  factory DeliveryOrderSummary.fromJson(Map<String, dynamic> json) {
    return DeliveryOrderSummary(
      subtotal: _parseDouble(json['subtotal']) ?? 0.0,
      deliveryFee: _parseDouble(json['deliveryFee']) ?? 0.0,
      total: _parseDouble(json['total']) ?? 0.0,
    );
  }
}

double? _parseDouble(dynamic val) {
  if (val == null) return null;
  if (val is num) return val.toDouble();
  if (val is String) return double.tryParse(val);
  return null;
}

class DeliveryHistory {
  final List<DeliveryOrder> orders;
  final int total;
  final int page;
  final int limit;

  DeliveryHistory({
    required this.orders,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory DeliveryHistory.fromJson(Map<String, dynamic> json) {
    return DeliveryHistory(
      orders: (json['orders'] as List?)
              ?.map((e) => DeliveryOrder.fromJson(e))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
    );
  }
}
