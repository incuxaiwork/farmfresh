import { useLocation, useNavigate } from 'react-router-dom';
import { Box, List, ListItemButton, ListItemIcon, ListItemText, Typography, Divider } from '@mui/material';
import DashboardIcon from '@mui/icons-material/Dashboard';
import InventoryIcon from '@mui/icons-material/Inventory';
import ShoppingCartIcon from '@mui/icons-material/ShoppingCart';
import AgricultureIcon from '@mui/icons-material/Agriculture';
import LocalShippingIcon from '@mui/icons-material/LocalShipping';
import DiscountIcon from '@mui/icons-material/Discount';
import CategoryIcon from '@mui/icons-material/Category';
import WarningAmberIcon from '@mui/icons-material/WarningAmber';
import PaymentsIcon from '@mui/icons-material/Payments';
import BarChartIcon from '@mui/icons-material/BarChart';
import StarIcon from '@mui/icons-material/Star';
import ReportProblemIcon from '@mui/icons-material/ReportProblem';
import SettingsIcon from '@mui/icons-material/Settings';
import CampaignIcon from '@mui/icons-material/Campaign';
import ImageIcon from '@mui/icons-material/Image';
import ArticleIcon from '@mui/icons-material/Article';
import HistoryIcon from '@mui/icons-material/History';

const SIDEBAR_WIDTH = 260;

const navSections = [
  {
    title: 'Overview',
    items: [
      { label: 'Dashboard', icon: <DashboardIcon />, path: '/' },
      { label: 'Analytics', icon: <BarChartIcon />, path: '/analytics' },
    ],
  },
  {
    title: 'Management',
    items: [
      { label: 'Products', icon: <InventoryIcon />, path: '/products' },
      { label: 'Categories', icon: <CategoryIcon />, path: '/categories' },
      { label: 'Orders', icon: <ShoppingCartIcon />, path: '/orders' },
      { label: 'Inventory Alerts', icon: <WarningAmberIcon />, path: '/inventory-alerts' },
    ],
  },
  {
    title: 'Partners',
    items: [
      { label: 'Farmers', icon: <AgricultureIcon />, path: '/farmers' },
      { label: 'Delivery Partners', icon: <LocalShippingIcon />, path: '/delivery-partners' },
      { label: 'Payouts', icon: <PaymentsIcon />, path: '/payouts' },
    ],
  },
  {
    title: 'Commerce',
    items: [
      { label: 'Coupons', icon: <DiscountIcon />, path: '/coupons' },
      { label: 'Banners', icon: <ImageIcon />, path: '/banners' },
      { label: 'Reviews', icon: <StarIcon />, path: '/reviews' },
    ],
  },
  {
    title: 'Support',
    items: [
      { label: 'Order Issues', icon: <ReportProblemIcon />, path: '/order-issues' },
      { label: 'Notifications', icon: <CampaignIcon />, path: '/notifications' },
    ],
  },
  {
    title: 'System',
    items: [
      { label: 'Audit Logs', icon: <HistoryIcon />, path: '/audit-logs' },
      { label: 'CMS', icon: <ArticleIcon />, path: '/cms' },
      { label: 'Settings', icon: <SettingsIcon />, path: '/settings' },
    ],
  },
];

export { SIDEBAR_WIDTH };

