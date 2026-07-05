import { Box, Card, CardContent, Skeleton } from '@mui/material';

export function SkeletonCard({ height = 300 }) {
  return (
    <Card sx={{ height: '100%' }}>
      <CardContent>
        <Skeleton variant="text" width="50%" height={28} sx={{ mb: 2 }} />
        <Skeleton variant="rectangular" height={height - 80} sx={{ borderRadius: 1 }} />
      </CardContent>
    </Card>
  );
}

export function SkeletonKpi() {
  return (
    <Card sx={{ height: '100%' }}>
      <CardContent>
        <Skeleton variant="text" width="60%" height={16} />
        <Skeleton variant="text" width="40%" height={40} sx={{ my: 1 }} />
        <Skeleton variant="text" width="80%" height={14} />
      </CardContent>
    </Card>
  );
}

export function SkeletonTable({ rows = 5, cols = 5 }) {
  return (
    <Box>
      {Array.from({ length: rows }).map((_, i) => (
        <Box key={i} sx={{ display: 'flex', gap: 2, mb: 1.5, px: 2 }}>
          {Array.from({ length: cols }).map((_, j) => (
            <Skeleton key={j} variant="text" height={35} sx={{ flex: 1 }} />
          ))}
        </Box>
      ))}
    </Box>
  );
}
