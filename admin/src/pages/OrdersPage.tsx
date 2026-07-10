import { Box, Typography, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper, Chip } from '@mui/material';

const orders = [
  { id: 'ORD-1024', customer: 'Ananya Sharma', farm: 'Santorini Farms', status: 'Delivered', amount: '₹1,250' },
  { id: 'ORD-1023', customer: 'Rahul Verma', farm: 'Green Valley Farms', status: 'Shipped', amount: '₹780' },
  { id: 'ORD-1022', customer: 'Priya Patel', farm: 'Hilltop Orchards', status: 'Pending', amount: '₹2,100' },
  { id: 'ORD-1021', customer: 'Vikram Singh', farm: 'Sunny Poultry', status: 'Accepted', amount: '₹460' },
];

export default function OrdersPage() {
  return (
    <Box>
      <Typography variant="h5" fontWeight={700} mb={3}>
        Order Fulfillment Management
      </Typography>

      <TableContainer component={Paper} elevation={1}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Order ID</TableCell>
              <TableCell>Customer Name</TableCell>
              <TableCell>Farm Entity</TableCell>
              <TableCell>Status</TableCell>
              <TableCell align="right">Amount</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {orders.map((ord) => (
              <TableRow key={ord.id} hover>
                <TableCell sx={{ fontWeight: 600 }}>{ord.id}</TableCell>
                <TableCell>{ord.customer}</TableCell>
                <TableCell>{ord.farm}</TableCell>
                <TableCell>
                  <Chip
                    label={ord.status}
                    color={
                      ord.status === 'Delivered'
                        ? 'success'
                        : ord.status === 'Shipped'
                        ? 'info'
                        : ord.status === 'Pending'
                        ? 'warning'
                        : 'primary'
                    }
                    size="small"
                    variant="outlined"
                  />
                </TableCell>
                <TableCell align="right" sx={{ fontWeight: 500 }}>{ord.amount}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>
    </Box>
  );
}
