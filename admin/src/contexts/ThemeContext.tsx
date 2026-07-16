import React, { createContext, useContext, useState, useEffect, useMemo } from 'react';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import { CssBaseline } from '@mui/material';

type ThemeMode = 'light' | 'dark' | 'system';

interface ThemeContextType {
  themeMode: ThemeMode;
  setThemeMode: (mode: ThemeMode) => void;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

export const useThemeContext = () => {
  const context = useContext(ThemeContext);
  if (!context) throw new Error('useThemeContext must be used within a CustomThemeProvider');
  return context;
};

export const CustomThemeProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [themeMode, setThemeModeState] = useState<ThemeMode>(() => {
    const saved = localStorage.getItem('themeMode');
    return (saved as ThemeMode) || 'system';
  });

  const setThemeMode = (mode: ThemeMode) => {
    localStorage.setItem('themeMode', mode);
    setThemeModeState(mode);
  };

  const [systemMode, setSystemMode] = useState<'light' | 'dark'>(() => {
    return typeof window !== 'undefined' && window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  });

  useEffect(() => {
    if (typeof window === 'undefined') return;
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
    const listener = (e: MediaQueryListEvent) => {
      setSystemMode(e.matches ? 'dark' : 'light');
    };
    mediaQuery.addEventListener('change', listener);
    return () => mediaQuery.removeEventListener('change', listener);
  }, []);

  const activeMode = themeMode === 'system' ? systemMode : themeMode;

