import { Box, Typography, Card, CardContent, Grid, Chip, Link, Divider, Avatar } from '@mui/material';
import { GitHub as GitHubIcon, Storage as DbIcon, Code as ApiIcon, Web as WebIcon, Architecture as ArchIcon } from '@mui/icons-material';

const TECH_STACK = [
  { category: 'Frontend', items: ['React 19', 'Vite', 'Material UI', 'Recharts', 'Axios', 'React Router'] },
  { category: 'Backend', items: ['Azure Functions', 'Python 3.x', 'psycopg3', 'REST API'] },
  { category: 'Database', items: ['PostgreSQL 18.4', 'Parameterized Queries', '13+ Indexes'] },
  { category: 'Analytics', items: ['Advanced SQL', 'Window Functions', 'Aggregations', 'CTEs'] },
];

const ARCHITECTURE = [
  { icon: <WebIcon />, label: 'React Dashboard', desc: 'Vite + MUI + Recharts' },
  { icon: <ApiIcon />, label: 'Azure Functions REST API', desc: 'Python + psycopg3' },
  { icon: <DbIcon />, label: 'PostgreSQL Database', desc: 'telecom_analytics_v2' },
  { icon: <ArchIcon />, label: 'Advanced SQL Analytics Layer', desc: '194 SQL objects, 7043 rows' },
];

export default function AboutPage() {
  return (
    <Box>
      <Typography variant="h4" sx={{ mb: 1 }}>About This Project</Typography>
      <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
        Full-stack telecom churn analytics platform
      </Typography>

      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Typography variant="h6" sx={{ mb: 2 }}>Architecture Overview</Typography>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, alignItems: 'center' }}>
            {ARCHITECTURE.map((step, i) => (
              <Box key={i} sx={{ display: 'flex', alignItems: 'center', gap: 2, width: '100%', maxWidth: 500 }}>
                <Avatar sx={{ bgcolor: ['primary.main', 'success.main', 'warning.main', 'secondary.main'][i], width: 48, height: 48 }}>
                  {step.icon}
                </Avatar>
                <Box sx={{ flex: 1, textAlign: 'center', py: 1.5, bgcolor: '#f5f7fa', borderRadius: 2, border: '1px solid #e8ecf0' }}>
                  <Typography variant="subtitle2" sx={{ fontWeight: 700 }}>{step.label}</Typography>
                  <Typography variant="caption" color="text.secondary">{step.desc}</Typography>
                </Box>
                {i < ARCHITECTURE.length - 1 && (
                  <Typography variant="h6" color="text.secondary" sx={{ position: 'absolute', ml: 22, mt: 6 }}>↓</Typography>
                )}
              </Box>
            ))}
          </Box>
        </CardContent>
      </Card>

      <Grid container spacing={3}>
        {TECH_STACK.map((stack) => (
          <Grid item xs={12} sm={6} key={stack.category}>
            <Card sx={{ height: '100%' }}>
              <CardContent>
                <Typography variant="h6" sx={{ mb: 2 }}>{stack.category}</Typography>
                <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1 }}>
                  {stack.items.map((item) => (
                    <Chip key={item} label={item} variant="outlined" size="small" />
                  ))}
                </Box>
              </CardContent>
            </Card>
          </Grid>
        ))}
      </Grid>

      <Card sx={{ mt: 3 }}>
        <CardContent>
          <Typography variant="h6" sx={{ mb: 2 }}>Dataset Information</Typography>
          <Grid container spacing={2}>
            <Grid item xs={12} sm={6}>
              <Box sx={{ mb: 1.5 }}>
                <Typography variant="body2" color="text.secondary">Source</Typography>
                <Typography variant="body2" sx={{ fontWeight: 600 }}>IBM Telco Customer Churn Dataset</Typography>
              </Box>
              <Box sx={{ mb: 1.5 }}>
                <Typography variant="body2" color="text.secondary">Records</Typography>
                <Typography variant="body2" sx={{ fontWeight: 600 }}>7,043 customers</Typography>
              </Box>
              <Box sx={{ mb: 1.5 }}>
                <Typography variant="body2" color="text.secondary">Columns</Typography>
                <Typography variant="body2" sx={{ fontWeight: 600 }}>38 fields per customer</Typography>
              </Box>
            </Grid>
            <Grid item xs={12} sm={6}>
              <Box sx={{ mb: 1.5 }}>
                <Typography variant="body2" color="text.secondary">Churn Rate</Typography>
                <Typography variant="body2" sx={{ fontWeight: 600 }}>26.54%</Typography>
              </Box>
              <Box sx={{ mb: 1.5 }}>
                <Typography variant="body2" color="text.secondary">Total Revenue</Typography>
                <Typography variant="body2" sx={{ fontWeight: 600 }}>$16.1M</Typography>
              </Box>
              <Box sx={{ mb: 1.5 }}>
                <Typography variant="body2" color="text.secondary">Database</Typography>
                <Typography variant="body2" sx={{ fontWeight: 600 }}>PostgreSQL 18.4</Typography>
              </Box>
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      <Card sx={{ mt: 3 }}>
        <CardContent>
          <Typography variant="h6" sx={{ mb: 2 }}>Key Features</Typography>
          <Grid container spacing={2}>
            {[
              '10 REST API endpoints with parameterized queries',
              'Clean architecture: routes, SQL, DB connection separated',
              'Interactive dashboard with 4 pages of analytics',
              'Real-time API/DB status monitoring',
              'City drill-down with comparison charts',
              'SQL Explorer showing all queries',
              'Responsive design for all screen sizes',
              'Loading skeletons for smooth UX',
            ].map((feature, i) => (
              <Grid item xs={12} sm={6} key={i}>
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                  <Chip label={`✓`} size="small" color="success" sx={{ minWidth: 24 }} />
                  <Typography variant="body2">{feature}</Typography>
                </Box>
              </Grid>
            ))}
          </Grid>
        </CardContent>
      </Card>
    </Box>
  );
}
