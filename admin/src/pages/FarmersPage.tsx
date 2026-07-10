import { Box, Typography, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper, Chip } from '@mui/material';

const farmers = [
  { id: 'F-001', name: 'John Miller', farmName: 'Santorini Farms', email: 'john@santorini.com', status: 'Approved' },
  { id: 'F-002', name: 'Sarah Green', farmName: 'Green Valley Farms', email: 'sarah@greenvalley.com', status: 'Approved' },
  { id: 'F-003', name: 'Robert Hill', farmName: 'Hilltop Orchards', email: 'robert@hilltop.com', status: 'Pending Review' },
];

export default function FarmersPage() {
  return (
    <Box>
      <Typography variant="h5" fontWeight={700} mb={3}>
        Farmer Partners Registry
      </Typography>

      <TableContainer component={Paper} elevation={1}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Farmer ID</TableCell>
              <TableCell>Farmer Name</TableCell>
              <TableCell>Farm Name</TableCell>
              <TableCell>Email</TableCell>
              <TableCell>Verification Status</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {farmers.map((farm) => (
              <TableRow key={farm.id} hover>
                <TableCell sx={{ fontWeight: 600 }}>{farm.id}</TableCell>
                <TableCell>{farm.name}</TableCell>
                <TableCell>{farm.farmName}</TableCell>
                <TableCell>{farm.email}</TableCell>
                <TableCell>
                  <Chip
                    label={farm.status}
                    color={farm.status === 'Approved' ? 'success' : 'warning'}
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
