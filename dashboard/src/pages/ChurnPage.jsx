import { useState, useEffect } from 'react';
import { Box, Grid, Typography, Card, CardContent } from '@mui/material';
import {
  PieChart, Pie, Cell, Tooltip, ResponsiveContainer, Legend,
  BarChart, Bar, XAxis, YAxis, CartesianGrid,
} from 'recharts';
import { getChurnReasons, getContracts, getInternet, getChurn } from '../api';
import { SkeletonCard } from '../components/Skeletons';

const COLORS = { blue: '#1976d2', green: '#2e7d32', orange: '#ed6c02', red: '#d32f2f', purple: '#7b1fa2', cyan: '#0097a7' };

function CustomTooltip({ active, payload, label }) {
  if (!active || !payload?.length) return null;
  return (
    <Box sx={{ bgcolor: '#fff', p: 1.5, border: '1px solid #e0e0e0', borderRadius: 1, boxShadow: 2 }}>
      <Typography variant="body2" sx={{ fontWeight: 600 }}>{label || payload[0].name}</Typography>
      <Typography variant="body2">{payload[0].value} customers</Typography>
    </Box>
  );
}

export default function ChurnPage() {
  const [reasons, setReasons] = useState([]);
  const [contracts, setContracts] = useState([]);
  const [internet, setInternet] = useState([]);
  const [churn, setChurn] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.all([getChurnReasons(), getContracts(), getInternet(), getChurn()])
      .then(([r, co, i, ch]) => {
        setReasons(r.data.value || r.data);
        setContracts(co.data.value || co.data);
        setInternet(i.data.value || i.data);
        setChurn(ch.data.value || ch.data);
      })
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  return (
    <Box>
      <Typography variant="h4" sx={{ mb: 1 }}>Churn Analysis</Typography>
      <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>Deep dive into customer churn patterns and reasons</Typography>

      <Grid container spacing={3}>
        <Grid item xs={12} md={7}>
          {loading ? <SkeletonCard height={480} /> : (
            <Card sx={{ height: '100%' }}>
              <CardContent>
                <Typography variant="h6" sx={{ mb: 2 }}>Top Churn Reasons</Typography>
                <ResponsiveContainer width="100%" height={480}>
                  <BarChart data={reasons} layout="vertical">
                    <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                    <XAxis type="number" tick={{ fontSize: 11 }} />
                    <YAxis dataKey="churn_reason" type="category" width={240} tick={{ fontSize: 11 }} />
                    <Tooltip content={<CustomTooltip />} />
                    <Bar dataKey="count" radius={[0, 4, 4, 0]}>
                      {reasons.map((_, i) => (
                        <Cell key={i} fill={[COLORS.red, COLORS.orange, COLORS.purple, COLORS.blue, COLORS.cyan][i % 5]} />
                      ))}
                    </Bar>
                  </BarChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>
          )}
        </Grid>

        <Grid item xs={12} md={5}>
          {loading ? <SkeletonCard height={480} /> : (
            <Card sx={{ height: '100%' }}>
              <CardContent>
                <Typography variant="h6" sx={{ mb: 2 }}>Churn by Label</Typography>
                <ResponsiveContainer width="100%" height={480}>
                  <PieChart>
                    <Pie data={churn} cx="50%" cy="50%" innerRadius={60} outerRadius={120} paddingAngle={4}
                      dataKey="count" nameKey="churn_label"
                      label={({ churn_label, percentage }) => `${churn_label}: ${percentage}%`}>
                      {churn.map((_, i) => (
                        <Cell key={i} fill={i === 0 ? COLORS.green : COLORS.red} />
                      ))}
                    </Pie>
                    <Tooltip />
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
                <Typography variant="h6" sx={{ mb: 2 }}>Churn by Contract Type</Typography>
                <ResponsiveContainer width="100%" height={360}>
                  <BarChart data={contracts}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                    <XAxis dataKey="contract" tick={{ fontSize: 12 }} />
                    <YAxis tick={{ fontSize: 12 }} />
                    <Tooltip />
                    <Bar dataKey="customers" radius={[4, 4, 0, 0]}>
                      {contracts.map((_, i) => (
                        <Cell key={i} fill={[COLORS.blue, COLORS.purple, COLORS.cyan][i % 3]} />
                      ))}
                    </Bar>
                  </BarChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>
          )}
        </Grid>

        <Grid item xs={12} md={6}>
          {loading ? <SkeletonCard height={360} /> : (
            <Card>
              <CardContent>
                <Typography variant="h6" sx={{ mb: 2 }}>Churn by Internet Service</Typography>
                <ResponsiveContainer width="100%" height={360}>
                  <BarChart data={internet}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                    <XAxis dataKey="internet_service" tick={{ fontSize: 12 }} />
                    <YAxis tick={{ fontSize: 12 }} />
                    <Tooltip />
                    <Bar dataKey="customers" radius={[4, 4, 0, 0]}>
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
      </Grid>
    </Box>
  );
}
