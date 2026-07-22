import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { adminService } from '../services/admin.service';
import DataTable from '../components/DataTable';
import SearchFilter from '../components/SearchFilter';
import StatusChip from '../components/StatusChip';
import PageHeader from '../components/PageHeader';
import {
  Box,
  Typography,
  IconButton,
  Tooltip,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  Drawer,
  Grid,
  Divider,
} from '@mui/material';
import InfoIcon from '@mui/icons-material/Info';
import BlockIcon from '@mui/icons-material/Block';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';

const DELIVERY_PARTNER_STATUSES = ['ACTIVE', 'SUSPENDED', 'INACTIVE'];

function formatDate(dateStr: string): string {
  const date = new Date(dateStr);
  return date.toLocaleDateString('en-IN', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  });
}

function formatCurrency(amount: number): string {
  return `₹${amount.toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
}

export default function DeliveryPartnersPage() {
  const queryClient = useQueryClient();

  const [page, setPage] = useState(1);
  const [limit] = useState(10);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [selectedPartner, setSelectedPartner] = useState<any>(null);
  const [detailDrawerOpen, setDetailDrawerOpen] = useState(false);
  const [toggleStatusDialogOpen, setToggleStatusDialogOpen] = useState(false);

  const { data, isLoading } = useQuery({
    queryKey: ['deliveryPartners', { page, limit, search, status: statusFilter }],
    queryFn: () =>
      adminService.getDeliveryPartners({ page, limit, search, status: statusFilter }),
  });

  const toggleStatusMutation = useMutation({
    mutationFn: ({ id, status }: { id: string; status: string }) =>
      adminService.updateDeliveryPartner(id, { status } as any),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['deliveryPartners'] });
      setToggleStatusDialogOpen(false);
      setSelectedPartner(null);
    },
  });

  const handleViewDetail = (partner: any) => {
    setSelectedPartner(partner);
    setDetailDrawerOpen(true);
  };

  const handleToggleStatus = (partner: any) => {
    setSelectedPartner(partner);
    setToggleStatusDialogOpen(true);
  };

  const handleConfirmToggleStatus = () => {
    if (selectedPartner) {
      const newStatus = selectedPartner.status === 'ACTIVE' ? 'SUSPENDED' : 'ACTIVE';
      toggleStatusMutation.mutate({ id: selectedPartner.id, status: newStatus });
    }
  };

  const columns = [
    {
      key: 'name',
      label: 'Name',
      render: (row: any) => (
        <Typography variant="body2" sx={{ fontWeight: 600 }}>
          {row.name}
        </Typography>
      ),
    },
    {
      key: 'email',
      label: 'Email',
      render: (row: any) => (
        <Typography variant="body2" color="text.secondary">
          {row.email}
        </Typography>
      ),
    },
    {
      key: 'phone',
      label: 'Phone',
      render: (row: any) => <Typography variant="body2">{row.phone}</Typography>,
    },
    {
      key: 'vehicleType',
      label: 'Vehicle',
      render: (row: any) => (
        <Box>
          <Typography variant="body2">{row.vehicleType}</Typography>
          <Typography variant="caption" color="text.secondary">
            {row.vehicleNumber}
          </Typography>
        </Box>
      ),
    },
    {
      key: 'completedDeliveries',
      label: 'Deliveries',
      render: (row: any) => (
        <Typography variant="body2" sx={{ fontWeight: 600 }}>
          {row.completedDeliveries}
        </Typography>
      ),
    },
    {
      key: 'rating',
      label: 'Rating',
      render: (row: any) => (
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
          <Typography variant="body2" sx={{ fontWeight: 600 }}>
            {row.rating.toFixed(1)}
          </Typography>
          <Typography variant="caption" color="text.secondary">
            / 5.0
          </Typography>
        </Box>
      ),
    },
    {
      key: 'status',
      label: 'Status',
      render: (row: any) => (
        <StatusChip status={row.status} />
      ),
    },
    {
      key: 'actions',
      label: 'Actions',
      render: (row: any) => (
        <Box sx={{ display: 'flex', gap: 0.5 }}>
          <Tooltip title="View Details">
            <IconButton size="small" onClick={() => handleViewDetail(row)}>
              <InfoIcon fontSize="small" />
            </IconButton>
          </Tooltip>
          <Tooltip title={row.status === 'ACTIVE' ? 'Suspend' : 'Activate'}>
            <IconButton
              size="small"
              color={row.status === 'ACTIVE' ? 'error' : 'success'}
              onClick={() => handleToggleStatus(row)}
            >
              {row.status === 'ACTIVE' ? (
                <BlockIcon fontSize="small" />
              ) : (
                <CheckCircleIcon fontSize="small" />
              )}
            </IconButton>
          </Tooltip>
        </Box>
      ),
    },
  ];

  return (
    <Box>
      <PageHeader title="Delivery Partner Management" />

      <SearchFilter
        searchPlaceholder="Search by name or email..."
        searchValue={search}
        onSearchChange={setSearch}
        filters={[
          {
            key: 'status',
            label: 'Status',
            value: statusFilter,
            options: DELIVERY_PARTNER_STATUSES.map((s) => ({ label: s, value: s })),
          },
        ]}
        onFilterChange={(key: string, value: string) => {
          if (key === 'status') {
            setStatusFilter(value);
            setPage(1);
          }
        }}
      />

      <DataTable
        columns={columns}
        data={data?.items || []}
        loading={isLoading}
        page={page}
        rowsPerPage={limit}
        total={data?.total || 0}
        onPageChange={setPage}
      />

      <Drawer
        anchor="right"
        open={detailDrawerOpen}
        onClose={() => setDetailDrawerOpen(false)}
        PaperProps={{ sx: { width: 450 } }}
      >
        {selectedPartner && (
          <Box sx={{ p: 3 }}>
            <Typography variant="h6" sx={{ mb: 2 }}>
              {selectedPartner.name}
            </Typography>

            <Divider sx={{ my: 2 }} />

            <Typography variant="subtitle2" gutterBottom>
              Personal Information
            </Typography>
            <Grid container spacing={1}>
              <Grid item xs={6}>
                <Typography variant="caption" color="text.secondary">
                  Email
                </Typography>
                <Typography variant="body2">{selectedPartner.email}</Typography>
              </Grid>
              <Grid item xs={6}>
                <Typography variant="caption" color="text.secondary">
                  Phone
                </Typography>
                <Typography variant="body2">{selectedPartner.phone}</Typography>
              </Grid>
              <Grid item xs={6}>
                <Typography variant="caption" color="text.secondary">
                  Status
                </Typography>
                <Box>
                  <StatusChip
                    status={selectedPartner.status}
                  />
                </Box>
              </Grid>
              <Grid item xs={6}>
                <Typography variant="caption" color="text.secondary">
                  Joined
                </Typography>
                <Typography variant="body2">{formatDate(selectedPartner.createdAt)}</Typography>
              </Grid>
              <Grid item xs={12}>
                <Typography variant="caption" color="text.secondary">
                  Address
                </Typography>
                <Typography variant="body2">{selectedPartner.address}</Typography>
              </Grid>
            </Grid>

            <Divider sx={{ my: 2 }} />

            <Typography variant="subtitle2" gutterBottom>
              VEHICLE DETAILS
            </Typography>
            <Grid container spacing={1}>
              <Grid item xs={6}>
                <Typography variant="caption" color="text.secondary">
                  Vehicle Type
                </Typography>
                <Typography variant="body2">{selectedPartner.vehicleType || 'BIKE'}</Typography>
              </Grid>
              <Grid item xs={6}>
                <Typography variant="caption" color="text.secondary">
                  Vehicle Number
                </Typography>
                <Typography variant="body2">{selectedPartner.vehicleNumber || 'N/A'}</Typography>
              </Grid>
              <Grid item xs={12}>
                <Typography variant="caption" color="text.secondary">
                  License Number
                </Typography>
                <Typography variant="body2">{selectedPartner.licenseNumber || 'N/A'}</Typography>
              </Grid>
            </Grid>

            <Divider sx={{ my: 2 }} />

            <Typography variant="subtitle2" gutterBottom>
              BANK ACCOUNT
            </Typography>
            {(() => {
              const b = selectedPartner.bankAccount || {};
              const accNo = b.accountNumber && b.accountNumber !== 'N/A' ? b.accountNumber : (selectedPartner.accountNumber || 'N/A');
              const ifsc = (b.ifscCode && b.ifscCode !== 'N/A') ? b.ifscCode : ((b.routingNumber && b.routingNumber !== 'N/A') ? b.routingNumber : (selectedPartner.ifscCode || selectedPartner.routingNumber || 'N/A'));
              const bankName = b.bankName && b.bankName !== 'N/A' ? b.bankName : (selectedPartner.bankName || 'N/A');
              const holder = b.accountHolder || selectedPartner.name || 'N/A';

              return (
                <Grid container spacing={1}>
                  <Grid item xs={12}>
                    <Typography variant="caption" color="text.secondary">
                      Account Holder
                    </Typography>
                    <Typography variant="body2">{holder}</Typography>
                  </Grid>
                  <Grid item xs={6}>
                    <Typography variant="caption" color="text.secondary">
                      Account Number
                    </Typography>
                    <Typography variant="body2">{accNo}</Typography>
                  </Grid>
                  <Grid item xs={6}>
                    <Typography variant="caption" color="text.secondary">
                      IFSC
                    </Typography>
                    <Typography variant="body2">{ifsc}</Typography>
                  </Grid>
                  <Grid item xs={12}>
                    <Typography variant="caption" color="text.secondary">
                      Bank
                    </Typography>
                    <Typography variant="body2">{bankName}</Typography>
                  </Grid>
                </Grid>
              );
            })()}

            <Divider sx={{ my: 2 }} />

            <Typography variant="subtitle2" gutterBottom>
              Statistics
            </Typography>
            <Grid container spacing={1}>
              <Grid item xs={6}>
                <Box
                  sx={{
                    p: 1.5,
                    borderRadius: 1,
                    bgcolor: 'grey.50',
                    textAlign: 'center',
                  }}
                >
                  <Typography variant="h5" sx={{ fontWeight: 700 }}>
                    {selectedPartner.completedDeliveries}
                  </Typography>
                  <Typography variant="caption" color="text.secondary">
                    Completed Deliveries
                  </Typography>
                </Box>
              </Grid>
              <Grid item xs={6}>
                <Box
                  sx={{
                    p: 1.5,
                    borderRadius: 1,
                    bgcolor: 'grey.50',
                    textAlign: 'center',
                  }}
                >
                  <Typography variant="h5" sx={{ fontWeight: 700 }}>
                    {selectedPartner.rating.toFixed(1)}
                  </Typography>
                  <Typography variant="caption" color="text.secondary">
                    Rating
                  </Typography>
                </Box>
              </Grid>
              <Grid item xs={6}>
                <Box
                  sx={{
                    p: 1.5,
                    borderRadius: 1,
                    bgcolor: 'grey.50',
                    textAlign: 'center',
                  }}
                >
                  <Typography variant="h5" sx={{ fontWeight: 700 }}>
                    {selectedPartner.onTimePercentage}%
                  </Typography>
                  <Typography variant="caption" color="text.secondary">
                    On-Time Delivery
                  </Typography>
                </Box>
              </Grid>
              <Grid item xs={6}>
                <Box
                  sx={{
                    p: 1.5,
                    borderRadius: 1,
                    bgcolor: 'grey.50',
                    textAlign: 'center',
                  }}
                >
                  <Typography variant="h5" sx={{ fontWeight: 700 }}>
                    {selectedPartner.averageDeliveryTime} min
                  </Typography>
                  <Typography variant="caption" color="text.secondary">
                    Avg Delivery Time
                  </Typography>
                </Box>
              </Grid>
              <Grid item xs={6}>
                <Box
                  sx={{
                    p: 1.5,
                    borderRadius: 1,
                    bgcolor: 'grey.50',
                    textAlign: 'center',
                  }}
                >
                  <Typography variant="h5" sx={{ fontWeight: 700 }}>
                    {selectedPartner.totalDistance.toLocaleString()} km
                  </Typography>
                  <Typography variant="caption" color="text.secondary">
                    Total Distance
                  </Typography>
                </Box>
              </Grid>
              <Grid item xs={6}>
                <Box
                  sx={{
                    p: 1.5,
                    borderRadius: 1,
                    bgcolor: 'grey.50',
                    textAlign: 'center',
                  }}
                >
                  <Typography variant="h5" sx={{ fontWeight: 700 }}>
                    {formatCurrency(selectedPartner.totalEarnings)}
                  </Typography>
                  <Typography variant="caption" color="text.secondary">
                    Total Earnings
                  </Typography>
                </Box>
              </Grid>
            </Grid>

            <Divider sx={{ my: 2 }} />

            <Button
              variant={selectedPartner.status === 'ACTIVE' ? 'outlined' : 'contained'}
              color={selectedPartner.status === 'ACTIVE' ? 'error' : 'success'}
              fullWidth
              startIcon={selectedPartner.status === 'ACTIVE' ? <BlockIcon /> : <CheckCircleIcon />}
              onClick={() => {
                setDetailDrawerOpen(false);
                handleToggleStatus(selectedPartner);
              }}
            >
              {selectedPartner.status === 'ACTIVE' ? 'Suspend Partner' : 'Activate Partner'}
            </Button>
          </Box>
        )}
      </Drawer>

      <Dialog
        open={toggleStatusDialogOpen}
        onClose={() => setToggleStatusDialogOpen(false)}
        maxWidth="xs"
        fullWidth
      >
        <DialogTitle>
          {selectedPartner?.status === 'ACTIVE' ? 'Suspend' : 'Activate'} Delivery Partner
        </DialogTitle>
        <DialogContent>
          <Typography variant="body2">
            Are you sure you want to{' '}
            {selectedPartner?.status === 'ACTIVE' ? 'suspend' : 'activate'} delivery partner{' '}
            <strong>{selectedPartner?.name}</strong>?
            {selectedPartner?.status === 'ACTIVE'
              ? ' They will not be able to accept new deliveries.'
              : ' They will be able to accept deliveries again.'}
          </Typography>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setToggleStatusDialogOpen(false)}>Cancel</Button>
          <Button
            variant="contained"
            color={selectedPartner?.status === 'ACTIVE' ? 'error' : 'success'}
            onClick={handleConfirmToggleStatus}
            disabled={toggleStatusMutation.isPending}
          >
            {toggleStatusMutation.isPending
              ? 'Processing...'
              : selectedPartner?.status === 'ACTIVE'
                ? 'Suspend'
                : 'Activate'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}
