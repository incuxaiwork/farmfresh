import { Box, Typography, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper, Chip } from '@mui/material';

const payouts = [
  { id: 'PAY-001', farm: 'Santorini Farms', period: 'July 1 - July 7', amount: '₹14,500', status: 'Transferred' },
  { id: 'PAY-002', farm: 'Green Valley Farms', period: 'July 1 - July 7', amount: '₹8,240', status: 'Pending' },
];

export default function PayoutsPage() {
  return (
    <Box>
      <Typography variant="h5" fontWeight={700} mb={3}>
        Farmer Payout settlements
      </Typography>

      <TableContainer component={Paper} elevation={1}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Payout ID</TableCell>
              <TableCell>Farm Entity</TableCell>
              <TableCell>Billing Period</TableCell>
              <TableCell>Settlement Amount</TableCell>
              <TableCell>Status</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {payouts.map((pay) => (
              <TableRow key={pay.id} hover>
                <TableCell sx={{ fontWeight: 600 }}>{pay.id}</TableCell>
                <TableCell>{pay.farm}</TableCell>
                <TableCell>{pay.period}</TableCell>
                <TableCell>{pay.amount}</TableCell>
                <TableCell>
                  <Chip
                    label={pay.status}
                    color={pay.status === 'Transferred' ? 'success' : 'warning'}
                    size="small"
                    variant="outlined"
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
