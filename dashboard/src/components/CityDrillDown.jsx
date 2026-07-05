import { useState, useEffect } from 'react';
import {
  Dialog, DialogTitle, DialogContent, Box, Typography, Grid, Chip, IconButton,
  Divider, CircularProgress, Tabs, Tab,
} from '@mui/material';
import { Close as CloseIcon } from '@mui/icons-material';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Cell } from 'recharts';
import { getCustomer, getRevenue } from '../api';

const COLORS = ['#1976d2', '#2e7d32', '#ed6c02', '#d32f2f', '#7b1fa2', '#0097a7'];

function formatCurrency(v) {
  if (v >= 1_000_000) return `$${(v / 1_000_000).toFixed(1)}M`;
  if (v >= 1_000) return `$${(v / 1_000).toFixed(1)}K`;
  return `$${Number(v).toFixed(2)}`;
}

export default function CityDrillDown({ city, onClose }) {
  const [revenueData, setRevenueData] = useState([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!city) return;
    setLoading(true);
    getRevenue()
      .then((res) => {
        const data = res.data.value || res.data;
        setRevenueData(data);
      })
      .catch(console.error)
      .finally(() => setLoading(false));
  }, [city]);

  const cityData = revenueData.find((r) => r.city === city);

  return (
    <Dialog open={!!city} onClose={onClose} maxWidth="md" fullWidth PaperProps={{ sx: { borderRadius: 3 } }}>
      <DialogTitle sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', pb: 1 }}>
        <Box>
          <Typography variant="h5" sx={{ fontWeight: 700 }}>{city}</Typography>
          <Typography variant="caption" color="text.secondary">City Drill-Down Analysis</Typography>
        </Box>
        <IconButton onClick={onClose}><CloseIcon /></IconButton>
      </DialogTitle>
      <Divider />
      <DialogContent>
        {loading ? (
          <Box sx={{ display: 'flex', justifyContent: 'center', py: 6 }}><CircularProgress /></Box>
        ) : cityData ? (
          <Grid container spacing={3}>
            <Grid item xs={6} md={3}>
              <Box sx={{ textAlign: 'center', p: 2, bgcolor: '#f5f7fa', borderRadius: 2 }}>
                <Typography variant="h4" sx={{ fontWeight: 700, color: '#1976d2' }}>{cityData.customers}</Typography>
                <Typography variant="body2" color="text.secondary">Customers</Typography>
              </Box>
            </Grid>
            <Grid item xs={6} md={3}>
              <Box sx={{ textAlign: 'center', p: 2, bgcolor: '#f5f7fa', borderRadius: 2 }}>
                <Typography variant="h4" sx={{ fontWeight: 700, color: '#2e7d32' }}>{formatCurrency(cityData.total_revenue)}</Typography>
                <Typography variant="body2" color="text.secondary">Total Revenue</Typography>
              </Box>
            </Grid>
            <Grid item xs={6} md={3}>
              <Box sx={{ textAlign: 'center', p: 2, bgcolor: '#f5f7fa', borderRadius: 2 }}>
                <Typography variant="h4" sx={{ fontWeight: 700, color: '#ed6c02' }}>
                  ${cityData.customers > 0 ? (cityData.total_revenue / cityData.customers).toFixed(0) : 0}
                </Typography>
                <Typography variant="body2" color="text.secondary">Avg Revenue/Customer</Typography>
              </Box>
            </Grid>
            <Grid item xs={6} md={3}>
              <Box sx={{ textAlign: 'center', p: 2, bgcolor: '#f5f7fa', borderRadius: 2 }}>
                <Typography variant="h4" sx={{ fontWeight: 700, color: '#7b1fa2' }}>
                  #{revenueData.findIndex((r) => r.city === city) + 1}
                </Typography>
                <Typography variant="body2" color="text.secondary">Revenue Rank</Typography>
              </Box>
            </Grid>
            <Grid item xs={12}>
              <Typography variant="h6" sx={{ mb: 2 }}>Top Cities Comparison</Typography>
              <ResponsiveContainer width="100%" height={280}>
                <BarChart data={revenueData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                  <XAxis dataKey="city" tick={{ fontSize: 11 }} />
                  <YAxis tickFormatter={(v) => `$${(v / 1000).toFixed(0)}K`} tick={{ fontSize: 11 }} />
                  <Tooltip formatter={(v) => formatCurrency(v)} />
                  <Bar dataKey="total_revenue" radius={[4, 4, 0, 0]}>
                    {revenueData.map((r, i) => (
                      <Cell key={i} fill={r.city === city ? '#d32f2f' : '#90caf9'} />
                    ))}
                  </Bar>
                </BarChart>
              </ResponsiveContainer>
            </Grid>
          </Grid>
        ) : (
          <Typography color="text.secondary" sx={{ textAlign: 'center', py: 4 }}>No data available</Typography>
        )}
      </DialogContent>
    </Dialog>
  );
}
