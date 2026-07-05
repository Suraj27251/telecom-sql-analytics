import { useState, useEffect } from 'react';
import { Box, Grid, Typography, Card, CardContent, Skeleton } from '@mui/material';
import {
  People as PeopleIcon, TrendingUp as RevenueIcon,
  Warning as ChurnIcon, AttachMoney as ChargesIcon,
} from '@mui/icons-material';
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend,
  PieChart, Pie, Cell,
} from 'recharts';
import KpiCard from '../components/KpiCard';
import FilterBar from '../components/FilterBar';
import { SkeletonCard, SkeletonKpi } from '../components/Skeletons';
import CityDrillDown from '../components/CityDrillDown';
import {
  getDashboard, getRevenue, getContracts, getChurn, getInternet, getMonthlyCharges,
} from '../api';

const COLORS = { blue: '#1976d2', green: '#2e7d32', orange: '#ed6c02', red: '#d32f2f', purple: '#7b1fa2', cyan: '#0097a7' };

function formatCurrency(value) {
  if (value >= 1_000_000) return `$${(value / 1_000_000).toFixed(1)}M`;
  if (value >= 1_000) return `$${(value / 1_000).toFixed(1)}K`;
  return `$${Number(value).toFixed(2)}`;
}

function formatNumber(value) {
  return Number(value).toLocaleString();
}

