import { useState } from 'react';
import {
  Box, Typography, Card, CardContent, Tabs, Tab, Paper, Chip,
  Table, TableBody, TableCell, TableContainer, TableHead, TableRow,
} from '@mui/material';
import { Code as CodeIcon, Storage as DbIcon } from '@mui/icons-material';

const SQL_QUERIES = [
  {
    title: 'Dashboard KPIs',
    description: 'Aggregated statistics for the executive dashboard',
    sql: `SELECT
    COUNT(*) AS total_customers,
    ROUND(AVG(monthly_charges), 2) AS avg_monthly_charge,
    ROUND(SUM(total_charges), 2) AS total_revenue,
    ROUND(
        SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*), 2
    ) AS churn_rate,
    SUM(CASE WHEN churn_label = 'Yes' THEN 1 ELSE 0 END) AS total_churned,
    SUM(CASE WHEN churn_label = 'No' THEN 1 ELSE 0 END) AS active_customers
FROM telecom_churn;`,
    endpoint: 'GET /api/dashboard',
  },
  {
    title: 'Churn Summary',
    description: 'Customer count and percentage by churn label',
    sql: `SELECT
    churn_label,
    COUNT(*) AS count,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM telecom_churn), 2
    ) AS percentage
FROM telecom_churn
GROUP BY churn_label
ORDER BY churn_label;`,
    endpoint: 'GET /api/churn',
  },
  {
    title: 'Contract Distribution',
    description: 'Customer count grouped by contract type',
    sql: `SELECT
    contract,
    COUNT(*) AS customers
FROM telecom_churn
GROUP BY contract
ORDER BY customers DESC;`,
    endpoint: 'GET /api/contracts',
  },
  {
    title: 'Top 10 Cities by Revenue',
    description: 'Cities ranked by total customer revenue',
    sql: `SELECT
    city,
    COUNT(*) AS customers,
    ROUND(SUM(total_charges), 2) AS total_revenue
FROM telecom_churn
WHERE total_charges IS NOT NULL
GROUP BY city
ORDER BY total_revenue DESC
LIMIT 10;`,
    endpoint: 'GET /api/revenue',
  },
  {
    title: 'Monthly Charges Distribution',
    description: 'Statistical summary of monthly charges',
    sql: `SELECT
    ROUND(AVG(monthly_charges)::numeric, 2) AS average,
    ROUND(MIN(monthly_charges)::numeric, 2) AS minimum,
    ROUND(MAX(monthly_charges)::numeric, 2) AS maximum,
    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP
            (ORDER BY monthly_charges)::numeric, 2
    ) AS median
FROM telecom_churn;`,
    endpoint: 'GET /api/monthlycharges',
  },
  {
    title: 'Top Churn Reasons',
    description: 'Most frequent reasons for customer churn',
    sql: `SELECT
    churn_reason,
    COUNT(*) AS count
FROM telecom_churn
WHERE churn_label = 'Yes'
  AND churn_reason IS NOT NULL
  AND churn_reason != ''
GROUP BY churn_reason
ORDER BY count DESC
LIMIT 15;`,
    endpoint: 'GET /api/churnreasons',
  },
  {
    title: 'Internet Service Breakdown',
    description: 'Customer distribution by internet service type',
    sql: `SELECT
    internet_service,
    COUNT(*) AS customers
FROM telecom_churn
GROUP BY internet_service
ORDER BY customers DESC;`,
    endpoint: 'GET /api/internet',
  },
  {
    title: 'Paginated Customer List',
    description: 'Full customer data with LIMIT/OFFSET pagination',
    sql: `SELECT customer_id, city, state, monthly_charges, churn_label
FROM telecom_churn
ORDER BY customer_id
LIMIT $1 OFFSET $2;`,
    endpoint: 'GET /api/customers?page=1&limit=20',
  },
  {
    title: 'Customer Detail Lookup',
    description: 'Complete customer record by ID',
    sql: `SELECT *
FROM telecom_churn
WHERE customer_id = $1;`,
    endpoint: 'GET /api/customer?id=0002-ORFBO',
  },
  {
    title: 'Top Cities by Customer Count',
    description: 'Cities ranked by subscriber base',
    sql: `SELECT
    city,
    COUNT(*) AS customers
FROM telecom_churn
GROUP BY city
ORDER BY customers DESC
LIMIT 10;`,
    endpoint: 'GET /api/topcities',
  },
];

export default function SqlExplorerPage() {
  const [selectedTab, setSelectedTab] = useState(0);
  const query = SQL_QUERIES[selectedTab];

  return (
    <Box>
      <Typography variant="h4" sx={{ mb: 1 }}>SQL Explorer</Typography>
      <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
        View the SQL queries powering each visualization
      </Typography>

      <Card>
        <Tabs
          value={selectedTab}
          onChange={(_, v) => setSelectedTab(v)}
          variant="scrollable"
          scrollButtons="auto"
          sx={{ borderBottom: 1, borderColor: 'divider', px: 2, pt: 1 }}
        >
          {SQL_QUERIES.map((q, i) => (
            <Tab key={i} label={q.title} icon={<CodeIcon />} iconPosition="start" sx={{ textTransform: 'none', minHeight: 48 }} />
          ))}
        </Tabs>

        <CardContent>
          <Box sx={{ mb: 2, display: 'flex', gap: 1, alignItems: 'center', flexWrap: 'wrap' }}>
            <Chip icon={<DbIcon />} label={query.endpoint} color="primary" variant="outlined" size="small" />
            <Typography variant="body2" color="text.secondary">{query.description}</Typography>
          </Box>

          <Paper sx={{ p: 2, bgcolor: '#1e1e1e', overflow: 'auto' }}>
            <pre style={{ margin: 0, color: '#d4d4d4', fontFamily: '"Fira Code", "Consolas", monospace', fontSize: '0.85rem', lineHeight: 1.6, whiteSpace: 'pre-wrap' }}>
              {query.sql}
            </pre>
          </Paper>
        </CardContent>
      </Card>

      <Card sx={{ mt: 3 }}>
        <CardContent>
          <Typography variant="h6" sx={{ mb: 2 }}>Database Schema</Typography>
          <TableContainer>
            <Table size="small">
              <TableHead>
                <TableRow>
                  <TableCell sx={{ fontWeight: 600, bgcolor: '#f5f7fa' }}>Table</TableCell>
                  <TableCell sx={{ fontWeight: 600, bgcolor: '#f5f7fa' }}>Description</TableCell>
                  <TableCell sx={{ fontWeight: 600, bgcolor: '#f5f7fa' }}>Rows</TableCell>
                  <TableCell sx={{ fontWeight: 600, bgcolor: '#f5f7fa' }}>Indexes</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                <TableRow>
                  <TableCell sx={{ fontFamily: 'monospace', fontWeight: 600 }}>telecom_churn</TableCell>
                  <TableCell>Main customer churn dataset</TableCell>
                  <TableCell>7,043</TableCell>
                  <TableCell>13+</TableCell>
                </TableRow>
              </TableBody>
            </Table>
          </TableContainer>
        </CardContent>
      </Card>
    </Box>
  );
}
