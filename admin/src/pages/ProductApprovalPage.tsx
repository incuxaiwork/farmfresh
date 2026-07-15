import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { adminService } from '../services/admin.service';
import type { Product } from '../types';
import {
  Box, Typography, Table, TableBody, TableCell, TableContainer, TableHead, TableRow,
  Paper, Button, Dialog, DialogTitle, DialogContent, DialogActions, Stack, Snackbar, Alert,
  Card, CardContent, Chip, Divider,
} from '@mui/material';
import PendingActionsIcon from '@mui/icons-material/PendingActions';
import VisibilityIcon from '@mui/icons-material/Visibility';
import CheckCircleOutlineIcon from '@mui/icons-material/CheckCircleOutline';
import CancelOutlinedIcon from '@mui/icons-material/CancelOutlined';
import ImageIcon from '@mui/icons-material/Image';

export default function ProductApprovalPage() {
  const queryClient = useQueryClient();
  const [detailProduct, setDetailProduct] = useState<Product | null>(null);
  const [detailOpen, setDetailOpen] = useState(false);
  const [rejectOpen, setRejectOpen] = useState(false);
  const [rejectReason, setRejectReason] = useState('');
  const [rejectTarget, setRejectTarget] = useState<Product | null>(null);
  const [confirmApproveOpen, setConfirmApproveOpen] = useState(false);
  const [approveTarget, setApproveTarget] = useState<Product | null>(null);
  const [snack, setSnack] = useState<{ open: boolean; message: string; severity: 'success' | 'error' }>({
    open: false, message: '', severity: 'success'
  });

  const { data, isLoading } = useQuery({
    queryKey: ['products-pending-approval'],
    queryFn: () => adminService.getProducts({ status: 'PENDING_APPROVAL', limit: 100 }),
  });
  const products = data?.items ?? [];

  const invalidate = () => queryClient.invalidateQueries({ queryKey: ['products-pending-approval'] });

  const updateStatusMutation = useMutation({
    mutationFn: ({ id, status }: { id: string; status: string }) => adminService.updateProductStatus(id, status),
    onSuccess: (_, variables) => {
      invalidate();
      setSnack({ open: true, message: `Product ${variables.status.toLowerCase()} successfully`, severity: 'success' });
    }
  });

  /* ── Handlers ── */
  const handleViewDetails = (product: Product) => {
    setDetailProduct(product);
    setDetailOpen(true);
  };

  const handleApproveClick = (product: Product) => {
    setApproveTarget(product);
    setConfirmApproveOpen(true);
  };

  const handleApproveConfirm = () => {
    if (approveTarget) {
      updateStatusMutation.mutate({ id: approveTarget.id, status: 'APPROVED' });
    }
    setConfirmApproveOpen(false);
    setApproveTarget(null);
    setDetailOpen(false);
    setDetailProduct(null);
  };

  const handleRejectClick = (product: Product) => {
    setRejectTarget(product);
    setRejectReason('');
    setRejectOpen(true);
  };

  const handleRejectConfirm = () => {
    if (rejectTarget) {
      updateStatusMutation.mutate({ id: rejectTarget.id, status: 'REJECTED' });
    }
    setRejectOpen(false);
    setRejectTarget(null);
    setDetailOpen(false);
    setDetailProduct(null);
  };

  return (
    <Box>
      {/* ── Summary stat card ── */}
      <Card
        sx={{
          mb: 3,
          background: 'linear-gradient(135deg, #0A2540 0%, #1a3a5c 100%)',
          color: '#fff',
          border: 'none',
        }}
      >
        <CardContent sx={{ display: 'flex', alignItems: 'center', gap: 2, py: 2.5, '&:last-child': { pb: 2.5 } }}>
          <Box
            sx={{
              width: 48,
              height: 48,
              borderRadius: '12px',
              bgcolor: 'rgba(76,175,80,0.2)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <PendingActionsIcon sx={{ fontSize: 28, color: '#4CAF50' }} />
          </Box>
          <Box>
            <Typography variant="h4" fontWeight={700} sx={{ lineHeight: 1.2 }}>
              {products.length}
            </Typography>
            <Typography variant="body2" sx={{ color: 'rgba(255,255,255,0.7)', mt: 0.25 }}>
              products awaiting approval
            </Typography>
          </Box>
        </CardContent>
      </Card>

      {/* ── Header ── */}
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Typography variant="h5" fontWeight={700}>
          Product Approval
        </Typography>
        <Chip
          label={`${products.length} pending`}
          size="small"
          sx={{
            bgcolor: '#FFF3E0',
            color: '#E65100',
            fontWeight: 600,
          }}
        />
      </Box>

      {/* ── Table ── */}
      <TableContainer component={Paper} elevation={0}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Product Name</TableCell>
              <TableCell>Category</TableCell>
              <TableCell align="right">Price (₹)</TableCell>
              <TableCell align="right">Stock</TableCell>
              <TableCell>Farmer</TableCell>
              <TableCell>Submitted</TableCell>
              <TableCell align="center">Actions</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {products.length === 0 ? (
              <TableRow>
                <TableCell colSpan={7} align="center" sx={{ py: 6, color: 'text.secondary' }}>
                  <CheckCircleOutlineIcon sx={{ fontSize: 40, color: '#4CAF50', mb: 1 }} />
                  <Typography variant="body1" fontWeight={500}>
                    All caught up! No products pending approval.
                  </Typography>
                </TableCell>
              </TableRow>
            ) : (
              products.map((p) => (
                <TableRow key={p.id} hover>
                  <TableCell sx={{ fontWeight: 500 }}>{p.name}</TableCell>
                  <TableCell>
                    <Chip label={p.category} size="small" variant="outlined" />
                  </TableCell>
                  <TableCell align="right">{p.price}</TableCell>
                  <TableCell align="right">{p.stock}</TableCell>
                  <TableCell>{p.farmerName}</TableCell>
                  <TableCell sx={{ color: 'text.secondary', fontSize: 13 }}>{new Date(p.createdAt).toLocaleDateString()}</TableCell>
                  <TableCell align="center">
                    <Stack direction="row" spacing={0.5} justifyContent="center">
                      <Button
                        size="small"
                        variant="outlined"
                        startIcon={<VisibilityIcon />}
                        onClick={() => handleViewDetails(p)}
                        sx={{ textTransform: 'none', fontSize: 12 }}
                      >
                        View
                      </Button>
                      <Button
                        size="small"
                        variant="contained"
                        color="success"
                        startIcon={<CheckCircleOutlineIcon />}
                        onClick={() => handleApproveClick(p)}
                        sx={{ textTransform: 'none', fontSize: 12, minWidth: 'auto' }}
                      >
                        Approve
                      </Button>
                      <Button
                        size="small"
                        variant="outlined"
                        color="error"
                        startIcon={<CancelOutlinedIcon />}
                        onClick={() => handleRejectClick(p)}
                        sx={{ textTransform: 'none', fontSize: 12, minWidth: 'auto' }}
                      >
                        Reject
                      </Button>
                    </Stack>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </TableContainer>

      {/* ── View Details Dialog ── */}
      <Dialog open={detailOpen} onClose={() => setDetailOpen(false)} fullWidth maxWidth="sm">
        <DialogTitle sx={{ fontWeight: 600, color: '#0A2540' }}>Product Details</DialogTitle>
        <DialogContent dividers>
          {detailProduct && (
            <Stack spacing={2.5} sx={{ pt: 1 }}>
              {/* Placeholder product image */}
              <Box
                sx={{
                  width: '100%',
                  height: 180,
                  borderRadius: 2,
                  bgcolor: '#F5F7FA',
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  justifyContent: 'center',
                  border: '2px dashed rgba(0,0,0,0.12)',
                }}
              >
                <ImageIcon sx={{ fontSize: 48, color: 'rgba(0,0,0,0.2)' }} />
                <Typography variant="caption" color="text.secondary" sx={{ mt: 0.5 }}>
                  Product image placeholder
                </Typography>
              </Box>

              <Box>
                <Typography variant="subtitle2" color="text.secondary" gutterBottom>
                  Product Name
                </Typography>
                <Typography variant="body1" fontWeight={500}>
                  {detailProduct.name}
                </Typography>
              </Box>

              <Divider />

              <Stack direction="row" spacing={4}>
                <Box flex={1}>
                  <Typography variant="subtitle2" color="text.secondary" gutterBottom>
                    Category
                  </Typography>
                  <Chip label={detailProduct.category} size="small" variant="outlined" />
                </Box>
                <Box flex={1}>
                  <Typography variant="subtitle2" color="text.secondary" gutterBottom>
                    Price
                  </Typography>
                  <Typography variant="body1" fontWeight={600}>
                    ₹{detailProduct.price}
                  </Typography>
                </Box>
                <Box flex={1}>
                  <Typography variant="subtitle2" color="text.secondary" gutterBottom>
                    Stock
                  </Typography>
                  <Typography variant="body1" fontWeight={600}>
                    {detailProduct.stock} units
                  </Typography>
                </Box>
              </Stack>

              <Divider />

              <Stack direction="row" spacing={4}>
                <Box flex={1}>
                  <Typography variant="subtitle2" color="text.secondary" gutterBottom>
                    Farmer
                  </Typography>
                  <Typography variant="body1">{detailProduct.farmer}</Typography>
                </Box>
                <Box flex={1}>
                  <Typography variant="subtitle2" color="text.secondary" gutterBottom>
                    Submitted Date
                  </Typography>
                  <Typography variant="body1">{detailProduct.submittedDate}</Typography>
                </Box>
              </Stack>

              <Divider />

              <Box>
                <Typography variant="subtitle2" color="text.secondary" gutterBottom>
                  Description
                </Typography>
                <Typography variant="body2" sx={{ color: 'text.secondary', lineHeight: 1.7 }}>
                  {detailProduct.description}
                </Typography>
              </Box>
            </Stack>
          )}
        </DialogContent>
        <DialogActions sx={{ px: 3, py: 2, gap: 1 }}>
          <Button onClick={() => setDetailOpen(false)} sx={{ mr: 'auto' }}>
            Close
          </Button>
          <Button
            variant="outlined"
            color="error"
            startIcon={<CancelOutlinedIcon />}
            onClick={() => detailProduct && handleRejectClick(detailProduct)}
          >
            Reject
          </Button>
          <Button
            variant="contained"
            color="success"
            startIcon={<CheckCircleOutlineIcon />}
            onClick={() => detailProduct && handleApproveClick(detailProduct)}
          >
            Approve
          </Button>
        </DialogActions>
      </Dialog>

      {/* ── Approve Confirmation Dialog ── */}
      <Dialog open={confirmApproveOpen} onClose={() => setConfirmApproveOpen(false)} maxWidth="xs" fullWidth>
        <DialogTitle sx={{ fontWeight: 600, color: '#0A2540' }}>Confirm Approval</DialogTitle>
        <DialogContent>
          <Typography variant="body1">
            Are you sure you want to approve <strong>{approveTarget?.name}</strong> by{' '}
            <strong>{approveTarget?.farmerName}</strong>?
          </Typography>
        </DialogContent>
        <DialogActions sx={{ px: 3, py: 2 }}>
          <Button onClick={() => setConfirmApproveOpen(false)}>Cancel</Button>
          <Button variant="contained" color="success" onClick={handleApproveConfirm}>
            Yes, Approve
          </Button>
        </DialogActions>
      </Dialog>

      {/* ── Reject Reason Dialog ── */}
      <Dialog open={rejectOpen} onClose={() => setRejectOpen(false)} maxWidth="xs" fullWidth>
        <DialogTitle sx={{ fontWeight: 600, color: '#0A2540' }}>Reject Product</DialogTitle>
        <DialogContent>
          <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
            Please provide a reason for rejecting <strong>{rejectTarget?.name}</strong>.
          </Typography>
          <TextField
            autoFocus
            label="Rejection Reason"
            variant="outlined"
            fullWidth
            multiline
            rows={3}
            value={rejectReason}
            onChange={(e) => setRejectReason(e.target.value)}
          />
        </DialogContent>
        <DialogActions sx={{ px: 3, py: 2 }}>
          <Button onClick={() => setRejectOpen(false)}>Cancel</Button>
          <Button variant="contained" color="error" onClick={handleRejectConfirm} disabled={!rejectReason.trim()}>
            Reject Product
          </Button>
        </DialogActions>
      </Dialog>

      {/* ── Snackbar ── */}
      <Snackbar
        open={snack.open}
        autoHideDuration={3000}
        onClose={() => setSnack((s) => ({ ...s, open: false }))}
        anchorOrigin={{ vertical: 'bottom', horizontal: 'center' }}
      >
        <Alert
          onClose={() => setSnack((s) => ({ ...s, open: false }))}
          severity={snack.severity}
          variant="filled"
          sx={{ borderRadius: 2 }}
        >
          {snack.message}
        </Alert>
      </Snackbar>
    </Box>
  );
}
