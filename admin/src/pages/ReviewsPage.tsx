import { Box, Typography, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper, Rating } from '@mui/material';

const reviews = [
  { id: 'REV-01', user: 'Ananya S.', product: 'Organic Red Tomatoes', rating: 5, comment: 'Absolutely fresh and sweet!' },
  { id: 'REV-02', user: 'Rohit V.', product: 'Fresh Spinach', rating: 4, comment: 'Clean leaves, great packaging.' },
];

export default function ReviewsPage() {
  return (
    <Box>
      <Typography variant="h5" fontWeight={700} mb={3}>
        Product Reviews & Feedback
      </Typography>

      <TableContainer component={Paper} elevation={1}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Review ID</TableCell>
              <TableCell>Customer</TableCell>
              <TableCell>Product</TableCell>
              <TableCell>Rating</TableCell>
              <TableCell>Comment</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {reviews.map((rev) => (
              <TableRow key={rev.id} hover>
                <TableCell sx={{ fontWeight: 600 }}>{rev.id}</TableCell>
                <TableCell>{rev.user}</TableCell>
                <TableCell>{rev.product}</TableCell>
                <TableCell>
                  <Rating value={rev.rating} readOnly size="small" />
                </TableCell>
                <TableCell>{rev.comment}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>
    </Box>
  );
}
