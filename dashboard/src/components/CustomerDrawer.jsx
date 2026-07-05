import { useState, useEffect } from 'react';
import {
  Drawer, Box, Typography, IconButton, Divider, Chip, Grid, CircularProgress,
} from '@mui/material';
import { Close as CloseIcon } from '@mui/icons-material';
import { getCustomer } from '../api';

const DETAIL_FIELDS = [
  { label: 'Gender', key: 'gender' },
  { label: 'Senior Citizen', key: 'senior_citizen' },
  { label: 'Partner', key: 'partner' },
  { label: 'Dependents', key: 'dependents' },
  { label: 'Tenure (months)', key: 'tenure_months' },
  { label: 'Contract', key: 'contract' },
  { label: 'Phone Service', key: 'phone_service' },
  { label: 'Multiple Lines', key: 'multiple_lines' },
  { label: 'Internet Service', key: 'internet_service' },
  { label: 'Online Security', key: 'online_security' },
  { label: 'Tech Support', key: 'tech_support' },
  { label: 'Payment Method', key: 'payment_method' },
  { label: 'Monthly Charges', key: 'monthly_charges', format: (v) => `$${Number(v).toFixed(2)}` },
  { label: 'Total Charges', key: 'total_charges', format: (v) => `$${Number(v).toFixed(2)}` },
  { label: 'CLTV', key: 'cltv' },
  { label: 'Churn Score', key: 'churn_score' },
  { label: 'Churn Reason', key: 'churn_reason' },
];

export default function CustomerDrawer({ customerId, onClose }) {
  const [customer, setCustomer] = useState(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!customerId) return;
    setLoading(true);
    getCustomer(customerId)
      .then((res) => setCustomer(res.data))
      .catch(() => setCustomer(null))
      .finally(() => setLoading(false));
  }, [customerId]);

  return (
    <Drawer anchor="right" open={!!customerId} onClose={onClose} PaperProps={{ sx: { width: { xs: '100%', sm: 440 }, p: 2 } }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 1 }}>
        <Typography variant="h6">Customer Details</Typography>
        <IconButton onClick={onClose}><CloseIcon /></IconButton>
      </Box>
      <Divider sx={{ mb: 2 }} />

      {loading ? (
        <Box sx={{ display: 'flex', justifyContent: 'center', mt: 6 }}><CircularProgress /></Box>
      ) : customer ? (
        <Box>
          <Box sx={{ display: 'flex', gap: 1, mb: 2, flexWrap: 'wrap' }}>
            <Chip label={customer.customer_id} color="primary" variant="outlined" />
            <Chip label={customer.churn_label === 'Yes' ? 'Churned' : 'Active'} color={customer.churn_label === 'Yes' ? 'error' : 'success'} size="small" />
            <Chip label={customer.contract} size="small" variant="outlined" />
            <Chip label={customer.internet_service} size="small" variant="outlined" />
          </Box>
          <Typography variant="subtitle2" color="text.secondary" gutterBottom>
            {customer.city}, {customer.state} {customer.zip_code}
          </Typography>
          <Grid container spacing={1.5} sx={{ mt: 1 }}>
            {DETAIL_FIELDS.map((field) => (
              <Grid item xs={6} key={field.key}>
                <Typography variant="caption" color="text.secondary">{field.label}</Typography>
                <Typography variant="body2" sx={{ fontWeight: 500 }}>
                  {field.format ? field.format(customer[field.key]) : customer[field.key] ?? '-'}
                </Typography>
              </Grid>
            ))}
          </Grid>
        </Box>
      ) : (
        <Typography color="text.secondary" sx={{ mt: 4, textAlign: 'center' }}>Customer not found</Typography>
      )}
    </Drawer>
  );
}
