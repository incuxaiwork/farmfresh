import { useQuery } from '@tanstack/react-query';
import { Bar, Doughnut } from 'react-chartjs-2';
import 'chart.js/auto';
import {
  Box,
  Card,
  CardContent,
  Grid,
  Typography,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
} from '@mui/material';
import { useTheme } from '@mui/material/styles';
import ShoppingCartIcon from '@mui/icons-material/ShoppingCart';
import CurrencyRupeeIcon from '@mui/icons-material/CurrencyRupee';
import AgricultureIcon from '@mui/icons-material/Agriculture';
import LocalShippingIcon from '@mui/icons-material/LocalShipping';
import PeopleIcon from '@mui/icons-material/People';
import InventoryIcon from '@mui/icons-material/Inventory';
import AssignmentTurnedInIcon from '@mui/icons-material/AssignmentTurnedIn';
import WarningAmberIcon from '@mui/icons-material/WarningAmber';
import ArrowUpwardIcon from '@mui/icons-material/ArrowUpward';
import { adminService } from '../services/admin.service';
import StatsCard from '../components/StatsCard';
import StatusChip from '../components/StatusChip';
import LoadingState from '../components/LoadingState';
import EmptyState from '../components/EmptyState';
import { useAuth } from '../contexts/AuthContext';
import type { DashboardStats } from '../types';

const f = (v: number) => '₹' + v.toLocaleString('en-IN');

const statCardsConfig: {
  title: string;
  dataKey: keyof DashboardStats;
  icon: React.ReactElement;
  color: string;
  bg: string;
  format?: (v: number) => string;
}[] = [
  { title: 'Total Revenue', dataKey: 'totalRevenue', icon: <CurrencyRupeeIcon />, color: '#10B981', bg: '#E8F5E9', format: f },
  { title: "Today's Sales", dataKey: 'todaySales', icon: <ShoppingCartIcon />, color: '#3B82F6', bg: '#E3F2FD', format: f },
  { title: 'Monthly Sales', dataKey: 'monthlySales', icon: <CurrencyRupeeIcon />, color: '#8B5CF6', bg: '#F3E5F5', format: f },
  { title: 'Total Orders', dataKey: 'totalOrders', icon: <ShoppingCartIcon />, color: '#EC4899', bg: '#FCE4EC' },
  { title: 'Active Customers', dataKey: 'activeCustomers', icon: <PeopleIcon />, color: '#06B6D4', bg: '#E0F7FA' },
  { title: 'Active Farmers', dataKey: 'activeFarmers', icon: <AgricultureIcon />, color: '#F59E0B', bg: '#FFF3E0' },
  { title: 'Delivery Partners', dataKey: 'deliveryPartners', icon: <LocalShippingIcon />, color: '#EF4444', bg: '#FFEBEE' },
  { title: 'Pending Crop Approvals', dataKey: 'pendingProductApprovals', icon: <InventoryIcon />, color: '#6366F1', bg: '#E0F2FE' },
  { title: 'Pending Farmer Approvals', dataKey: 'pendingFarmerApprovals', icon: <AssignmentTurnedInIcon />, color: '#14B8A6', bg: '#E0F2F1' },
  { title: 'Low Inventory Alert', dataKey: 'lowInventory', icon: <WarningAmberIcon />, color: '#F97316', bg: '#FFF3E0' },
  { title: 'Active Deliveries', dataKey: 'activeDeliveries', icon: <LocalShippingIcon />, color: '#84CC16', bg: '#F1F8E9' },
];

const DOUGHNUT_COLORS = [
  '#10B981', // Emerald
  '#3B82F6', // Blue
  '#F59E0B', // Amber
  '#EF4444', // Red
  '#8B5CF6', // Purple
  '#EC4899', // Pink
  '#06B6D4', // Cyan
  '#F97316', // Orange
];

