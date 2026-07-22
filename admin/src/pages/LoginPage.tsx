import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Box, Card, CardContent, Typography, Button, TextField, Alert } from '@mui/material';
import { useAuth } from '../contexts/AuthContext';

export default function LoginPage() {
  const [email, setEmail] = useState('admin@farmfresh.com');
  const [password, setPassword] = useState('Admin@123');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !password) {
      setError('Please enter email and password');
      return;
    }
    setLoading(true);
    setError('');
    try {
      await login(email, password);
      navigate('/', { replace: true });
    } catch (err: any) {
      const msg = err.response?.data?.message || err.message || 'Login failed';
      setError(msg);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Box
      sx={{
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        backgroundImage: 'url("/login_bg.jpg")',
        backgroundSize: 'cover',
        backgroundPosition: 'center',
        position: 'relative',
        overflow: 'hidden',
        '@keyframes fadeUp': {
          '0%': { opacity: 0, transform: 'translateY(30px)' },
          '100%': { opacity: 1, transform: 'translateY(0)' }
        },
        '&::before': {
          content: '""',
          position: 'absolute',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          background: 'linear-gradient(135deg, rgba(11, 13, 12, 0.75) 0%, rgba(15, 23, 42, 0.85) 100%)',
          zIndex: 0,
        }
      }}
    >
      <Card
        elevation={0}
        sx={{
          width: '90%',
          maxWidth: 420,
          borderRadius: '24px',
          border: '1px solid rgba(255, 255, 255, 0.08)',
          background: 'rgba(19, 22, 20, 0.7)',
          backdropFilter: 'blur(20px)',
          boxShadow: '0 20px 50px rgba(0, 0, 0, 0.45)',
          position: 'relative',
          overflow: 'hidden',
          zIndex: 1,
          animation: 'fadeUp 0.8s cubic-bezier(0.16, 1, 0.3, 1) forwards',
          '&::before': {
            content: '""',
            position: 'absolute',
            top: 0,
            left: 0,
            right: 0,
            height: '4px',
            background: 'linear-gradient(90deg, #10B981 0%, #3B82F6 100%)',
          }
        }}
      >
        <CardContent sx={{ p: 5 }}>
          <Box sx={{ textAlign: 'center', mb: 4.5 }}>
            <Typography 
              variant="h4" 
              fontWeight={800} 
              sx={{ 
                fontFamily: "'Outfit', sans-serif", 
                letterSpacing: '-0.5px', 
                background: 'linear-gradient(90deg, #34D399 0%, #60A5FA 100%)', 
                WebkitBackgroundClip: 'text', 
                WebkitTextFillColor: 'transparent',
                mb: 0.5
              }}
            >
              FarmFresh
            </Typography>
            <Typography variant="body2" sx={{ color: '#94A3B8', fontFamily: "'Outfit', sans-serif" }}>
              Sign in to your admin dashboard
            </Typography>
          </Box>

          {error && (
            <Alert 
              severity="error" 
              sx={{ 
                mb: 3, 
                borderRadius: '12px',
                bgcolor: 'rgba(239, 107, 107, 0.08)', 
                color: '#F87171', 
                border: '1px solid rgba(239, 107, 107, 0.15)',
                '& .MuiAlert-icon': { color: '#F87171' }
              }}
            >
              {error}
            </Alert>
          )}

          <Box component="form" onSubmit={handleSubmit}>
            <TextField
              fullWidth
              label="Email Address"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              margin="normal"
              autoFocus
              sx={{
                '& .MuiOutlinedInput-root': {
                  borderRadius: '14px',
                  backgroundColor: 'rgba(255, 255, 255, 0.02)',
                  backdropFilter: 'blur(10px)',
                  transition: 'all 0.3s ease',
                  '&:hover .MuiOutlinedInput-notchedOutline': { borderColor: 'rgba(74, 222, 128, 0.4)' },
                  '&.Mui-focused .MuiOutlinedInput-notchedOutline': { borderColor: '#4ADE80', borderWidth: 2 },
                },
                '& .MuiInputLabel-root': {
                  color: '#94A3B8',
                  fontFamily: "'Outfit', sans-serif",
                  '&.Mui-focused': { color: '#4ADE80' },
                },
                '& input': { color: '#FFFFFF', fontFamily: "'Outfit', sans-serif" },
                '& .MuiOutlinedInput-notchedOutline': { borderColor: 'rgba(255, 255, 255, 0.08)', borderWidth: 1 },
              }}
            />
            <TextField
              fullWidth
              label="Password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              margin="normal"
              sx={{
                '& .MuiOutlinedInput-root': {
                  borderRadius: '14px',
                  backgroundColor: 'rgba(255, 255, 255, 0.02)',
                  backdropFilter: 'blur(10px)',
                  transition: 'all 0.3s ease',
                  '&:hover .MuiOutlinedInput-notchedOutline': { borderColor: 'rgba(74, 222, 128, 0.4)' },
                  '&.Mui-focused .MuiOutlinedInput-notchedOutline': { borderColor: '#4ADE80', borderWidth: 2 },
                },
                '& .MuiInputLabel-root': {
                  color: '#94A3B8',
                  fontFamily: "'Outfit', sans-serif",
                  '&.Mui-focused': { color: '#4ADE80' },
                },
                '& input': { color: '#FFFFFF', fontFamily: "'Outfit', sans-serif" },
                '& .MuiOutlinedInput-notchedOutline': { borderColor: 'rgba(255, 255, 255, 0.08)', borderWidth: 1 },
              }}
            />
            <Button
              type="submit"
              variant="contained"
              fullWidth
              size="large"
              disabled={loading}
              sx={{
                py: 1.8,
                fontSize: 16,
                mt: 4,
                borderRadius: '14px',
                fontWeight: 700,
                fontFamily: "'Outfit', sans-serif",
                textTransform: 'none',
                background: 'linear-gradient(135deg, #10B981 0%, #059669 100%)',
                color: '#FFFFFF',
                boxShadow: '0 4px 15px rgba(16, 185, 129, 0.35)',
                transition: 'all 0.25s cubic-bezier(0.16, 1, 0.3, 1)',
                '&:hover': {
                  background: 'linear-gradient(135deg, #34D399 0%, #059669 100%)',
                  boxShadow: '0 6px 20px rgba(16, 185, 129, 0.55)',
                  transform: 'translateY(-2px)',
                },
                '&:disabled': {
                  background: 'rgba(16, 185, 129, 0.2)',
                  color: 'rgba(255, 255, 255, 0.35)',
                  boxShadow: 'none'
                },
              }}
            >
              {loading ? 'Signing in...' : 'Sign In'}
            </Button>
          </Box>
        </CardContent>
      </Card>
    </Box>
  );
}