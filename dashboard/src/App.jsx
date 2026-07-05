import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { ThemeProvider, CssBaseline } from '@mui/material';
import theme from './theme';
import Layout from './components/Layout';
import DashboardPage from './pages/DashboardPage';
import CustomersPage from './pages/CustomersPage';
import ChurnPage from './pages/ChurnPage';
import RevenuePage from './pages/RevenuePage';
import SqlExplorerPage from './pages/SqlExplorerPage';
import AboutPage from './pages/AboutPage';

export default function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <BrowserRouter>
        <Routes>
          <Route element={<Layout />}>
            <Route path="/" element={<DashboardPage />} />
            <Route path="/customers" element={<CustomersPage />} />
            <Route path="/churn" element={<ChurnPage />} />
            <Route path="/revenue" element={<RevenuePage />} />
            <Route path="/sql-explorer" element={<SqlExplorerPage />} />
            <Route path="/about" element={<AboutPage />} />
          </Route>
        </Routes>
      </BrowserRouter>
    </ThemeProvider>
  );
}
