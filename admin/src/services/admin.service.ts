import api from './api';
import type {
  DashboardData, PaginatedResponse, Product, Category, Order,
  Farmer, DeliveryPartner, Coupon, Banner, InventoryItem,
  InventoryHistory, Notification, AuditLog, PlatformSettings,
  CmsContent, User, Review, Payout, OrderIssue,
} from '../types';

const extract = <T>(res: any): T => res.data?.data ?? res.data;

export const adminService = {
  getDashboard: () => api.get('/admin/dashboard').then(r => extract<DashboardData>(r)),
  getStatistics: () => api.get('/admin/statistics').then(r => extract<any>(r)),

  getCustomers: (params?: Record<string, any>) =>
    api.get('/admin/customers', { params }).then(r => extract<PaginatedResponse<User>>(r)),
  getCustomer: (id: string) => api.get(`/admin/customers/${id}`).then(r => extract<User>(r)),
  updateCustomer: (id: string, data: Partial<User>) =>
    api.patch(`/admin/customers/${id}`, data).then(r => extract<User>(r)),

  getFarmers: (params?: Record<string, any>) =>
    api.get('/admin/farmers', { params }).then(r => extract<PaginatedResponse<Farmer>>(r)),
  getFarmer: (id: string) => api.get(`/admin/farmers/${id}`).then(r => extract<Farmer>(r)),
  approveFarmer: (id: string) => api.patch(`/admin/farmers/${id}/approve`).then(r => extract<Farmer>(r)),
  rejectFarmer: (id: string, reason?: string) =>
    api.patch(`/admin/farmers/${id}/reject`, { reason }).then(r => extract<Farmer>(r)),
  suspendFarmer: (id: string, reason?: string) =>
    api.patch(`/admin/farmers/${id}/suspend`, { reason }).then(r => extract<Farmer>(r)),

  getDeliveryPartners: (params?: Record<string, any>) =>
    api.get('/admin/delivery-partners', { params }).then(r => extract<PaginatedResponse<DeliveryPartner>>(r)),
  updateDeliveryPartner: (id: string, data: Partial<DeliveryPartner>) =>
    api.patch(`/admin/delivery-partners/${id}`, data).then(r => extract<DeliveryPartner>(r)),

  getProducts: (params?: Record<string, any>) =>
    api.get('/admin/products', { params }).then(r => extract<PaginatedResponse<Product>>(r)),
  createProduct: (data: Partial<Product> & { farmerId: string }) =>
    api.post('/admin/products', data).then(r => extract<Product>(r)),
  updateProduct: (id: string, data: Partial<Product>) =>
    api.patch(`/products/${id}`, data).then(r => extract<Product>(r)),
  updateProductStatus: (id: string, status: string) =>
    api.patch(`/products/${id}/status`, { status }).then(r => extract<Product>(r)),
  deleteProduct: (id: string) => api.delete(`/products/${id}`),

  getCategories: (params?: Record<string, any>) =>
    api.get('/categories', { params }).then(r => extract<PaginatedResponse<Category>>(r)),
  getCategoryTree: () => api.get('/categories/tree').then(r => extract<Category[]>(r)),
  createCategory: (data: Partial<Category>) =>
    api.post('/categories', data).then(r => extract<Category>(r)),
  updateCategory: (id: string, data: Partial<Category>) =>
    api.patch(`/categories/${id}`, data).then(r => extract<Category>(r)),
  deleteCategory: (id: string) => api.delete(`/categories/${id}`),
  updateCategoryStatus: (id: string, status: string) =>
    api.patch(`/categories/${id}/status`, { status }).then(r => extract<Category>(r)),

  getInventory: (params?: Record<string, any>) =>
    api.get('/inventory', { params }).then(r => extract<PaginatedResponse<InventoryItem>>(r)),
  getLowStock: () => api.get('/inventory/low-stock').then(r => extract<InventoryItem[]>(r)),
  getInventoryHistory: (params?: Record<string, any>) =>
    api.get('/inventory/history', { params }).then(r => extract<PaginatedResponse<InventoryHistory>>(r)),
  updateInventory: (id: string, data: Partial<InventoryItem>) =>
    api.patch(`/inventory/${id}`, data).then(r => extract<InventoryItem>(r)),
  adjustStock: (id: string, quantity: number) =>
    api.patch(`/inventory/${id}/adjust`, { quantity }).then(r => extract<InventoryItem>(r)),

  getOrders: (params?: Record<string, any>) =>
    api.get('/admin/orders', { params }).then(r => extract<PaginatedResponse<Order>>(r)),
  getOrder: (id: string) => api.get(`/orders/${id}`).then(r => extract<Order>(r)),
  updateOrderStatus: (id: string, status: string) =>
    api.patch(`/orders/${id}/status`, { status }).then(r => extract<Order>(r)),
  cancelOrder: (id: string, reason?: string) =>
    api.patch(`/orders/${id}/cancel`, { reason }).then(r => extract<Order>(r)),

  getDeliveries: (params?: Record<string, any>) =>
    api.get('/admin/deliveries', { params }).then(r => extract<any>(r)),
  assignDelivery: (orderId: string, driverId: string) =>
    api.post('/delivery/assign', { orderId, driverId }).then(r => extract<any>(r)),

  getCoupons: (params?: Record<string, any>) =>
    api.get('/admin/coupons', { params }).then(r => extract<PaginatedResponse<Coupon>>(r)),
  createCoupon: (data: Partial<Coupon>) =>
    api.post('/admin/coupons', data).then(r => extract<Coupon>(r)),
  updateCoupon: (id: string, data: Partial<Coupon>) =>
    api.patch(`/admin/coupons/${id}`, data).then(r => extract<Coupon>(r)),
  deleteCoupon: (id: string) => api.delete(`/admin/coupons/${id}`),

  getBanners: (params?: Record<string, any>) =>
    api.get('/admin/banners', { params }).then(r => extract<PaginatedResponse<Banner>>(r)),
  createBanner: (data: Partial<Banner>) =>
    api.post('/admin/banners', data).then(r => extract<Banner>(r)),
  updateBanner: (id: string, data: Partial<Banner>) =>
    api.patch(`/admin/banners/${id}`, data).then(r => extract<Banner>(r)),
  deleteBanner: (id: string) => api.delete(`/admin/banners/${id}`),

  getNotifications: (params?: Record<string, any>) =>
    api.get('/admin/notifications', { params }).then(r => extract<PaginatedResponse<Notification>>(r)),
  sendNotification: (data: { title: string; body: string; targetRole?: string; targetUserId?: string }) =>
    api.post('/admin/notifications/send', data).then(r => extract<Notification>(r)),

  getSettings: () => api.get('/admin/settings').then(r => extract<PlatformSettings>(r)),
  updateSettings: (data: Partial<PlatformSettings>) =>
    api.patch('/admin/settings', data).then(r => extract<PlatformSettings>(r)),

  getAuditLogs: (params?: Record<string, any>) =>
    api.get('/admin/audit-logs', { params }).then(r => extract<PaginatedResponse<AuditLog>>(r)),

  getCmsContent: () => api.get('/admin/cms').then(r => extract<CmsContent[]>(r)),
  updateCmsContent: (key: string, data: { title: string; content: string }) =>
    api.patch(`/admin/cms/${key}`, data).then(r => extract<CmsContent>(r)),

  getReviews: (params?: Record<string, any>) =>
    api.get('/admin/reviews', { params }).then(r => extract<PaginatedResponse<Review>>(r)),
  moderateReview: (id: string, action: 'approve' | 'reject' | 'flag') =>
    api.patch(`/admin/reviews/${id}/moderate`, { action }).then(r => extract<Review>(r)),

  getPayouts: (params?: Record<string, any>) =>
    api.get('/admin/payouts', { params }).then(r => extract<PaginatedResponse<Payout>>(r)),
  processPayout: (id: string) =>
    api.patch(`/admin/payouts/${id}/process`).then(r => extract<Payout>(r)),

  getOrderIssues: (params?: Record<string, any>) =>
    api.get('/admin/order-issues', { params }).then(r => extract<PaginatedResponse<OrderIssue>>(r)),
  resolveIssue: (id: string, resolution: string) =>
    api.patch(`/admin/order-issues/${id}/resolve`, { resolution }).then(r => extract<OrderIssue>(r)),
};
