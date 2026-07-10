import { Box, Card, Typography, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper, Chip } from '@mui/material';

const products = [
  { id: '1', name: 'Organic Red Tomatoes', farm: 'Santorini Farms', stock: '120 kg', price: '₹120/kg' },
  { id: '2', name: 'Fresh Spinach', farm: 'Green Valley Farms', stock: '45 bundles', price: '₹40/bundle' },
  { id: '3', name: 'Red Gala Apples', farm: 'Hilltop Orchards', stock: '210 kg', price: '₹180/kg' },
  { id: '4', name: 'Artisanal Goat Cheese', farm: 'Vermont Farms', stock: '0 units', price: '₹450/unit' },
];

export default function ProductsPage() {
  return (
    <Box>
      <Typography variant="h5" fontWeight={700} mb={3}>
        Product Catalog Management
      </Typography>

      <TableContainer component={Paper} elevation={1}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Product Name</TableCell>
              <TableCell>Farm Origin</TableCell>
              <TableCell>Stock Level</TableCell>
              <TableCell>Price Indicator</TableCell>
              <TableCell>Status</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {products.map((prod) => (
              <TableRow key={prod.id} hover>
                <TableCell sx={{ fontWeight: 600 }}>{prod.name}</TableCell>
                <TableCell>{prod.farm}</TableCell>
                <TableCell>{prod.stock}</TableCell>
                <TableCell>{prod.price}</TableCell>
                <TableCell>
                  <Chip
                    label={prod.stock === '0 units' ? 'Out of Stock' : 'Active'}
                    color={prod.stock === '0 units' ? 'error' : 'success'}
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
