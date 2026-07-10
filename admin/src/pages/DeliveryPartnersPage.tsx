import { Box, Typography, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper, Chip } from '@mui/material';

const partners = [
  { id: 'DP-01', name: 'Amit Kumar', phone: '+91 98765 43210', vehicle: 'Two-Wheeler', status: 'On Duty' },
  { id: 'DP-02', name: 'Sandeep Singh', phone: '+91 99887 76655', vehicle: 'Electric Scooty', status: 'Off Duty' },
];

export default function DeliveryPartnersPage() {
  return (
    <Box>
      <Typography variant="h5" fontWeight={700} mb={3}>
        Delivery Fleet Management
      </Typography>

      <TableContainer component={Paper} elevation={1}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Partner ID</TableCell>
              <TableCell>Driver Name</TableCell>
              <TableCell>Phone</TableCell>
              <TableCell>Vehicle Type</TableCell>
              <TableCell>Status</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {partners.map((partner) => (
              <TableRow key={partner.id} hover>
                <TableCell sx={{ fontWeight: 600 }}>{partner.id}</TableCell>
                <TableCell>{partner.name}</TableCell>
                <TableCell>{partner.phone}</TableCell>
                <TableCell>{partner.vehicle}</TableCell>
                <TableCell>
                  <Chip
                    label={partner.status}
                    color={partner.status === 'On Duty' ? 'success' : 'default'}
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
