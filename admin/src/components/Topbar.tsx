import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { AppBar, Toolbar, Typography, Box, IconButton, Avatar, Menu, MenuItem, ListItemIcon, ListItemText, Dialog, DialogTitle, DialogContent, DialogActions, Button, Grid, Tooltip } from '@mui/material';
import PersonIcon from '@mui/icons-material/Person';
import LogoutIcon from '@mui/icons-material/Logout';
import PhotoCameraIcon from '@mui/icons-material/PhotoCamera';
import LightModeIcon from '@mui/icons-material/LightMode';
import DarkModeIcon from '@mui/icons-material/DarkMode';
import DesktopWindowsIcon from '@mui/icons-material/DesktopWindows';
import CalendarTodayIcon from '@mui/icons-material/CalendarToday';
import { SIDEBAR_WIDTH } from './Sidebar';
import { useAuth } from '../contexts/AuthContext';
import { useThemeContext } from '../contexts/ThemeContext';

const DEFAULT_AVATARS = [
  '🍎', '🍏', '🍊', '🍋', '🍌', '🍉', '🍓', '🍒', '🥭', '🍍',
  '🍇', '🍅', '🥑', '🥕', '🌽', '🥦', '🥬', '🥔', '🧅', '🍄'
];

const isEmoji = (str: string) => {
  return str.length <= 4 && !str.startsWith('http') && !str.startsWith('data') && !str.startsWith('/');
};

