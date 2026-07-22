export interface User {
  id: string;
  name: string;
  email: string;
  phone?: string;
  role: 'ADMIN' | 'CUSTOMER' | 'FARMER' | 'DELIVERY_PARTNER';
  isActive: boolean;
  createdAt: string;
  updatedAt?: string;
}

export interface AuthResponse {
  user: User;
  accessToken: string;
  refreshToken: string;
}

export interface Product {
  id: string;
  name: string;
  description: string;
  price: number;
  discountPrice?: number;
  category: string;
  categoryId?: string;
  stock: number;
  unit: string;
  farmerId: string;
  farmerName?: string;
  imageUrl?: string;
  images?: ProductImage[];
  status: 'DRAFT' | 'PENDING_APPROVAL' | 'APPROVED' | 'REJECTED' | 'ARCHIVED';
  isFeatured: boolean;
  isActive: boolean;
  rating?: number;
  reviewCount?: number;
  createdAt: string;
  updatedAt?: string;
}

export interface ProductImage {
  id: string;
  url: string;
  isPrimary: boolean;
}

export interface Category {
  id: string;
  name: string;
  slug: string;
  description?: string;
  icon?: string;
  imageUrl?: string;
  parentId?: string;
  parent?: Category;
  children?: Category[];
  displayOrder: number;
  status: 'ACTIVE' | 'INACTIVE' | 'ARCHIVED';
  productCount?: number;
  createdAt: string;
  updatedAt?: string;
}

export interface Order {
  id: string;
  orderNumber?: string;
  customerId: string;
  customerName?: string;
  customer?: User;
  items: OrderItem[];
  subtotal: number;
  deliveryFee: number;
  tax: number;
  discount: number;
  totalAmount: number;
  status: 'PENDING' | 'CONFIRMED' | 'PREPARING' | 'READY_FOR_PICKUP' | 'OUT_FOR_DELIVERY' | 'DELIVERED' | 'CANCELLED';
  paymentStatus: 'PENDING' | 'PAID' | 'FAILED' | 'REFUNDED';
  deliveryAddress?: string;
  deliveryPartnerId?: string;
  deliveryPartnerName?: string;
  specialInstructions?: string;
  createdAt: string;
  updatedAt?: string;
}

export interface OrderItem {
  id: string;
  productId: string;
  productName: string;
  quantity: number;
  unitPrice: number;
  totalPrice: number;
  farmerId?: string;
  farmerName?: string;
  status?: string;
}

export interface Farmer {
  id: string;
  name: string;
  email: string;
  phone: string;
  farmName?: string;
  farmAddress?: string;
  location?: string;
  description?: string;
  productsCount?: number;
  totalOrders?: number;
  totalEarnings?: number;
  rating?: number;
  status: 'PENDING' | 'APPROVED' | 'REJECTED' | 'SUSPENDED';
  kycStatus: 'NOT_SUBMITTED' | 'PENDING' | 'VERIFIED' | 'REJECTED';
  kycDocuments?: string;
  bankAccount?: BankAccount;
  isActive: boolean;
  joinedAt: string;
  updatedAt?: string;
}

export interface BankAccount {
  bankName: string;
  accountNumber: string;
  ifscCode?: string;
  accountHolderName?: string;
}

export interface DeliveryPartner {
  id: string;
  name: string;
  email: string;
  phone: string;
  vehicleType?: string;
  vehicleNumber?: string;
  licenseNumber?: string;
  bankAccount?: {
    bankName?: string;
    accountNumber?: string;
    routingNumber?: string;
    ifscCode?: string;
    accountHolder?: string;
  };
  isAvailable: boolean;
  isActive: boolean;
  status: 'ACTIVE' | 'SUSPENDED' | 'INACTIVE';
  completedDeliveries: number;
  avgRating?: number;
  totalEarnings?: number;
  joinedAt: string;
  createdAt?: string;
  address?: string;
  onTimePercentage?: number;
  averageDeliveryTime?: number;
  totalDistance?: number;
}

export interface Coupon {
  id: string;
  code: string;
  description?: string;
  discountType: 'PERCENTAGE' | 'FLAT';
  discountValue: number;
  minOrderAmount: number;
  maxDiscountAmount?: number;
  maxUses: number;
  usedCount: number;
  isActive: boolean;
  expiresAt: string;
  createdAt: string;
}