export default function Sidebar() {
  const { pathname } = useLocation();
  const navigate = useNavigate();

  return (
    <Box
      sx={{
        width: SIDEBAR_WIDTH,
        height: '100vh',
        position: 'fixed',
        top: 0,
        left: 0,
        background: 'linear-gradient(180deg, #044E31 0%, #076C63 45%, #0B1D35 100%)',
        color: '#FFFFFF',
        display: 'flex',
        flexDirection: 'column',
        zIndex: (theme) => theme.zIndex.drawer + 1,
        borderRight: '1px solid rgba(255,255,255,0.06)',
        boxShadow: '4px 0 25px rgba(0,0,0,0.2)',
      }}
    >
      {/* Brand Header */}
      <Box sx={{ px: 3, py: 3.5, borderBottom: '1px solid rgba(255,255,255,0.08)', position: 'relative', overflow: 'hidden' }}>
        <Box
          sx={{
            position: 'absolute',
            top: -20,
            right: -20,
            width: 80,
            height: 80,
            borderRadius: '50%',
            background: 'rgba(52, 211, 153, 0.12)',
            filter: 'blur(15px)',
            pointerEvents: 'none'
          }}
        />
        <Typography 
          variant="h6" 
          fontWeight={800} 
          letterSpacing={0.5} 
          sx={{ 
            fontSize: 21, 
            fontFamily: '"Outfit", sans-serif',
            background: 'linear-gradient(90deg, #FFFFFF 0%, #A7F3D0 100%)',
            WebkitBackgroundClip: 'text',
            WebkitTextFillColor: 'transparent',
          }}
        >
          FarmFresh
        </Typography>
        <Typography variant="caption" sx={{ color: 'rgba(255,255,255,0.5)', mt: 0.25, display: 'block', fontWeight: 600, letterSpacing: '0.05em', textTransform: 'uppercase', fontSize: 10 }}>
          Admin Dashboard
        </Typography>
      </Box>

      {/* Nav List */}
      <List 
        sx={{ 
          flex: 1, 
          px: 1.5, 
          pt: 2.5, 
          pb: 2.5, 
          overflowY: 'auto', 
          '&::-webkit-scrollbar': { width: 4 }, 
          '&::-webkit-scrollbar-track': { background: 'transparent' }, 
          '&::-webkit-scrollbar-thumb': { background: 'rgba(255,255,255,0.15)', borderRadius: 2 }, 
          scrollbarWidth: 'thin', 
          scrollbarColor: 'rgba(255,255,255,0.15) transparent' 
        }}
      >
        {navSections.map((section, sIdx) => (
          <Box key={section.title} sx={{ mb: 2 }}>
            {sIdx > 0 && <Divider sx={{ borderColor: 'rgba(255,255,255,0.06)', my: 1.5, mx: 1 }} />}
            <Typography 
              variant="caption" 
              sx={{ 
                color: 'rgba(255,255,255,0.4)', 
                px: 2, 
                py: 0.75, 
                display: 'block', 
                fontWeight: 700, 
                letterSpacing: '0.08em', 
                textTransform: 'uppercase', 
                fontSize: 10 
              }}
            >
              {section.title}
            </Typography>
            {section.items.map(({ label, icon, path }) => {
              const active = pathname === path;
              return (
                <ListItemButton
                  key={path} 
                  onClick={() => navigate(path)}
                  sx={{ 
                    borderRadius: '12px', 
                    mb: 0.5, 
                    py: 1.2, 
                    px: 2,
                    color: active ? '#FFFFFF' : 'rgba(255,255,255,0.8)', 
                    bgcolor: active ? 'rgba(255,255,255,0.12)' : 'transparent', 
                    backdropFilter: active ? 'blur(10px)' : 'none',
                    border: active ? '1px solid rgba(255,255,255,0.15)' : '1px solid transparent',
                    boxShadow: active ? '0 4px 12px rgba(0,0,0,0.1)' : 'none',
                    transition: 'all 0.25s cubic-bezier(0.4, 0, 0.2, 1)', 
                    position: 'relative', 
                    '&:hover': { 
                      bgcolor: active ? 'rgba(255,255,255,0.16)' : 'rgba(255,255,255,0.06)',
                      transform: 'translateX(4px)',
                      color: '#FFFFFF',
                      '& .MuiListItemIcon-root': {
                        color: active ? '#34D399' : '#A7F3D0',
                      }
                    } 
                  }}
                >
                  <ListItemIcon 
                    sx={{ 
                      color: active ? '#34D399' : 'rgba(255,255,255,0.55)', 
                      minWidth: 36, 
                      transition: 'color 0.25s ease', 
                      '& .MuiSvgIcon-root': { fontSize: 18 } 
                    }}
                  >
                    {icon}
                  </ListItemIcon>
                  <ListItemText 
                    primary={label} 
                    primaryTypographyProps={{ 
                      fontSize: 13, 
                      fontWeight: active ? 700 : 500,
                      fontFamily: '"Outfit", sans-serif',
                      letterSpacing: '0.01em',
                    }} 
                  />
                  {active && (
                    <Box 
                      sx={{ 
                        width: 4, 
                        height: 18, 
                        borderRadius: '4px', 
                        bgcolor: '#34D399', 
                        position: 'absolute', 
                        right: 8,
                        boxShadow: '0 0 8px #34D399'
                      }} 
                    />
                  )}
                </ListItemButton>
              );
            })}
          </Box>
        ))}
      </List>
    </Box>
  );
}