export default function Topbar() {
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
  const [themeAnchorEl, setThemeAnchorEl] = useState<null | HTMLElement>(null);
  const open = Boolean(anchorEl);
  const themeOpen = Boolean(themeAnchorEl);
  const navigate = useNavigate();
  const { user, logout } = useAuth();
  const { themeMode, setThemeMode } = useThemeContext();

  // Time and Date state
  const [dateTime, setDateTime] = useState(new Date());

  useEffect(() => {
    const timer = setInterval(() => setDateTime(new Date()), 1000);
    return () => clearInterval(timer);
  }, []);

  const formattedDate = dateTime.toLocaleDateString('en-IN', {
    weekday: 'short',
    day: '2-digit',
    month: 'short',
  });
  const formattedTime = dateTime.toLocaleTimeString('en-IN', {
    hour: '2-digit',
    minute: '2-digit',
    hour12: true,
  });

  // Avatar state
  const [avatar, setAvatar] = useState<string | null>(localStorage.getItem('adminAvatar'));
  const [profileOpen, setProfileOpen] = useState(false);
  const [tempAvatar, setTempAvatar] = useState<string | null>(avatar);

  const handleOpen = (e: React.MouseEvent<HTMLElement>) => setAnchorEl(e.currentTarget);
  const handleClose = () => setAnchorEl(null);

  const handleThemeMenuOpen = (e: React.MouseEvent<HTMLElement>) => setThemeAnchorEl(e.currentTarget);
  const handleThemeMenuClose = () => setThemeAnchorEl(null);

  const handleLogout = async () => {
    await logout();
    navigate('/login', { replace: true });
  };

  const handleProfileClick = () => {
    handleClose();
    setTempAvatar(avatar);
    setProfileOpen(true);
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setTempAvatar(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  };

  const handleSaveProfile = () => {
    if (tempAvatar) {
      localStorage.setItem('adminAvatar', tempAvatar);
      setAvatar(tempAvatar);
    } else {
      localStorage.removeItem('adminAvatar');
      setAvatar(null);
    }
    setProfileOpen(false);
  };

  const handleThemeSelect = (mode: 'light' | 'dark' | 'system') => {
    setThemeMode(mode);
    handleThemeMenuClose();
  };

  const renderAvatar = (avatarVal: string | null, size: number = 36, fontSz: number = 14) => {
    if (!avatarVal) {
      return (
        <Avatar sx={{ width: size, height: size, bgcolor: 'primary.dark', color: 'primary.light', fontSize: fontSz, fontWeight: 600 }}>
          {user?.name?.charAt(0)?.toUpperCase() || 'A'}
        </Avatar>
      );
    }
    if (isEmoji(avatarVal)) {
      return (
        <Avatar sx={{ width: size, height: size, bgcolor: 'background.default', fontSize: size * 0.6 }}>
          {avatarVal}
        </Avatar>
      );
    }
    return <Avatar src={avatarVal} sx={{ width: size, height: size }} />;
  };

  return (
    <>
      <AppBar
        position="fixed" elevation={0}
        sx={{
          left: SIDEBAR_WIDTH, width: `calc(100% - ${SIDEBAR_WIDTH}px)`,
          bgcolor: 'background.paper', backdropFilter: 'blur(12px)', color: 'text.primary',
          borderBottom: '1px solid', borderColor: 'divider', boxShadow: '0 1px 4px rgba(0,0,0,0.02)',
        }}
      >
        <Toolbar sx={{ justifyContent: 'space-between', minHeight: 64 }}>
          <Typography variant="h6" fontWeight={700} sx={{ fontSize: 18, fontFamily: '"Outfit", sans-serif' }}>FarmFresh Admin</Typography>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
            {/* Calendar & Time Widget */}
            <Box
              sx={{
                display: { xs: 'none', sm: 'flex' },
                alignItems: 'center',
                gap: 1,
                border: '1px solid',
                borderColor: 'divider',
                borderRadius: '20px',
                px: 2,
                py: 0.75,
                bgcolor: 'background.default',
                boxShadow: '0 2px 8px rgba(0,0,0,0.02)',
              }}
            >
              <CalendarTodayIcon sx={{ fontSize: 14, color: 'primary.main' }} />
              <Typography variant="body2" fontWeight={600} sx={{ fontSize: 12, fontFamily: 'Outfit, sans-serif' }}>
                {formattedDate} • {formattedTime}
              </Typography>
            </Box>

            <Box sx={{ textAlign: 'right' }}>
              <Typography variant="body2" fontWeight={600}>{user?.name || 'Admin'}</Typography>
              <Typography variant="caption" color="text.secondary">{user?.role?.replace('_', ' ') || 'Admin'}</Typography>
            </Box>

            {/* Theme Selector Button */}
            <Tooltip title="Change theme">
              <IconButton onClick={handleThemeMenuOpen} size="small" sx={{ border: '1px solid', borderColor: 'divider', p: 0.75 }}>
                {themeMode === 'light' && <LightModeIcon fontSize="small" />}
                {themeMode === 'dark' && <DarkModeIcon fontSize="small" />}
                {themeMode === 'system' && <DesktopWindowsIcon fontSize="small" />}
              </IconButton>
            </Tooltip>

            {/* Avatar Profile Button */}
            <IconButton onClick={handleOpen} size="small">
              {renderAvatar(avatar, 36, 14)}
            </IconButton>

            {/* User Dropdown Menu */}
            <Menu anchorEl={anchorEl} open={open} onClose={handleClose} anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }} transformOrigin={{ vertical: 'top', horizontal: 'right' }} slotProps={{ paper: { sx: { mt: 1, minWidth: 180, borderRadius: '12px', boxShadow: '0 8px 24px rgba(0,0,0,0.12)' } } }}>
              <MenuItem onClick={handleProfileClick} sx={{ py: 1.2 }}>
                <ListItemIcon><PersonIcon fontSize="small" /></ListItemIcon>
                <ListItemText>Profile</ListItemText>
              </MenuItem>
              <MenuItem onClick={handleLogout} sx={{ py: 1.2 }}>
                <ListItemIcon><LogoutIcon fontSize="small" /></ListItemIcon>
                <ListItemText>Logout</ListItemText>
              </MenuItem>
            </Menu>

            {/* Theme Dropdown Menu */}
            <Menu anchorEl={themeAnchorEl} open={themeOpen} onClose={handleThemeMenuClose} anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }} transformOrigin={{ vertical: 'top', horizontal: 'right' }} slotProps={{ paper: { sx: { mt: 1, minWidth: 160, borderRadius: '12px', boxShadow: '0 8px 24px rgba(0,0,0,0.12)' } } }}>
              <MenuItem onClick={() => handleThemeSelect('light')} selected={themeMode === 'light'} sx={{ py: 1 }}>
                <ListItemIcon><LightModeIcon fontSize="small" /></ListItemIcon>
                <ListItemText>Light Mode</ListItemText>
              </MenuItem>
              <MenuItem onClick={() => handleThemeSelect('dark')} selected={themeMode === 'dark'} sx={{ py: 1 }}>
                <ListItemIcon><DarkModeIcon fontSize="small" /></ListItemIcon>
                <ListItemText>Dark Mode</ListItemText>
              </MenuItem>
              <MenuItem onClick={() => handleThemeSelect('system')} selected={themeMode === 'system'} sx={{ py: 1 }}>
                <ListItemIcon><DesktopWindowsIcon fontSize="small" /></ListItemIcon>
                <ListItemText>System Default</ListItemText>
              </MenuItem>
            </Menu>
          </Box>
        </Toolbar>
      </AppBar>

      {/* Profile Avatar Selection Dialog */}
      <Dialog open={profileOpen} onClose={() => setProfileOpen(false)} maxWidth="xs" fullWidth slotProps={{ paper: { sx: { borderRadius: '16px', p: 1 } } }}>
        <DialogTitle fontWeight={600} textAlign="center">Update Profile Picture</DialogTitle>
        <DialogContent>
          <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2.5, my: 1 }}>
            {/* Large Preview */}
            <Box sx={{ position: 'relative' }}>
              {renderAvatar(tempAvatar, 90, 36)}
            </Box>

            {/* Custom File Upload */}
            <Button
              variant="outlined"
              component="label"
              size="small"
              startIcon={<PhotoCameraIcon />}
              sx={{ borderRadius: '20px', textTransform: 'none', px: 2.5 }}
            >
              Choose from files
              <input type="file" accept="image/*" hidden onChange={handleFileChange} />
            </Button>

            <Typography variant="body2" fontWeight={600} color="text.secondary" sx={{ mt: 1 }}>
              Or choose a default avatar:
            </Typography>

            {/* Fruit & Vegetable Emoji Grid */}
            <Grid container spacing={1.5} justifyContent="center" sx={{ maxWidth: 280 }}>
              {DEFAULT_AVATARS.map((emoji) => (
                <Grid item key={emoji}>
                  <Tooltip title={emoji} arrow>
                    <IconButton
                      onClick={() => setTempAvatar(emoji)}
                      sx={{
                        fontSize: 26,
                        width: 44,
                        height: 44,
                        borderRadius: '12px',
                        border: tempAvatar === emoji ? '2px solid #10B981' : '1px solid #E0E0E0',
                        bgcolor: tempAvatar === emoji ? 'rgba(16,185,129,0.08)' : 'transparent',
                        transition: 'all 0.2s',
                        '&:hover': {
                          transform: 'scale(1.1)',
                          bgcolor: 'action.hover',
                        }
                      }}
                    >
                      {emoji}
                    </IconButton>
                  </Tooltip>
                </Grid>
              ))}
            </Grid>
          </Box>
        </DialogContent>
        <DialogActions sx={{ px: 3, pb: 2, justifyContent: 'space-between' }}>
          <Button 
            onClick={() => {
              setTempAvatar(null);
            }} 
            color="error" 
            size="small" 
            sx={{ textTransform: 'none' }}
          >
            Clear Picture
          </Button>
          <Box sx={{ display: 'flex', gap: 1 }}>
            <Button onClick={() => setProfileOpen(false)} size="small" sx={{ textTransform: 'none' }}>Cancel</Button>
            <Button onClick={handleSaveProfile} variant="contained" size="small" sx={{ textTransform: 'none', borderRadius: '8px' }}>Save</Button>
          </Box>
        </DialogActions>
      </Dialog>
    </>
  );
}
