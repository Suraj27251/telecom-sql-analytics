import axios from 'axios';

const api = axios.create({
  baseURL: '/api',
  timeout: 15000,
  headers: { 'Content-Type': 'application/json' },
});

export const getDashboard = () => api.get('/dashboard');
export const getChurn = () => api.get('/churn');
export const getContracts = () => api.get('/contracts');
export const getTopCities = () => api.get('/topcities');
export const getRevenue = () => api.get('/revenue');
export const getInternet = () => api.get('/internet');
export const getMonthlyCharges = () => api.get('/monthlycharges');
export const getChurnReasons = () => api.get('/churnreasons');
export const getCustomers = (page = 1, limit = 20) =>
  api.get('/customers', { params: { page, limit } });
export const getCustomer = (id) => api.get('/customer', { params: { id } });

export default api;
