import { createTheme } from '@mui/material/styles';

const theme = createTheme({
  palette: {
    mode: 'dark',
    primary: {
      main: '#4ADE80',
      light: '#6EE7B7',
      dark: '#1F5B3A',
      contrastText: '#0B0D0C',
    },
    secondary: {
      main: '#7C877D',
      light: '#9CA39D',
      dark: '#5A635D',
    },
    background: {
      default: '#0B0D0C',
      paper: '#131614',
    },
    divider: '#232823',
    text: {
      primary: '#FFFFFF',
      secondary: '#7C877D',
    },
    error: {
      main: '#EF6B6B',
      light: '#F29696',
      dark: '#C44A4A',
    },
    success: {
      main: '#4ADE80',
      light: '#6EE7B7',
      dark: '#1F5B3A',
    },
  },
  typography: {
    fontFamily: '"Inter", "Roboto", "Helvetica", "Arial", sans-serif',
    h4: {
      fontWeight: 600,
      letterSpacing: '-0.02em',
      fontSize: 32,
    },
    h5: {
      fontWeight: 500,
      letterSpacing: '-0.01em',
      fontSize: 28,
    },
    h6: {
      fontWeight: 600,
      letterSpacing: '-0.01em',
      fontSize: 24,
    },
    subtitle1: {
      fontWeight: 600,
      fontSize: 14,
    },
    subtitle2: {
      fontWeight: 400,
      fontSize: 12,
      color: '#7C877D',
      textTransform: 'uppercase',
      letterSpacing: '0.04em',
    },
    body1: {
      fontSize: 15,
      fontWeight: 400,
    },
    body2: {
      fontSize: 14,
      fontWeight: 400,
    },
    caption: {
      fontSize: 12,
      color: '#7C877D',
    },
  },
  shape: {
    borderRadius: 12,
  },
  shadows: [
    'none',
    '0 1px 2px rgba(0,0,0,0.3)',
    '0 2px 4px rgba(0,0,0,0.3)',
    '0 4px 8px rgba(0,0,0,0.3)',
    '0 6px 12px rgba(0,0,0,0.3)',
    '0 8px 16px rgba(0,0,0,0.3)',
    '0 12px 24px rgba(0,0,0,0.3)',
    '0 14px 28px rgba(0,0,0,0.3)',
    '0 16px 32px rgba(0,0,0,0.3)',
    ...Array(16).fill('0 16px 32px rgba(0,0,0,0.3)'),
  ] as any,
  components: {
    /* ── Cards ── */
    MuiCard: {
      defaultProps: { elevation: 0 },
      styleOverrides: {
        root: {
          borderRadius: 12,
          border: '0.5px solid #232823',
          boxShadow: '0 1px 2px rgba(0,0,0,0.3)',
          transition: 'box-shadow 0.2s ease, transform 0.2s ease',
          backgroundColor: '#131614',
          '&:hover': {
            boxShadow: '0 4px 12px rgba(0,0,0,0.4)',
          },
        },
      },
    },
    MuiPaper: {
      styleOverrides: {
        root: {
          backgroundColor: '#131614',
          backgroundImage: 'none',
        },
        rounded: {
          borderRadius: 12,
        },
      },
    },
    /* ── Buttons ── */
    MuiButton: {
      styleOverrides: {
        root: {
          borderRadius: 10,
          textTransform: 'none' as const,
          fontWeight: 500,
          transition: 'all 0.2s ease',
        },
        containedPrimary: {
          backgroundColor: '#4ADE80',
          color: '#0B0D0C',
          '&:hover': {
            backgroundColor: '#6EE7B7',
            boxShadow: '0 4px 12px rgba(74,222,128,0.3)',
          },
        },
        containedSecondary: {
          backgroundColor: '#1F5B3A',
          color: '#FFFFFF',
          '&:hover': {
            backgroundColor: '#1F5B3A',
          },
        },
        outlinedPrimary: {
          borderColor: '#232823',
          color: '#4ADE80',
          '&:hover': {
            borderColor: '#4ADE80',
            backgroundColor: 'rgba(74, 222, 128, 0.08)',
          },
        },
      },
    },
    /* ── Text Fields ── */
    MuiOutlinedInput: {
      styleOverrides: {
        root: {
          borderRadius: 10,
          backgroundColor: '#131614',
          transition: 'border-color 0.2s ease, box-shadow 0.2s ease',
          '& .MuiOutlinedInput-notchedOutline': {
            borderColor: '#232823',
            borderWidth: 1,
          },
          '&:hover .MuiOutlinedInput-notchedOutline': {
            borderColor: '#4ADE80',
          },
          '&.Mui-focused .MuiOutlinedInput-notchedOutline': {
            borderColor: '#4ADE80',
            borderWidth: 2,
          },
        },
        input: {
          color: '#FFFFFF',
          '&::placeholder': {
            color: '#7C877D',
            opacity: 1,
          },
        },
      },
    },
    MuiInputLabel: {
      styleOverrides: {
        root: {
          color: '#7C877D',
          '&.Mui-focused': {
            color: '#4ADE80',
          },
        },
      },
    },
    /* ── Tables ── */
    MuiTableCell: {
      styleOverrides: {
        root: {
          fontSize: 14,
          padding: '14px 16px',
          borderBottom: '0.5px solid #232823',
          color: '#FFFFFF',
        },
        head: {
          fontWeight: 600,
          backgroundColor: '#0B0D0C',
          color: '#7C877D',
          fontSize: 12,
          textTransform: 'uppercase' as const,
          letterSpacing: '0.04em',
          borderBottom: '0.5px solid #232823',
        },
      },
    },
    MuiTableRow: {
      styleOverrides: {
        root: {
          transition: 'background-color 0.15s ease',
          '&:hover': {
            backgroundColor: 'rgba(74, 222, 128, 0.04)',
          },
        },
      },
    },
    MuiTableContainer: {
      styleOverrides: {
        root: {
          borderRadius: 12,
          border: '0.5px solid #232823',
        },
      },
    },
    /* ── Chips ── */
    MuiChip: {
      styleOverrides: {
        root: {
          fontWeight: 500,
          fontSize: 12,
          borderRadius: 8,
          backgroundColor: '#1F5B3A',
          color: '#FFFFFF',
        },
        sizeSmall: {
          height: 26,
        },
      },
    },
    /* ── Dialogs ── */
    MuiDialog: {
      styleOverrides: {
        paper: {
          borderRadius: 12,
          backgroundColor: '#131614',
          border: '0.5px solid #232823',
        },
      },
    },
    /* ── Tabs ── */
    MuiTab: {
      styleOverrides: {
        root: {
          textTransform: 'none',
          fontWeight: 500,
          fontSize: 14,
          color: '#7C877D',
          '&.Mui-selected': {
            color: '#4ADE80',
          },
        },
      },
    },
    MuiTabs: {
      styleOverrides: {
        indicator: {
          backgroundColor: '#4ADE80',
          height: 3,
        },
      },
    },
    /* ── Icon Buttons ── */
    MuiIconButton: {
      styleOverrides: {
        root: {
          color: '#FFFFFF',
          '&:hover': {
            backgroundColor: 'rgba(74, 222, 128, 0.08)',
          },
        },
      },
    },
    /* ── Avatar (for icon chips) ── */
    MuiAvatar: {
      styleOverrides: {
        root: {
          backgroundColor: '#1F5B3A',
          color: '#4ADE80',
        },
      },
    },
    /* ── List Items ── */
    MuiListItem: {
      styleOverrides: {
        root: {
          borderRadius: 10,
          '&:hover': {
            backgroundColor: 'rgba(74, 222, 128, 0.08)',
          },
        },
      },
    },
    /* ── Menu ── */
    MuiMenu: {
      styleOverrides: {
        paper: {
          borderRadius: 12,
          backgroundColor: '#131614',
          border: '0.5px solid #232823',
        },
      },
    },
    MuiMenuItem: {
      styleOverrides: {
        root: {
          color: '#FFFFFF',
          '&:hover': {
            backgroundColor: 'rgba(74, 222, 128, 0.08)',
          },
        },
      },
    },
    /* ── Tooltip ── */
    MuiTooltip: {
      styleOverrides: {
        tooltip: {
          backgroundColor: '#131614',
          border: '0.5px solid #232823',
          color: '#FFFFFF',
          fontSize: 12,
          borderRadius: 8,
        },
      },
    },
    /* ── Select ── */
    MuiSelect: {
      styleOverrides: {
        root: {
          backgroundColor: '#131614',
        },
      },
    },
    /* ── Autocomplete ── */
    MuiAutocomplete: {
      styleOverrides: {
        root: {
          '& .MuiOutlinedInput-root': {
            backgroundColor: '#131614',
          },
        },
      },
    },
    /* ── Alert ── */
    MuiAlert: {
      styleOverrides: {
        root: {
          borderRadius: 10,
          border: '0.5px solid #232823',
        },
        standardError: {
          backgroundColor: 'rgba(239, 107, 107, 0.1)',
          color: '#EF6B6B',
        },
        standardSuccess: {
          backgroundColor: 'rgba(74, 222, 128, 0.1)',
          color: '#4ADE80',
        },
        standardWarning: {
          backgroundColor: 'rgba(245, 158, 11, 0.1)',
          color: '#F59E0B',
        },
      },
    },
    /* ── Skeleton ── */
    MuiSkeleton: {
      styleOverrides: {
        root: {
          backgroundColor: '#1F5B3A',
        },
      },
    },
    /* ── Pagination ── */
    MuiPaginationItem: {
      styleOverrides: {
        root: {
          color: '#FFFFFF',
          borderColor: '#232823',
          '&.Mui-selected': {
            backgroundColor: '#4ADE80',
            color: '#0B0D0C',
            borderColor: '#4ADE80',
          },
        },
      },
    },
    /* ── Divider ── */
    MuiDivider: {
      styleOverrides: {
        root: {
          borderColor: '#232823',
          borderWidth: 0.5,
        },
      },
    },
  },
});

export default theme;