export default function DashboardPage() {
  const [dashboard, setDashboard] = useState(null);
  const [revenue, setRevenue] = useState([]);
  const [contracts, setContracts] = useState([]);
  const [churn, setChurn] = useState([]);
  const [internet, setInternet] = useState([]);
  const [monthly, setMonthly] = useState(null);
  const [loading, setLoading] = useState(true);
  const [filters, setFilters] = useState({ state: '', contract: '', internet_service: '', churn_label: '', gender: '' });
  const [selectedCity, setSelectedCity] = useState(null);

  const fetchData = () => {
    setLoading(true);
    Promise.all([getDashboard(), getRevenue(), getContracts(), getChurn(), getInternet(), getMonthlyCharges()])
      .then(([d, r, co, ch, i, m]) => {
        setDashboard(d.data);
        setRevenue(r.data.value || r.data);
        setContracts(co.data.value || co.data);
        setChurn(ch.data.value || ch.data);
        setInternet(i.data.value || i.data);
        setMonthly(m.data);
      })
      .catch(console.error)
      .finally(() => setLoading(false));
  };

  useEffect(() => { fetchData(); }, []);

  const totalRevenue = revenue.reduce((s, r) => s + (r.total_revenue || 0), 0);

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Box>
          <Typography variant="h4">Executive Dashboard</Typography>
          <Typography variant="body2" color="text.secondary">Real-time telecom churn analytics overview</Typography>
        </Box>
      </Box>

      <FilterBar filters={filters} onFilterChange={(k, v) => setFilters((f) => ({ ...f, [k]: v }))} onClear={() => setFilters({ state: '', contract: '', internet_service: '', churn_label: '', gender: '' })} />

      <Grid container spacing={3} sx={{ mb: 4 }}>
        <Grid item xs={12} sm={6} md={3}>
          {loading ? <SkeletonKpi /> : (
            <KpiCard title="Total Customers" value={formatNumber(dashboard?.total_customers)}
              icon={<PeopleIcon />} color={COLORS.blue} subtitle="Active subscriber base" trend="+2.1% vs last quarter" />
          )}
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          {loading ? <SkeletonKpi /> : (
            <KpiCard title="Total Revenue" value={formatCurrency(dashboard?.total_revenue)}
              icon={<RevenueIcon />} color={COLORS.green} subtitle="Cumulative lifetime charges" trend="+5.3% vs last quarter" />
          )}
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          {loading ? <SkeletonKpi /> : (
            <KpiCard title="Churn Rate" value={`${dashboard?.churn_rate}%`}
              icon={<ChurnIcon />} color={COLORS.red} subtitle={`${dashboard?.total_churned} customers lost`} trend="-0.8% vs last quarter" />
          )}
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          {loading ? <SkeletonKpi /> : (
            <KpiCard title="Avg Monthly Charges" value={`$${dashboard?.avg_monthly_charge}`}
              icon={<ChargesIcon />} color={COLORS.orange} subtitle="Per customer average" trend="+$1.20 vs last quarter" />
          )}
        </Grid>
      </Grid>

      <Grid container spacing={3}>
        <Grid item xs={12} md={6}>
          {loading ? <SkeletonCard height={400} /> : (
            <Card>
              <CardContent>
                <Typography variant="h6" sx={{ mb: 2 }}>Revenue by City</Typography>
                <ResponsiveContainer width="100%" height={400}>
                  <BarChart data={revenue} onClick={(e) => e?.activePayload?.[0]?.payload?.city && setSelectedCity(e.activePayload[0].payload.city)} style={{ cursor: 'pointer' }}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                    <XAxis dataKey="city" tick={{ fontSize: 11 }} />
                    <YAxis tickFormatter={(v) => `$${(v / 1000).toFixed(0)}K`} tick={{ fontSize: 11 }} />
                    <Tooltip formatter={(v) => formatCurrency(v)} cursor={{ fill: 'rgba(0,0,0,0.02)' }} />
                    <Bar dataKey="total_revenue" fill={COLORS.green} radius={[4, 4, 0, 0]} />
                  </BarChart>
                </ResponsiveContainer>
                <Typography variant="caption" color="text.secondary" sx={{ display: 'block', mt: 1, textAlign: 'center' }}>
                  Click a city bar to drill down
                </Typography>
              </CardContent>
            </Card>
          )}
        </Grid>

        <Grid item xs={12} md={6}>
          {loading ? <SkeletonCard height={400} /> : (
            <Card sx={{ height: '100%' }}>
              <CardContent>
                <Typography variant="h6" sx={{ mb: 2 }}>Churn Breakdown</Typography>
                <ResponsiveContainer width="100%" height={400}>
                  <PieChart>
                    <Pie data={churn} cx="50%" cy="50%" innerRadius={70} outerRadius={130} paddingAngle={4}
                      dataKey="count" nameKey="churn_label"
                      label={({ churn_label, percentage }) => `${churn_label}: ${percentage}%`}>
                      {churn.map((_, i) => (
                        <Cell key={i} fill={i === 0 ? COLORS.green : COLORS.red} />
                      ))}
                    </Pie>
                    <Tooltip formatter={(v) => formatNumber(v)} />
                  </PieChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>
          )}
        </Grid>

        <Grid item xs={12} md={6}>
          {loading ? <SkeletonCard height={360} /> : (
            <Card>
              <CardContent>
                <Typography variant="h6" sx={{ mb: 2 }}>Contract Distribution</Typography>
                <ResponsiveContainer width="100%" height={360}>
                  <PieChart>
                    <Pie data={contracts} cx="50%" cy="50%" innerRadius={60} outerRadius={120} paddingAngle={3}
                      dataKey="customers" nameKey="contract"
                      label={({ contract, customers }) => `${contract}: ${customers}`}>
                      {contracts.map((_, i) => (
                        <Cell key={i} fill={[COLORS.blue, COLORS.purple, COLORS.cyan][i % 3]} />
                      ))}
                    </Pie>
                    <Tooltip />
                    <Legend />
                  </PieChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>
          )}
        </Grid>

        <Grid item xs={12} md={6}>
          {loading ? <SkeletonCard height={360} /> : (
            <Card>
              <CardContent>
                <Typography variant="h6" sx={{ mb: 2 }}>Internet Service Breakdown</Typography>
                <ResponsiveContainer width="100%" height={360}>
                  <BarChart data={internet} layout="vertical">
                    <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                    <XAxis type="number" tick={{ fontSize: 11 }} />
                    <YAxis dataKey="internet_service" type="category" width={110} tick={{ fontSize: 11 }} />
                    <Tooltip />
                    <Bar dataKey="customers" radius={[0, 4, 4, 0]}>
                      {internet.map((_, i) => (
                        <Cell key={i} fill={[COLORS.orange, COLORS.red, COLORS.grey][i % 3]} />
                      ))}
                    </Bar>
                  </BarChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>
          )}
        </Grid>

        {monthly && (
          <Grid item xs={12}>
            {loading ? <SkeletonCard height={120} /> : (
              <Card>
                <CardContent>
                  <Typography variant="h6" sx={{ mb: 3 }}>Monthly Charges Distribution</Typography>
                  <Box sx={{ display: 'flex', gap: 4, justifyContent: 'center', flexWrap: 'wrap' }}>
                    {[
                      { label: 'Minimum', value: `$${monthly.minimum}`, color: COLORS.green },
                      { label: 'Average', value: `$${monthly.average}`, color: COLORS.blue },
                      { label: 'Median', value: `$${monthly.median}`, color: COLORS.orange },
                      { label: 'Maximum', value: `$${monthly.maximum}`, color: COLORS.red },
                    ].map((stat) => (
                      <Box key={stat.label} sx={{ textAlign: 'center', minWidth: 120 }}>
                        <Typography variant="h3" sx={{ fontWeight: 700, color: stat.color }}>{stat.value}</Typography>
                        <Typography variant="body2" color="text.secondary" sx={{ fontWeight: 500 }}>{stat.label}</Typography>
                      </Box>
                    ))}
                  </Box>
                </CardContent>
              </Card>
            )}
          </Grid>
        )}
      </Grid>

      <CityDrillDown city={selectedCity} onClose={() => setSelectedCity(null)} />
    </Box>
  );
}
