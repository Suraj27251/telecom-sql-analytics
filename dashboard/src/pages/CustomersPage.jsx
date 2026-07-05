import { useState, useEffect } from 'react';
import {
  Box, Typography, Card, CardContent, Table, TableBody, TableCell,
  TableContainer, TableHead, TableRow, TablePagination, TextField,
  InputAdornment, Chip, IconButton, TableSortLabel, Grid,
} from '@mui/material';
import { Search as SearchIcon, Visibility as ViewIcon } from '@mui/icons-material';
import { getCustomers } from '../api';
import CustomerDrawer from '../components/CustomerDrawer';
import { SkeletonTable } from '../components/Skeletons';

const COLUMNS = [
  { id: 'customer_id', label: 'Customer ID', sortable: true },
  { id: 'city', label: 'City', sortable: true },
  { id: 'state', label: 'State', sortable: true },
  { id: 'monthly_charges', label: 'Monthly Charges', sortable: true, format: (v) => `$${Number(v).toFixed(2)}` },
  { id: 'churn_label', label: 'Status', sortable: true },
];

export default function CustomersPage() {
  const [customers, setCustomers] = useState([]);
  const [pagination, setPagination] = useState({ page: 0, limit: 20, total: 0 });
  const [search, setSearch] = useState('');
  const [order, setOrder] = useState('asc');
  const [orderBy, setOrderBy] = useState('customer_id');
  const [selectedId, setSelectedId] = useState(null);
  const [loading, setLoading] = useState(true);

  const fetchCustomers = (page = 1, limit = 20) => {
    setLoading(true);
    getCustomers(page, limit)
      .then((res) => {
        setCustomers(res.data.customers || []);
        setPagination({
          page: res.data.pagination.page - 1,
          limit: res.data.pagination.limit,
          total: res.data.pagination.total,
        });
      })
      .catch(console.error)
      .finally(() => setLoading(false));
  };

  useEffect(() => { fetchCustomers(1, 20); }, []);

  const handlePageChange = (_, newPage) => fetchCustomers(newPage + 1, pagination.limit);
  const handleRowsPerPage = (e) => fetchCustomers(1, parseInt(e.target.value, 10));

  const handleSort = (col) => {
    const isAsc = orderBy === col && order === 'asc';
    setOrder(isAsc ? 'desc' : 'asc');
    setOrderBy(col);
  };

  const sorted = [...customers].sort((a, b) => {
    const va = a[orderBy] ?? '';
    const vb = b[orderBy] ?? '';
    const cmp = typeof va === 'string' ? va.localeCompare(vb) : Number(va) - Number(vb);
    return order === 'asc' ? cmp : -cmp;
  });

  const filtered = sorted.filter((c) => {
    if (!search) return true;
    const q = search.toLowerCase();
    return (c.customer_id?.toLowerCase().includes(q)) || (c.city?.toLowerCase().includes(q));
  });

  return (
    <Box>
      <Typography variant="h4" sx={{ mb: 1 }}>Customers</Typography>
      <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>Explore and search the full customer database</Typography>

      <Card sx={{ mb: 2 }}>
        <CardContent sx={{ pb: '16px !important' }}>
          <Grid container spacing={2} alignItems="center">
            <Grid item xs={12} md={8}>
              <TextField
                fullWidth size="small" placeholder="Search by Customer ID or City..."
                value={search} onChange={(e) => setSearch(e.target.value)}
                InputProps={{ startAdornment: <InputAdornment position="start"><SearchIcon /></InputAdornment> }}
              />
            </Grid>
            <Grid item xs={12} md={4}>
              <Typography variant="body2" color="text.secondary" sx={{ textAlign: { md: 'right' } }}>
                Showing {filtered.length} of {pagination.total.toLocaleString()} customers
              </Typography>
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      <Card>
        <TableContainer sx={{ maxHeight: 600 }}>
          <Table size="small" stickyHeader>
            <TableHead>
              <TableRow>
                {COLUMNS.map((col) => (
                  <TableCell key={col.id} sx={{ fontWeight: 600, bgcolor: '#f5f7fa' }}>
                    {col.sortable ? (
                      <TableSortLabel active={orderBy === col.id} direction={orderBy === col.id ? order : 'asc'} onClick={() => handleSort(col.id)}>
                        {col.label}
                      </TableSortLabel>
                    ) : col.label}
                  </TableCell>
                ))}
                <TableCell sx={{ fontWeight: 600, bgcolor: '#f5f7fa' }}>Details</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {loading ? (
                <TableRow><TableCell colSpan={6}><SkeletonTable rows={8} cols={5} /></TableCell></TableRow>
              ) : filtered.length === 0 ? (
                <TableRow><TableCell colSpan={6} align="center" sx={{ py: 6 }}>No customers found</TableCell></TableRow>
              ) : (
                filtered.map((c) => (
                  <TableRow key={c.customer_id} hover sx={{ cursor: 'pointer' }} onClick={() => setSelectedId(c.customer_id)}>
                    <TableCell>
                      <Typography variant="body2" sx={{ fontWeight: 600, fontFamily: 'monospace' }}>{c.customer_id}</Typography>
                    </TableCell>
                    <TableCell>{c.city}</TableCell>
                    <TableCell>{c.state}</TableCell>
                    <TableCell sx={{ fontWeight: 600 }}>{COLUMNS[3].format(c.monthly_charges)}</TableCell>
                    <TableCell>
                      <Chip label={c.churn_label === 'Yes' ? 'Churned' : 'Active'} color={c.churn_label === 'Yes' ? 'error' : 'success'} size="small" variant="outlined" />
                    </TableCell>
                    <TableCell>
                      <IconButton size="small" onClick={(e) => { e.stopPropagation(); setSelectedId(c.customer_id); }}>
                        <ViewIcon fontSize="small" />
                      </IconButton>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </TableContainer>
        <TablePagination component="div" count={pagination.total} page={pagination.page} onPageChange={handlePageChange}
          rowsPerPage={pagination.limit} onRowsPerPageChange={handleRowsPerPage} rowsPerPageOptions={[10, 20, 50]} />
      </Card>

      <CustomerDrawer customerId={selectedId} onClose={() => setSelectedId(null)} />
    </Box>
  );
}
