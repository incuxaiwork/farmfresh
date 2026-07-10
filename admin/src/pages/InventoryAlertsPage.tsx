import { Box, Typography, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper, Chip } from '@mui/material';

const alerts = [
  { id: '1', product: 'Artisanal Goat Cheese', stock: '0 units', farm: 'Vermont Farms', severity: 'Critical' },
  { id: '2', product: 'Sweet Avocados', stock: '2 kg left', farm: 'Valley Orchards', severity: 'Warning' },
];

export default function InventoryAlertsPage() {
  return (
    <Box>
      <Typography variant="h5" fontWeight={700} mb={3}>
        Inventory Stock Alerts
      </Typography>

      <TableContainer component={Paper} elevation={1}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Product</TableCell>
              <TableCell>Current Stock</TableCell>
              <TableCell>Farm Partner</TableCell>
              <TableCell>Severity</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {alerts.map((alert) => (
              <TableRow key={alert.id} hover>
                <TableCell sx={{ fontWeight: 600 }}>{alert.product}</TableCell>
                <TableCell>{alert.stock}</TableCell>
                <TableCell>{alert.farm}</TableCell>
                <TableCell>
                  <Chip
                    label={alert.severity}
                    color={alert.severity === 'Critical' ? 'error' : 'warning'}
                    size="small"
                  />
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>
    </Box>
  );
}