export interface Banner {
  id: string;
  title: string;
  subtitle?: string;
  imageUrl: string;
  linkUrl?: string;
  displayOrder: number;
  isActive: boolean;
  startDate?: string;
  endDate?: string;
  createdAt: string;
}

export interface InventoryItem {
  id: string;
  productId: string;
  productName?: string;
  farmerId: string;
  farmerName?: string;
  currentStock: number;
  minStock: number;
  maxStock: number;
  reorderLevel: number;
  unit: string;
  status: 'IN_STOCK' | 'LOW_STOCK' | 'OUT_OF_STOCK' | 'OVERSTOCK';
  lastRestockedAt?: string;
  createdAt: string;
  updatedAt?: string;
}

export interface InventoryHistory {
  id: string;
  inventoryId: string;
  productId: string;
  productName?: string;
  farmerName?: string;
  type: 'ADD' | 'REMOVE' | 'ADJUST' | 'ORDER_PLACED' | 'ORDER_CANCELLED';
  quantity: number;
  previousStock: number;
  newStock: number;
  notes?: string;
  createdAt: string;
}

export interface Notification {
  id: string;
  title: string;
  body: string;
  type: 'ORDER' | 'DELIVERY' | 'PAYMENT' | 'SYSTEM' | 'PROMOTION';
  targetRole?: string;
  targetUserId?: string;
  isRead: boolean;
  createdAt: string;
}

export interface AuditLog {
  id: string;
  userId: string;
  userName?: string;
  action: string;
  entity: string;
  entityId?: string;
  details?: string;
  ipAddress?: string;
  createdAt: string;
}

export interface PlatformSettings {
  commissionRate: number;
  deliveryCharge: number;
  freeDeliveryThreshold: number;
  gstRate: number;
  platformFee: number;
  minOrderAmount: number;
  maxDeliveryDistance: number;
  supportEmail: string;
  supportPhone: string;
  marketplaceName: string;
  marketplaceDescription: string;
}

export interface CmsContent {
  id: string;
  key: string;
  title: string;
  content: string;
  updatedAt: string;
}

export interface DashboardStats {
  totalRevenue: number;
  todaySales: number;
  monthlySales: number;
  totalOrders: number;
  activeCustomers: number;
  activeFarmers: number;
  deliveryPartners: number;
  pendingProductApprovals: number;
  pendingFarmerApprovals: number;
  lowInventory: number;
  activeDeliveries: number;
}

export interface DashboardData {
  stats: DashboardStats;
  topSellingProducts: { name: string; count: number; revenue: number }[];
  topFarmers: { name: string; orders: number; revenue: number }[];
  recentOrders: Order[];
  monthlyRevenue: { month: string; revenue: number }[];
  ordersByStatus: { status: string; count: number }[];
}

export interface PaginatedResponse<T> {
  items: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

export interface ApiError {
  message: string;
  statusCode: number;
  error?: string;
}

export interface Review {
  id: string;
  customerId: string;
  customerName?: string;
  productId: string;
  productName?: string;
  rating: number;
  comment?: string;
  status: 'PENDING' | 'APPROVED' | 'REJECTED' | 'FLAGGED';
  createdAt: string;
}

export interface Payout {
  id: string;
  farmerId: string;
  farmerName?: string;
  amount: number;
  status: 'PENDING' | 'PROCESSING' | 'COMPLETED' | 'FAILED';
  period?: string;
  bankAccount?: string;
  createdAt: string;
  processedAt?: string;
}

export interface OrderIssue {
  id: string;
  orderId: string;
  customerId: string;
  customerName?: string;
  type: string;
  description: string;
  status: 'PENDING' | 'IN_PROGRESS' | 'RESOLVED' | 'CLOSED';
  resolution?: string;
  createdAt: string;
  resolvedAt?: string;
}

export interface ChartDataPoint {
  label: string;
  value: number;
}

export type AdminRole = 'SUPER_ADMIN' | 'ADMIN' | 'MANAGER' | 'SUPPORT_EXECUTIVE' | 'CONTENT_MANAGER';
