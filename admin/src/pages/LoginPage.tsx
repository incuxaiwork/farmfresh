import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Box, Card, CardContent, Typography, Button, TextField, Alert } from '@mui/material';
import { useAuth } from '../contexts/AuthContext';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
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
        backgroundColor: '#0B0D0C',
        position: 'relative',
        overflow: 'hidden',
        '&::before': {
          content: '""',
          position: 'absolute',
          width: 500,
          height: 500,
          borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(74,222,128,0.08) 0%, transparent 70%)',
          top: -120,
          right: -100,
        },
        '&::after': {
          content: '""',
          position: 'absolute',
          width: 400,
          height: 400,
          borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(31,91,58,0.06) 0%, transparent 70%)',
          bottom: -80,
          left: -60,
        },
      }}
    >
      <Card
        elevation={0}
        className="page-fade-in"
        sx={{
          width: '100%',
          maxWidth: 420,
          border: '0.5px solid #232823',
          bgcolor: '#131614',
          zIndex: 1,
        }}
      >
        <CardContent sx={{ p: 5 }}>
          <Box sx={{ textAlign: 'center', mb: 4 }}>
            <Typography variant="h4" fontWeight={700} color="#4ADE80" mb={0.5}>
              FarmFresh
            </Typography>
            <Typography variant="body2" color="#7C877D">
              Sign in to your admin dashboard
            </Typography>
          </Box>

          {error && <Alert severity="error" sx={{ mb: 2, bgcolor: 'rgba(239,107,107,0.1)', color: '#EF6B6B' }}>{error}</Alert>}

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
                  borderRadius: 10,
                  backgroundColor: '#131614',
                  '&:hover .MuiOutlinedInput-notchedOutline': { borderColor: '#4ADE80' },
                  '&.Mui-focused .MuiOutlinedInput-notchedOutline': { borderColor: '#4ADE80', borderWidth: 2 },
                },
                '& .MuiInputLabel-root': {
                  color: '#7C877D',
                  '&.Mui-focused': { color: '#4ADE80' },
                },
                '& input': { color: '#FFFFFF' },
                '& .MuiOutlinedInput-notchedOutline': { borderColor: '#232823', borderWidth: 1 },
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
                  borderRadius: 10,
                  backgroundColor: '#131614',
                  '&:hover .MuiOutlinedInput-notchedOutline': { borderColor: '#4ADE80' },
                  '&.Mui-focused .MuiOutlinedInput-notchedOutline': { borderColor: '#4ADE80', borderWidth: 2 },
                },
                '& .MuiInputLabel-root': {
                  color: '#7C877D',
                  '&.Mui-focused': { color: '#4ADE80' },
                },
                '& input': { color: '#FFFFFF' },
                '& .MuiOutlinedInput-notchedOutline': { borderColor: '#232823', borderWidth: 1 },
              }}
            />
            <Button
              type="submit"
              variant="contained"
              fullWidth
              size="large"
              disabled={loading}
              sx={{
                py: 1.5,
                fontSize: 16,
                mt: 3,
                borderRadius: 10,
                fontWeight: 500,
                backgroundColor: '#4ADE80',
                color: '#0B0D0C',
                '&:hover': {
                  backgroundColor: '#6EE7B7',
                  boxShadow: '0 4px 12px rgba(74,222,128,0.3)',
                },
                '&:disabled': {
                  backgroundColor: '#1F5B3A',
                  color: '#7C877D',
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