  const theme = useMemo(() => {
    const isDark = activeMode === 'dark';

    // Premium Color Palette (SaaS Theme)
    const primaryColor = '#10B981'; // Emerald Green
    const primaryLight = '#34D399';
    const primaryDark = '#047857';

    const bgDefault = isDark ? '#060813' : '#F6F8FC'; // Space navy vs soft gray
    const bgPaper = isDark ? '#0C0F22' : '#FFFFFF';   // Cards / Panels

    const borderClr = isDark ? 'rgba(255, 255, 255, 0.08)' : 'rgba(0, 0, 0, 0.06)';
    const textPrimary = isDark ? '#F1F5F9' : '#0F172A';
    const textSecondary = isDark ? '#94A3B8' : '#64748B';

    return createTheme({
      palette: {
        mode: activeMode,
        primary: {
          main: primaryColor,
          light: primaryLight,
          dark: primaryDark,
          contrastText: '#FFFFFF',
        },
        secondary: {
          main: isDark ? '#818CF8' : '#4F46E5', // Indigo / Purple
        },
        background: {
          default: bgDefault,
          paper: bgPaper,
        },
        divider: borderClr,
        text: {
          primary: textPrimary,
          secondary: textSecondary,
        },
        error: {
          main: '#F43F5E',
        },
        success: {
          main: '#10B981',
        },
        warning: {
          main: '#F59E0B',
        },
      },
      typography: {
        fontFamily: '"Outfit", "Plus Jakarta Sans", "Inter", sans-serif',
        h4: { fontWeight: 800, letterSpacing: '-0.03em', fontSize: 28 },
        h5: { fontWeight: 800, letterSpacing: '-0.02em', fontSize: 22 },
        h6: { fontWeight: 700, letterSpacing: '-0.02em', fontSize: 18 },
        subtitle1: { fontWeight: 600, fontSize: 14 },
        subtitle2: { fontWeight: 600, fontSize: 11, color: textSecondary, letterSpacing: '0.06em', textTransform: 'uppercase' },
        body1: { fontSize: 15, fontWeight: 400 },
        body2: { fontSize: 14, fontWeight: 400 },
        caption: { fontSize: 12, color: textSecondary },
      },
      shape: {
        borderRadius: 16,
      },
      shadows: isDark
        ? [
            'none',
            '0 4px 20px rgba(0,0,0,0.6)',
            '0 8px 30px rgba(0,0,0,0.7)',
            ...Array(22).fill('0 8px 30px rgba(0,0,0,0.7)'),
          ] as any
        : [
            'none',
            '0 2px 8px rgba(15,23,42,0.04)',
            '0 10px 30px rgba(15,23,42,0.05)',
            ...Array(22).fill('0 10px 30px rgba(15,23,42,0.05)'),
          ] as any,
      components: {
        MuiCssBaseline: {
          styleOverrides: {
            body: {
              transition: 'background-color 0.25s ease, color 0.25s ease',
              '&::-webkit-scrollbar': { width: 6 },
              '&::-webkit-scrollbar-track': { background: 'transparent' },
              '&::-webkit-scrollbar-thumb': { background: isDark ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.1)', borderRadius: 3 },
            },
          },
        },
        MuiCard: {
          defaultProps: { elevation: 0 },
          styleOverrides: {
            root: {
              borderRadius: 16,
              border: `1px solid ${borderClr}`,
              boxShadow: isDark ? '0 4px 20px rgba(0,0,0,0.3)' : '0 4px 20px rgba(15,23,42,0.02)',
              transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
              backgroundColor: isDark ? 'rgba(12, 15, 34, 0.8)' : 'rgba(255, 255, 255, 0.8)',
              backdropFilter: 'blur(20px)',
              '&:hover': {
                transform: 'translateY(-2px)',
                boxShadow: isDark ? '0 12px 30px rgba(16,185,129,0.08)' : '0 12px 30px rgba(15,23,42,0.04)',
                borderColor: primaryColor,
              },
            },
          },
        },
        MuiPaper: {
          styleOverrides: {
            root: {
              backgroundImage: 'none',
              backgroundColor: bgPaper,
            },
            rounded: {
              borderRadius: 16,
            },
          },
        },
        MuiButton: {
          styleOverrides: {
            root: {
              borderRadius: 12,
              textTransform: 'none',
              fontWeight: 600,
              padding: '8px 18px',
              transition: 'all 0.2s ease',
            },
            containedPrimary: {
              background: `linear-gradient(135deg, ${primaryColor} 0%, ${primaryLight} 100%)`,
              color: '#FFFFFF',
              boxShadow: `0 4px 14px rgba(16,185,129,0.25)`,
              '&:hover': {
                background: `linear-gradient(135deg, ${primaryLight} 0%, ${primaryColor} 100%)`,
                boxShadow: `0 6px 20px rgba(16,185,129,0.35)`,
                transform: 'scale(1.01)',
              },
            },
            outlinedPrimary: {
              borderColor: borderClr,
              color: textPrimary,
              '&:hover': {
                borderColor: primaryColor,
                backgroundColor: isDark ? 'rgba(16,185,129,0.08)' : 'rgba(16,185,129,0.04)',
              },
            },
          },
        },
        MuiOutlinedInput: {
          styleOverrides: {
            root: {
              borderRadius: 12,
              backgroundColor: isDark ? 'rgba(14,19,34,0.3)' : '#FFFFFF',
              '& .MuiOutlinedInput-notchedOutline': {
                borderColor: borderClr,
              },
              '&:hover .MuiOutlinedInput-notchedOutline': {
                borderColor: primaryColor,
              },
              '&.Mui-focused .MuiOutlinedInput-notchedOutline': {
                borderColor: primaryColor,
                borderWidth: 2,
              },
            },
            input: {
              color: textPrimary,
              '&::placeholder': {
                color: textSecondary,
                opacity: 0.6,
              },
            },
          },
        },
        MuiInputLabel: {
          styleOverrides: {
            root: {
              color: textSecondary,
              '&.Mui-focused': {
                color: primaryColor,
              },
            },
          },
        },
        MuiTableCell: {
          styleOverrides: {
            root: {
              padding: '16px 20px',
              borderColor: borderClr,
              color: textPrimary,
            },
            head: {
              fontWeight: 700,
              backgroundColor: isDark ? 'rgba(12,15,34,0.5)' : '#F8FAFC',
              color: textSecondary,
              textTransform: 'uppercase',
              fontSize: 11,
              letterSpacing: '0.06em',
            },
          },
        },
        MuiTableRow: {
          styleOverrides: {
            root: {
              transition: 'background-color 0.2s ease',
              '&:hover': {
                backgroundColor: isDark ? 'rgba(16,185,129,0.02)' : 'rgba(16,185,129,0.01)',
              },
            },
          },
        },
        MuiTableContainer: {
          styleOverrides: {
            root: {
              borderRadius: 16,
              border: `1px solid ${borderClr}`,
              boxShadow: 'none',
              backgroundColor: bgPaper,
            },
          },
        },
        MuiChip: {
          styleOverrides: {
            root: {
              fontWeight: 600,
              fontSize: 12,
              borderRadius: 8,
            },
          },
        },
        MuiDialog: {
          styleOverrides: {
            paper: {
              borderRadius: 20,
              border: `1px solid ${borderClr}`,
              boxShadow: isDark ? '0 20px 50px rgba(0,0,0,0.5)' : '0 20px 50px rgba(15,23,42,0.1)',
            },
          },
        },
        MuiTabs: {
          styleOverrides: {
            indicator: {
              height: 3,
              borderRadius: '3px 3px 0 0',
              backgroundColor: primaryColor,
            },
          },
        },
        MuiTab: {
          styleOverrides: {
            root: {
              fontWeight: 600,
              textTransform: 'none',
              fontSize: 14,
              color: textSecondary,
              '&.Mui-selected': {
                color: primaryColor,
              },
            },
          },
        },
        MuiIconButton: {
          styleOverrides: {
            root: {
              color: textPrimary,
              transition: 'all 0.2s ease',
              '&:hover': {
                backgroundColor: isDark ? 'rgba(16,185,129,0.08)' : 'rgba(16,185,129,0.04)',
                color: primaryColor,
              },
            },
          },
        },
        MuiMenu: {
          styleOverrides: {
            paper: {
              borderRadius: 16,
              border: `1px solid ${borderClr}`,
              boxShadow: isDark ? '0 10px 30px rgba(0,0,0,0.3)' : '0 10px 30px rgba(15,23,42,0.08)',
              backgroundColor: bgPaper,
            },
          },
        },
        MuiMenuItem: {
          styleOverrides: {
            root: {
              borderRadius: 8,
              margin: '4px 8px',
              padding: '8px 16px',
              color: textPrimary,
              '&:hover': {
                backgroundColor: isDark ? 'rgba(16,185,129,0.08)' : 'rgba(16,185,129,0.04)',
                color: primaryColor,
              },
            },
          },
        },
        MuiTooltip: {
          styleOverrides: {
            tooltip: {
              backgroundColor: isDark ? '#1E293B' : '#0F172A',
              color: '#FFFFFF',
              fontSize: 12,
              borderRadius: 8,
              padding: '6px 10px',
            },
          },
        },
        MuiAlert: {
          styleOverrides: {
            root: {
              borderRadius: 12,
              border: `1px solid ${borderClr}`,
            },
          },
        },
      },
    });
  }, [activeMode]);

  return (
    <ThemeContext.Provider value={{ themeMode, setThemeMode }}>
      <ThemeProvider theme={theme}>
        <CssBaseline />
        {children}
      </ThemeProvider>
    </ThemeContext.Provider>
  );
};
