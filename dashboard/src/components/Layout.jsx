import { useState, useEffect } from 'react';
import { useNavigate, useLocation, Outlet } from 'react-router-dom';
import {
  Box, Drawer, AppBar, Toolbar, Typography, List, ListItem, ListItemButton,
  ListItemIcon, ListItemText, IconButton, useMediaQuery, useTheme, Chip,
  Stack, Avatar, Tooltip,
} from '@mui/material';
import {
  Menu as MenuIcon, Dashboard as DashboardIcon, People as PeopleIcon,
  PieChart as ChurnIcon, TrendingUp as RevenueIcon, Code as SqlIcon,
  Info as AboutIcon, CheckCircle as CheckIcon, Error as ErrorIcon,
} from '@mui/icons-material';
import { getDashboard } from '../api';

const DRAWER_WIDTH = 260;

const NAV_ITEMS = [
  { path: '/', label: 'Executive Dashboard', icon: <DashboardIcon /> },
  { path: '/customers', label: 'Customers', icon: <PeopleIcon /> },
  { path: '/churn', label: 'Churn Analysis', icon: <ChurnIcon /> },
  { path: '/revenue', label: 'Revenue Analysis', icon: <RevenueIcon /> },
  { path: '/sql-explorer', label: 'SQL Explorer', icon: <SqlIcon /> },
  { path: '/about', label: 'About Project', icon: <AboutIcon /> },
];

function StatusChip({ label, online }) {
  return (
    <Chip
      icon={online ? <CheckIcon sx={{ fontSize: 16 }} /> : <ErrorIcon sx={{ fontSize: 16 }} />}
      label={label}
      size="small"
      color={online ? 'success' : 'error'}
      variant="outlined"
      sx={{ fontWeight: 500 }}
    />
  );
}

export default function Layout() {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('md'));
  const [mobileOpen, setMobileOpen] = useState(false);
  const [apiOnline, setApiOnline] = useState(false);
  const [lastUpdated, setLastUpdated] = useState(new Date());
  const navigate = useNavigate();
  const location = useLocation();

  useEffect(() => {
    const checkApi = () => {
      getDashboard()
        .then(() => setApiOnline(true))
        .catch(() => setApiOnline(false));
    };
    checkApi();
    const interval = setInterval(checkApi, 30000);
    return () => clearInterval(interval);
  }, []);

  const drawerContent = (
    <Box>
      <Toolbar sx={{ px: 2 }}>
        <Avatar sx={{ bgcolor: 'primary.main', mr: 1.5, width: 36, height: 36, fontSize: 18 }}>TC</Avatar>
        <Box>
          <Typography variant="subtitle1" sx={{ fontWeight: 700, lineHeight: 1.2, color: 'primary.main' }}>
            Telecom
          </Typography>
          <Typography variant="caption" color="text.secondary" sx={{ lineHeight: 1 }}>
            Analytics Platform
          </Typography>
        </Box>
      </Toolbar>
      <List sx={{ px: 1.5, mt: 1 }}>
        {NAV_ITEMS.map((item) => (
          <ListItem key={item.path} disablePadding sx={{ mb: 0.5 }}>
            <ListItemButton
              selected={location.pathname === item.path}
              onClick={() => { navigate(item.path); if (isMobile) setMobileOpen(false); }}
              sx={{
                borderRadius: 2, px: 2, py: 1,
                '&.Mui-selected': {
                  backgroundColor: 'primary.main', color: '#fff',
                  '&:hover': { backgroundColor: 'primary.dark' },
                  '& .MuiListItemIcon-root': { color: '#fff' },
                },
              }}
            >
              <ListItemIcon sx={{ minWidth: 36 }}>{item.icon}</ListItemIcon>
              <ListItemText primary={item.label} primaryTypographyProps={{ fontSize: '0.875rem', fontWeight: 500 }} />
            </ListItemButton>
          </ListItem>
        ))}
      </List>
    </Box>
  );

  return (
    <Box sx={{ display: 'flex' }}>
      <AppBar
        position="fixed" elevation={0}
        sx={{
          backgroundColor: '#fff', color: '#1a1a2e',
          borderBottom: '1px solid #e8ecf0',
          backdropFilter: 'blur(8px)',
        }}
      >
        <Toolbar sx={{ justifyContent: 'space-between' }}>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
            <IconButton color="inherit" edge="start" onClick={() => setMobileOpen(!mobileOpen)} sx={{ display: { md: 'none' } }}>
              <MenuIcon />
            </IconButton>
            <Box>
              <Typography variant="h6" noWrap sx={{ fontWeight: 700, letterSpacing: '-0.02em', lineHeight: 1.2 }}>
                Telecom Customer Churn Analytics Platform
              </Typography>
              <Typography variant="caption" color="text.secondary">
                Powered by Azure Functions + PostgreSQL + React
              </Typography>
            </Box>
          </Box>
          <Stack direction="row" spacing={1.5} sx={{ alignItems: 'center' }}>
            <StatusChip label="API Online" online={apiOnline} />
            <StatusChip label="PostgreSQL Connected" online={apiOnline} />
            <Tooltip title="Last refreshed">
              <Chip
                label={lastUpdated.toLocaleDateString('en-US', { day: '2-digit', month: 'short', year: 'numeric' }) +
                  ' ' + lastUpdated.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })}
                size="small"
                variant="outlined"
                sx={{ fontWeight: 500, fontFamily: 'monospace' }}
              />
            </Tooltip>
          </Stack>
        </Toolbar>
      </AppBar>

      {isMobile ? (
        <Drawer variant="temporary" open={mobileOpen} onClose={() => setMobileOpen(false)} ModalProps={{ keepMounted: true }}
          sx={{ '& .MuiDrawer-paper': { width: DRAWER_WIDTH } }}>
          {drawerContent}
        </Drawer>
      ) : (
        <Drawer variant="permanent"
          sx={{ '& .MuiDrawer-paper': { width: DRAWER_WIDTH, boxSizing: 'border-box', borderRight: '1px solid #e8ecf0' } }}>
          {drawerContent}
        </Drawer>
      )}

      <Box component="main" sx={{
        flexGrow: 1, p: 3, mt: 10,
        ml: { md: `${DRAWER_WIDTH}px` },
        backgroundColor: '#f0f2f5', minHeight: '100vh',
      }}>
        <Outlet />
      </Box>
    </Box>
  );
}
