import { createTheme } from '@mui/material/styles';

const COLORS = {
  blue: '#1976d2',
  green: '#2e7d32',
  orange: '#ed6c02',
  red: '#d32f2f',
  purple: '#7b1fa2',
  cyan: '#0097a7',
  grey: '#546e7a',
};

const theme = createTheme({
  palette: {
    mode: 'light',
    primary: { main: COLORS.blue },
    secondary: { main: COLORS.purple },
    background: { default: '#f0f2f5', paper: '#ffffff' },
    success: { main: COLORS.green },
    warning: { main: COLORS.orange },
    error: { main: COLORS.red },
  },
  typography: {
    fontFamily: '"Inter", "Roboto", "Helvetica", "Arial", sans-serif',
    h4: { fontWeight: 700, letterSpacing: '-0.02em' },
    h5: { fontWeight: 600, letterSpacing: '-0.01em' },
    h6: { fontWeight: 600 },
  },
  shape: { borderRadius: 12 },
  components: {
    MuiCard: {
      styleOverrides: {
        root: {
          boxShadow: '0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04)',
          border: '1px solid #e8ecf0',
          transition: 'box-shadow 0.2s ease',
          '&:hover': { boxShadow: '0 4px 12px rgba(0,0,0,0.08)' },
        },
      },
    },
    MuiPaper: {
      styleOverrides: { root: { backgroundImage: 'none' } },
    },
    MuiChip: {
      styleOverrides: {
        root: { fontWeight: 500 },
      },
    },
  },
});

export { COLORS };
export default theme;
