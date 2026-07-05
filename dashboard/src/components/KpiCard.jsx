import { Card, CardContent, Typography, Box, Skeleton } from '@mui/material';

export default function KpiCard({ title, value, icon, color = '#1976d2', subtitle, trend, loading }) {
  if (loading) {
    return (
      <Card sx={{ height: '100%' }}>
        <CardContent>
          <Skeleton variant="text" width="60%" height={20} />
          <Skeleton variant="text" width="40%" height={40} />
          <Skeleton variant="text" width="80%" height={16} />
        </CardContent>
      </Card>
    );
  }

  return (
    <Card sx={{ height: '100%' }}>
      <CardContent>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
          <Box sx={{ flex: 1 }}>
            <Typography variant="body2" color="text.secondary" gutterBottom sx={{ fontWeight: 500, textTransform: 'uppercase', letterSpacing: '0.05em', fontSize: '0.7rem' }}>
              {title}
            </Typography>
            <Typography variant="h4" sx={{ fontWeight: 700, color, lineHeight: 1.1, mb: 0.5 }}>
              {value}
            </Typography>
            {subtitle && (
              <Typography variant="caption" color="text.secondary" sx={{ display: 'block', lineHeight: 1.2 }}>
                {subtitle}
              </Typography>
            )}
            {trend && (
              <Typography variant="caption" sx={{ color: trend.startsWith('+') ? '#2e7d32' : trend.startsWith('-') ? '#d32f2f' : 'text.secondary', fontWeight: 600, display: 'block', mt: 0.5 }}>
                {trend}
              </Typography>
            )}
          </Box>
          <Box sx={{
            p: 1.5, borderRadius: 2.5,
            backgroundColor: `${color}12`, color,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            {icon}
          </Box>
        </Box>
      </CardContent>
    </Card>
  );
}
