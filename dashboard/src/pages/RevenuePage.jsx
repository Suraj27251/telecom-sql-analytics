import { useState, useEffect } from 'react';
import { Box, Grid, Typography, Card, CardContent } from '@mui/material';
import { TrendingUp as TrendIcon, AttachMoney as MoneyIcon } from '@mui/icons-material';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Cell } from 'recharts';
import { getRevenue, getMonthlyCharges } from '../api';
import KpiCard from '../components/KpiCard';
import { SkeletonCard, SkeletonKpi } from '../components/Skeletons';

const COLORS = { green: '#2e7d32', blue: '#1976d2', orange: '#ed6c02', purple: '#7b1fa2' };

function formatCurrency(v) {
  if (v >= 1_000_000) return `$${(v / 1_000_000).toFixed(1)}M`;
  if (v >= 1_000) return `$${(v / 1_000).toFixed(1)}K`;
  return `$${Number(v).toFixed(2)}`;
}

export default function RevenuePage() {
  const [revenue, setRevenue] = useState([]);
  const [monthly, setMonthly] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.all([getRevenue(), getMonthlyCharges()])
      .then(([rev, m]) => {
        setRevenue(rev.data.value || rev.data);
        setMonthly(m.data);
      })
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  const totalRev = revenue.reduce((s, r) => s + (r.total_revenue || 0), 0);

  return (
    <Box>
      <Typography variant="h4" sx={{ mb: 1 }}>Revenue Analysis</Typography>
      <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>Revenue distribution and pricing analytics</Typography>

      <Grid container spacing={3} sx={{ mb: 3 }}>
        <Grid item xs={12} sm={6} md={3}>
          {loading ? <SkeletonKpi /> : (
            <KpiCard title="Top 10 Cities Revenue" value={formatCurrency(totalRev)} icon={<TrendIcon />} color={COLORS.green} subtitle="Combined top cities" />
          )}
        </Grid>
        {monthly && (
          <>
            <Grid item xs={12} sm={6} md={3}>
              {loading ? <SkeletonKpi /> : (
                <KpiCard title="Average Monthly" value={`$${monthly.average}`} icon={<MoneyIcon />} color={COLORS.blue} subtitle="Per customer" />
              )}
            </Grid>
            <Grid item xs={12} sm={6} md={3}>
              {loading ? <SkeletonKpi /> : (
                <KpiCard title="Median Monthly" value={`$${monthly.median}`} icon={<MoneyIcon />} color={COLORS.orange} subtitle="50th percentile" />
              )}
            </Grid>
            <Grid item xs={12} sm={6} md={3}>
              {loading ? <SkeletonKpi /> : (
                <KpiCard title="Max Monthly" value={`$${monthly.maximum}`} icon={<MoneyIcon />} color={COLORS.purple} subtitle="Highest charge" />
              )}
            </Grid>
          </>
        )}
      </Grid>

      <Grid container spacing={3}>
        <Grid item xs={12} md={8}>
          {loading ? <SkeletonCard height={450} /> : (
            <Card>
              <CardContent>
                <Typography variant="h6" sx={{ mb: 2 }}>Revenue by City</Typography>
                <ResponsiveContainer width="100%" height={450}>
                  <BarChart data={revenue}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                    <XAxis dataKey="city" tick={{ fontSize: 11 }} />
                    <YAxis tickFormatter={(v) => `$${(v / 1000).toFixed(0)}K`} tick={{ fontSize: 11 }} />
                    <Tooltip formatter={(v) => formatCurrency(v)} />
                    <Bar dataKey="total_revenue" radius={[4, 4, 0, 0]}>
                      {revenue.map((_, i) => (
                        <Cell key={i} fill={i === 0 ? COLORS.green : '#90caf9'} />
                      ))}
                    </Bar>
                  </BarChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>
          )}
        </Grid>

        <Grid item xs={12} md={4}>
          {loading ? <SkeletonCard height={450} /> : (
            <Card sx={{ height: '100%' }}>
              <CardContent>
                <Typography variant="h6" sx={{ mb: 2 }}>Revenue Leaderboard</Typography>
                <Box sx={{ maxHeight: 420, overflow: 'auto' }}>
                  {revenue.map((r, i) => (
                    <Box key={i} sx={{
                      display: 'flex', justifyContent: 'space-between', alignItems: 'center',
                      py: 1.5, borderBottom: '1px solid #f0f0f0',
                      bgcolor: i === 0 ? '#f0fdf4' : 'transparent', px: 1, borderRadius: 1,
                    }}>
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
                        <Typography variant="body2" sx={{ fontWeight: 700, color: i === 0 ? COLORS.green : 'text.secondary', minWidth: 24 }}>
                          #{i + 1}
                        </Typography>
                        <Box>
                          <Typography variant="body2" sx={{ fontWeight: 600 }}>{r.city}</Typography>
                          <Typography variant="caption" color="text.secondary">{r.customers} customers</Typography>
                        </Box>
                      </Box>
                      <Typography variant="body2" sx={{ fontWeight: 700, color: COLORS.green }}>
                        {formatCurrency(r.total_revenue)}
                      </Typography>
                    </Box>
                  ))}
                </Box>
              </CardContent>
            </Card>
          )}
        </Grid>
      </Grid>
    </Box>
  );
}
