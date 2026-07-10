import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../models/cart_item_model.dart';

class MockDb {
  static UserModel? currentUser = UserModel(
    id: 'user-customer',
    name: 'Jane Doe',
    email: 'customer@farmfresh.com',
    role: 'Customer',
  );

  static final List<ProductModel> products = [
    ProductModel(
      id: 'prod-1',
      name: 'Organic Red Tomatoes',
      price: 2.50,
      originalPrice: 4.00,
      discount: '37% OFF',
      origin: 'Santorini Farms',
      category: 'Vegetables',
      image: 'assets/cherry_tomatoes.jpg',
      description: 'Fresh organic red tomatoes grown locally without artificial chemicals or pesticides. Hand-picked straight from Santorini Farms fields to ensure maximum freshness.',
      calories: '18 kcal',
      protein: '0.9g',
      fat: '0.2g',
      weight: '1 kg',
      stock: 12.0,
      farmName: 'Santorini Farms',
    ),
    ProductModel(
      id: 'prod-2',
      name: 'Fresh Spinach Bundle',
      price: 1.20,
      originalPrice: 1.80,
      discount: '33% OFF',
      origin: 'Green Valley Farms',
      category: 'Vegetables',
      image: 'assets/baby_spinach.jpg',
      description: 'Pre-washed tender green spinach leaves. Extremely rich in iron and dietary fiber, perfect for salads, smoothies, or local curries.',
      calories: '23 kcal',
      protein: '2.9g',
      fat: '0.4g',
      weight: '1 bundle',
      stock: 25.0,
      farmName: 'Green Valley Farms',
    ),
    ProductModel(
      id: 'prod-3',
      name: 'Red Gala Apples',
      price: 4.50,
      originalPrice: 5.50,
      discount: '18% OFF',
      origin: 'Hilltop Orchards',
      category: 'Fruits',
      image: 'assets/crisp_red_apples.jpg',
      description: 'Sweet and crunchy Gala apples harvested in the early morning. Perfect for pies, snack boxes, or freshly squeezed apple juice.',
      calories: '52 kcal',
      protein: '0.3g',
      fat: '0.2g',
      weight: '1 kg',
      stock: 50.0,
      farmName: 'Hilltop Orchards',
    ),
    ProductModel(
      id: 'prod-4',
      name: 'Farm Fresh Eggs',
      price: 3.50,
      originalPrice: 3.50,
      discount: null,
      origin: 'Sunny Poultry',
      category: 'Dairy',
      image: 'assets/fresh_farm_eggs.jpg',
      description: 'One dozen premium brown eggs from free-range cage-free hens. Hand-selected for quality and fresh yolk richness.',
      calories: '70 kcal',
      protein: '6.0g',
      fat: '5.0g',
      weight: '1 dozen',
      stock: 15.0,
      farmName: 'Sunny Poultry',
    ),
    ProductModel(
      id: 'prod-5',
      name: 'Sweet Avocados',
      price: 5.49,
      originalPrice: 6.99,
      discount: '21% OFF',
      origin: 'Valley Orchards',
      category: 'Fruits',
      image: 'assets/hass_avocados.jpg',
      description: 'Rich, buttery avocados loaded with healthy fats. Ideal for guacamole or delicious breakfast sourdough toast.',
      calories: '160 kcal',
      protein: '2.0g',
      fat: '15.0g',
      weight: '0.5 kg',
      stock: 10.0,
      farmName: 'Valley Orchards',
    ),
  ];

  static final List<CartItemModel> cartItems = [
    CartItemModel(product: products[0], quantity: 2),
    CartItemModel(product: products[1], quantity: 1),
  ];

  static final List<OrderModel> orders = [
    OrderModel(
      id: '1004',
      date: DateTime.now().subtract(const Duration(days: 2)),
      items: [
        CartItemModel(product: products[0], quantity: 2),
        CartItemModel(product: products[1], quantity: 1),
      ],
      total: 6.20,
      deliveryFee: 2.00,
      status: 'In Transit',
      otp: '4829',
    ),
    OrderModel(
      id: '0988',
      date: DateTime.now().subtract(const Duration(days: 5)),
      items: [
        CartItemModel(product: products[3], quantity: 1),
      ],
      total: 3.50,
      deliveryFee: 2.00,
      status: 'Delivered',
      otp: '1730',
    ),
  ];

  static final List<UserModel> users = [
    UserModel(id: 'user-customer', name: 'Jane Doe', email: 'customer@farmfresh.com', role: 'Customer'),
    UserModel(id: 'user-farmer', name: 'John Farmer', email: 'farmer@farmfresh.com', role: 'Farmer'),
  ];
}
