import { Box, Typography, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper, Chip } from '@mui/material';

const categories = [
  { id: '1', name: 'Vegetables', count: '45 products', emoji: '🥦' },
  { id: '2', name: 'Fruits', count: '32 products', emoji: '🍎' },
  { id: '3', name: 'Dairy', count: '18 products', emoji: '🧀' },
  { id: '4', name: 'Grains', count: '12 products', emoji: '🌾' },
];

export default function CategoriesPage() {
  return (
    <Box>
      <Typography variant="h5" fontWeight={700} mb={3}>
        Product Categories
      </Typography>

      <TableContainer component={Paper} elevation={1}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Icon</TableCell>
              <TableCell>Category Name</TableCell>
              <TableCell>Total Products</TableCell>
              <TableCell>Status</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {categories.map((cat) => (
              <TableRow key={cat.id} hover>
                <TableCell sx={{ fontSize: 24 }}>{cat.emoji}</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>{cat.name}</TableCell>
                <TableCell>{cat.count}</TableCell>
                <TableCell>
                  <Chip label="Active" color="success" size="small" variant="outlined" />
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>
    </Box>
  );
}