export default function DashboardPage() {
  const theme = useTheme();
  const isDark = theme.palette.mode === 'dark';
  const { user } = useAuth();

  const { data: dashboard, isLoading } = useQuery({
    queryKey: ['dashboard'],
    queryFn: adminService.getDashboard,
  });

  if (isLoading) return <LoadingState rows={8} />;

  if (!dashboard) return <EmptyState message="No dashboard data available" />;

  const stats = dashboard.stats;

  // Chart Adaptability Configurations
  const gridColor = isDark ? 'rgba(255, 255, 255, 0.08)' : 'rgba(0, 0, 0, 0.04)';
  const textColor = isDark ? '#94A3B8' : '#64748B';

  const barData = {
    labels: dashboard.monthlyRevenue?.map((m) => m.month) ?? [],
    datasets: [
      {
        label: 'Revenue',
        data: dashboard.monthlyRevenue?.map((m) => m.revenue) ?? [],
        backgroundColor: isDark ? 'rgba(16, 185, 129, 0.75)' : 'rgba(16, 185, 129, 0.85)',
        borderColor: '#10B981',
        borderWidth: 0,
        borderRadius: 8,
        barThickness: 28,
      },
    ],
  };

  const barOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { display: false },
      tooltip: {
        backgroundColor: isDark ? '#1E293B' : '#0F172A',
        titleColor: '#FFF',
        bodyColor: '#FFF',
        borderColor: isDark ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.1)',
        borderWidth: 1,
        borderRadius: 12,
        padding: 12,
      }
    },
    scales: {
      x: {
        grid: { display: false },
        ticks: { color: textColor, font: { family: 'Outfit, sans-serif', weight: 500 } }
      },
      y: {
        grid: { color: gridColor },
        beginAtZero: true,
        ticks: {
          color: textColor,
          font: { family: 'Outfit, sans-serif' },
          callback: (v: any) => '₹' + Number(v).toLocaleString('en-IN')
        }
      },
    },
  };

  const doughnutData = {
    labels: dashboard.ordersByStatus?.map((o) => o.status) ?? [],
    datasets: [
      {
        data: dashboard.ordersByStatus?.map((o) => o.count) ?? [],
        backgroundColor: DOUGHNUT_COLORS.slice(0, dashboard.ordersByStatus?.length ?? 0),
        borderWidth: isDark ? 2 : 0,
        borderColor: isDark ? '#0C0F22' : '#FFF',
        hoverOffset: 4,
      },
    ],
  };

  const doughnutOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { 
        position: 'bottom' as const, 
        labels: { 
          padding: 16, 
          usePointStyle: true,
          color: textColor,
          font: { family: 'Outfit, sans-serif', size: 12, weight: 500 }
        } 
      },
      tooltip: {
        backgroundColor: isDark ? '#1E293B' : '#0F172A',
        borderRadius: 12,
        padding: 12,
      }
    },
    cutout: '70%',
  };

  const renderRankBadge = (rank: number) => {
    const bg = rank === 1 ? '#FEF3C7' : rank === 2 ? '#F1F5F9' : rank === 3 ? '#FFEDD5' : 'transparent';
    const color = rank === 1 ? '#D97706' : rank === 2 ? '#475569' : rank === 3 ? '#EA580C' : 'inherit';
    const label = rank === 1 ? '🥇' : rank === 2 ? '🥈' : rank === 3 ? '🥉' : `#${rank}`;
    
    if (rank <= 3) {
      return (
        <Box sx={{ display: 'inline-flex', alignItems: 'center', justifyContent: 'center', bgcolor: bg, color, px: 1.2, py: 0.6, borderRadius: '8px', fontWeight: 800, fontSize: 12 }}>
          {label}
        </Box>
      );
    }
    return <Typography variant="body2" sx={{ pl: 1, fontWeight: 600, color: 'text.secondary' }}>{rank}</Typography>;
  };

  return (
    <Box className="page-fade-in">
      {/* Welcome Banner Card */}
      <Card
        sx={{
          mb: 4,
          background: isDark
            ? 'linear-gradient(135deg, #047857 0%, #10B981 50%, #06B6D4 100%)'
            : 'linear-gradient(135deg, #065F46 0%, #10B981 60%, #06B6D4 100%)',
          borderRadius: 4,
          color: '#FFFFFF',
          position: 'relative',
          overflow: 'hidden',
          boxShadow: '0 8px 32px rgba(16,185,129,0.15)',
          border: 'none',
          '&:hover': {
            transform: 'none',
            boxShadow: '0 12px 40px rgba(16,185,129,0.25)',
          }
        }}
      >
        <CardContent sx={{ p: { xs: 4, md: 5 }, position: 'relative', zIndex: 2 }}>
          <Box sx={{ maxWidth: { xs: '100%', md: '75%' } }}>
            <Typography variant="h4" fontWeight={800} sx={{ mb: 1, fontFamily: '"Outfit", sans-serif' }}>
              Welcome back, {user?.name || 'Admin'}! 🌱
            </Typography>
            <Typography variant="body1" sx={{ opacity: 0.9, fontWeight: 500, fontSize: 16, lineHeight: 1.5 }}>
              Here is the latest snapshot for FarmFresh today. You currently have <strong>{stats.pendingProductApprovals} products</strong> and <strong>{stats.pendingFarmerApprovals} farmers</strong> pending moderation approval.
            </Typography>
          </Box>
        </CardContent>

        {/* Decorative Sprout Icon Elements */}
        <Box sx={{ position: 'absolute', right: 40, bottom: -20, fontSize: 140, opacity: 0.15, userSelect: 'none', pointerEvents: 'none' }}>
          🌱
        </Box>
        <Box sx={{ position: 'absolute', right: 180, top: -20, fontSize: 80, opacity: 0.1, userSelect: 'none', pointerEvents: 'none' }}>
          🍃
        </Box>
      </Card>

      {/* KPI Cards Grid */}
      <Grid container spacing={3} mb={4}>
        {statCardsConfig.map(({ title, dataKey, icon, color, bg, format }) => (
          <Grid item xs={12} sm={6} md={4} key={dataKey}>
            <StatsCard
              title={title}
              value={format ? format(stats[dataKey]) : stats[dataKey]}
              icon={icon}
              color={color}
              bg={bg}
            />
          </Grid>
        ))}
      </Grid>

      {/* Charts Grid */}
      <Grid container spacing={3} mb={4}>
        <Grid item xs={12} md={7}>
          <Card>
            <CardContent sx={{ p: 3 }}>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
                <Typography variant="h6" fontWeight={700} sx={{ fontFamily: 'Outfit' }}>Monthly Performance</Typography>
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5, color: 'success.main' }}>
                  <ArrowUpwardIcon fontSize="small" />
                  <Typography variant="caption" fontWeight={700}>+12.4% vs last year</Typography>
                </Box>
              </Box>
              <Box sx={{ height: 320 }}>
                {dashboard.monthlyRevenue?.length ? (
                  <Bar data={barData} options={barOptions} />
                ) : (
                  <EmptyState message="No revenue data available" />
                )}
              </Box>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} md={5}>
          <Card>
            <CardContent sx={{ p: 3 }}>
              <Typography variant="h6" fontWeight={700} mb={3} sx={{ fontFamily: 'Outfit' }}>Orders Status Distribution</Typography>
              <Box sx={{ height: 320, position: 'relative', display: 'flex', flexDirection: 'column', justifyContent: 'center' }}>
                {dashboard.ordersByStatus?.length ? (
                  <Box sx={{ height: 240 }}>
                    <Doughnut data={doughnutData} options={doughnutOptions} />
                  </Box>
                ) : (
                  <EmptyState message="No status data available" />
                )}
              </Box>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Top Tables Row */}
      <Grid container spacing={3} mb={4}>
        <Grid item xs={12} md={6}>
          <Typography variant="h6" fontWeight={700} mb={2} sx={{ fontFamily: 'Outfit', display: 'flex', alignItems: 'center', gap: 1 }}>
            🔥 Top Selling Products
          </Typography>
          <TableContainer component={Paper}>
            <Table size="medium">
              <TableHead>
                <TableRow>
                  <TableCell sx={{ width: 80 }}>Rank</TableCell>
                  <TableCell>Product Name</TableCell>
                  <TableCell align="right">Orders</TableCell>
                  <TableCell align="right">Revenue</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {dashboard.topSellingProducts?.length ? (
                  dashboard.topSellingProducts.map((p, i) => (
                    <TableRow key={p.name} hover>
                      <TableCell>{renderRankBadge(i + 1)}</TableCell>
                      <TableCell sx={{ fontWeight: 600 }}>{p.name}</TableCell>
                      <TableCell align="right" sx={{ fontWeight: 500 }}>{p.count}</TableCell>
                      <TableCell align="right" sx={{ fontWeight: 700, color: 'primary.main' }}>{f(p.revenue)}</TableCell>
                    </TableRow>
                  ))
                ) : (
                  <TableRow>
                    <TableCell colSpan={4}><EmptyState message="No products data" /></TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          </TableContainer>
        </Grid>
        <Grid item xs={12} md={6}>
          <Typography variant="h6" fontWeight={700} mb={2} sx={{ fontFamily: 'Outfit', display: 'flex', alignItems: 'center', gap: 1 }}>
            🚜 Top Performing Farmers
          </Typography>
          <TableContainer component={Paper}>
            <Table size="medium">
              <TableHead>
                <TableRow>
                  <TableCell sx={{ width: 80 }}>Rank</TableCell>
                  <TableCell>Farmer Name</TableCell>
                  <TableCell align="right">Orders</TableCell>
                  <TableCell align="right">Revenue</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {dashboard.topFarmers?.length ? (
                  dashboard.topFarmers.map((farmer, i) => (
                    <TableRow key={farmer.name} hover>
                      <TableCell>{renderRankBadge(i + 1)}</TableCell>
                      <TableCell sx={{ fontWeight: 600 }}>{farmer.name}</TableCell>
                      <TableCell align="right" sx={{ fontWeight: 500 }}>{farmer.orders}</TableCell>
                      <TableCell align="right" sx={{ fontWeight: 700, color: 'primary.main' }}>{f(farmer.revenue)}</TableCell>
                    </TableRow>
                  ))
                ) : (
                  <TableRow>
                    <TableCell colSpan={4}><EmptyState message="No farmer data" /></TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          </TableContainer>
        </Grid>
      </Grid>

      {/* Recent Orders Section */}
      <Typography variant="h6" fontWeight={700} mb={2} sx={{ fontFamily: 'Outfit' }}>
        🛍️ Recent Orders Activity
      </Typography>
      <TableContainer component={Paper} sx={{ mb: 4 }}>
        <Table size="medium">
          <TableHead>
            <TableRow>
              <TableCell>Order Number</TableCell>
              <TableCell>Customer Name</TableCell>
              <TableCell>Status</TableCell>
              <TableCell align="right">Total Amount</TableCell>
              <TableCell>Placed Date</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {dashboard.recentOrders?.length ? (
              dashboard.recentOrders.map((order) => (
                <TableRow key={order.id} hover>
                  <TableCell sx={{ fontWeight: 600, color: 'secondary.main' }}>
                    {order.orderNumber ?? order.id.slice(0, 8)}
                  </TableCell>
                  <TableCell sx={{ fontWeight: 500 }}>{order.customerName ?? 'N/A'}</TableCell>
                  <TableCell><StatusChip status={order.status} /></TableCell>
                  <TableCell align="right" sx={{ fontWeight: 700, color: 'text.primary' }}>{f(order.totalAmount)}</TableCell>
                  <TableCell sx={{ color: 'text.secondary', fontSize: 13 }}>
                    {new Date(order.createdAt).toLocaleDateString('en-IN', { 
                      day: '2-digit', 
                      month: 'short', 
                      year: 'numeric',
                      hour: '2-digit',
                      minute: '2-digit'
                    })}
                  </TableCell>
                </TableRow>
              ))
            ) : (
              <TableRow>
                <TableCell colSpan={5}><EmptyState message="No recent orders activity" /></TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </TableContainer>
    </Box>
  );
}
