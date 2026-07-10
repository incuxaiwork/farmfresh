import { Box, Typography, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper, Chip } from '@mui/material';

const coupons = [
  { id: '1', code: 'SAVE50', discount: '50% OFF', description: '50% off on first farm purchase', status: 'Active' },
  { id: '2', code: 'FREEDEL', discount: 'Free Delivery', description: 'Free shipping on orders above ₹1600', status: 'Active' },
];

export default function CouponsPage() {
  return (
    <Box>
      <Typography variant="h5" fontWeight={700} mb={3}>
        Discount Coupons & Promotions
      </Typography>

      <TableContainer component={Paper} elevation={1}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Promo Code</TableCell>
              <TableCell>Discount Tier</TableCell>
              <TableCell>Description</TableCell>
              <TableCell>Status</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {coupons.map((coupon) => (
              <TableRow key={coupon.id} hover>
                <TableCell sx={{ fontWeight: 700, color: 'green' }}>{coupon.code}</TableCell>
                <TableCell>{coupon.discount}</TableCell>
                <TableCell>{coupon.description}</TableCell>
                <TableCell>
                  <Chip label={coupon.status} color="success" size="small" variant="outlined" />
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>
    </Box>
  );
}
