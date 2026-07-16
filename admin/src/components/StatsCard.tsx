import { Card, CardContent, Box, Typography } from '@mui/material';
import { useTheme } from '@mui/material/styles';
import type { ReactNode } from 'react';

interface Props {
  title: string;
  value: string | number;
  icon: ReactNode;
  color: string;
  bg: string;
  subtitle?: string;
  gradient?: string;
}

export default function StatsCard({ title, value, icon, color, bg, subtitle, gradient }: Props) {
  const theme = useTheme();
  const isDark = theme.palette.mode === 'dark';

  return (
    <Card
      sx={{
        borderRadius: 4,
        overflow: 'hidden',
        position: 'relative',
        background: isDark
          ? 'linear-gradient(135deg, rgba(30, 41, 59, 0.4) 0%, rgba(15, 23, 42, 0.8) 100%)'
          : 'linear-gradient(135deg, rgba(255, 255, 255, 0.9) 0%, rgba(241, 245, 249, 0.9) 100%)',
        backdropFilter: 'blur(20px)',
        border: `1px solid ${isDark ? 'rgba(255, 255, 255, 0.06)' : 'rgba(15, 23, 42, 0.05)'}`,
        boxShadow: isDark
          ? '0 10px 30px -10px rgba(0, 0, 0, 0.3)'
          : '0 10px 30px -10px rgba(148, 163, 184, 0.1)',
        transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
        '&:hover': {
          transform: 'translateY(-4px)',
          boxShadow: isDark
            ? `0 15px 35px -5px rgba(0, 0, 0, 0.5), 0 0 15px 0px ${color}20`
            : `0 15px 35px -5px ${color}15, 0 0 15px 0px ${color}10`,
          borderColor: color,
          '& .icon-container': {
            transform: 'scale(1.1) rotate(5deg)',
          }
        }
      }}
    >
      {/* Decorative background blur shape */}
      <Box
        sx={{
          position: 'absolute',
          top: -20,
          right: -20,
          width: 80,
          height: 80,
          borderRadius: '50%',
          background: color,
          opacity: isDark ? 0.06 : 0.04,
          filter: 'blur(20px)',
          pointerEvents: 'none',
        }}
      />

      <CardContent sx={{ display: 'flex', alignItems: 'center', gap: 2.5, p: 3, '&:last-child': { pb: 3 } }}>
        <Box
          className="icon-container"
          sx={{
            width: 52,
            height: 52,
            borderRadius: '14px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            background: gradient || `linear-gradient(135deg, ${color}22 0%, ${color}44 100%)`,
            color: color,
            transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
            boxShadow: `0 4px 12px ${color}15`,
            '& .MuiSvgIcon-root': { fontSize: 26 }
          }}
        >
          {icon}
        </Box>
        <Box sx={{ flexGrow: 1 }}>
          <Typography
            variant="body2"
            fontWeight={600}
            color="text.secondary"
            sx={{ fontSize: 11, textTransform: 'uppercase', letterSpacing: '0.08em', mb: 0.5 }}
          >
            {title}
          </Typography>
          <Typography
            variant="h5"
            fontWeight={800}
            sx={{
              lineHeight: 1.1,
              fontFamily: '"Outfit", sans-serif',
              letterSpacing: '-0.02em',
              background: isDark
                ? 'linear-gradient(90deg, #FFFFFF 0%, #E2E8F0 100%)'
                : 'linear-gradient(90deg, #0F172A 0%, #334155 100%)',
              WebkitBackgroundClip: 'text',
              WebkitTextFillColor: 'transparent',
            }}
          >
            {value}
          </Typography>
          {subtitle && (
            <Typography variant="caption" color="text.secondary" sx={{ mt: 0.5, display: 'block' }}>
              {subtitle}
            </Typography>
          )}
        </Box>
      </CardContent>
    </Card>
  );
}
