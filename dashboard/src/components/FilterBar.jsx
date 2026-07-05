import { Box, Card, CardContent, TextField, MenuItem, InputAdornment, Button } from '@mui/material';
import { FilterList as FilterIcon, Clear as ClearIcon } from '@mui/icons-material';

const FILTER_OPTIONS = {
  state: { label: 'State', options: ['California'] },
  contract: { label: 'Contract', options: ['Month-to-month', 'One year', 'Two year'] },
  internet_service: { label: 'Internet Service', options: ['DSL', 'Fiber optic', 'No'] },
  churn_label: { label: 'Churn', options: ['Yes', 'No'] },
  gender: { label: 'Gender', options: ['Male', 'Female'] },
};

export default function FilterBar({ filters, onFilterChange, onClear }) {
  const hasFilters = Object.values(filters).some((v) => v !== '');

  return (
    <Card sx={{ mb: 3 }}>
      <CardContent sx={{ py: '12px !important', '&:last-child': { pb: '12px !important' } }}>
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5, flexWrap: 'wrap' }}>
          <FilterIcon color="primary" sx={{ mr: 0.5 }} />
          {Object.entries(FILTER_OPTIONS).map(([key, { label, options }]) => (
            <TextField
              key={key}
              select
              size="small"
              label={label}
              value={filters[key] || ''}
              onChange={(e) => onFilterChange(key, e.target.value)}
              sx={{ minWidth: 140 }}
            >
              <MenuItem value="">All</MenuItem>
              {options.map((opt) => (
                <MenuItem key={opt} value={opt}>{opt}</MenuItem>
              ))}
            </TextField>
          ))}
          {hasFilters && (
            <Button size="small" startIcon={<ClearIcon />} onClick={onClear} color="inherit">
              Clear All
            </Button>
          )}
        </Box>
      </CardContent>
    </Card>
  );
}
