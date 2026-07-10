import { Box, Typography, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper, Chip } from '@mui/material';

const issues = [
  { id: 'ISSUE-01', orderId: 'ORD-1011', issueType: 'Damaged Goods', details: 'Bruised apples received', status: 'Pending Resolve' },
  { id: 'ISSUE-02', orderId: 'ORD-1002', issueType: 'Late Delivery', details: 'Delayed by 2.5 hours', status: 'Resolved' },
];

export default function OrderIssuesPage() {
  return (
    <Box>
      <Typography variant="h5" fontWeight={700} mb={3}>
        Customer Support & Order Issues
      </Typography>

      <TableContainer component={Paper} elevation={1}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Issue ID</TableCell>
              <TableCell>Order ID</TableCell>
              <TableCell>Issue Type</TableCell>
              <TableCell>Details</TableCell>
              <TableCell>Status</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {issues.map((iss) => (
              <TableRow key={iss.id} hover>
                <TableCell sx={{ fontWeight: 600 }}>{iss.id}</TableCell>
                <TableCell>{iss.orderId}</TableCell>
                <TableCell>{iss.issueType}</TableCell>
                <TableCell>{iss.details}</TableCell>
                <TableCell>
                  <Chip
                    label={iss.status}
                    color={iss.status === 'Resolved' ? 'success' : 'error'}
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
