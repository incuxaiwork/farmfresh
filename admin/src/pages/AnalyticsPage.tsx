import { Box, Card, CardContent, Grid, Typography, LinearProgress } from '@mui/material';
import TrendingUpIcon from '@mui/icons-material/TrendingUp';
import PeopleIcon from '@mui/icons-material/People';
import ShoppingBagIcon from '@mui/icons-material/ShoppingBag';

export default function AnalyticsPage() {
  return (
    <Box>
      <Typography variant="h5" fontWeight={700} mb={3}>
        Business Analytics
      </Typography>

      <Grid container spacing={3} mb={4}>
        <Grid item xs={12} md={4}>
          <Card>
            <CardContent>
              <Box display="flex" justifyContent="space-between" alignItems="center" mb={2}>
                <Typography variant="h6" color="text.secondary">Sales Growth</Typography>
                <TrendingUpIcon color="success" />
              </Box>
              <Typography variant="h4" fontWeight={700}>+24.5%</Typography>
              <Typography variant="body2" color="text.secondary" mt={1}>vs Last month</Typography>
              <Box mt={2}>
                <LinearProgress variant="determinate" value={75} color="success" />
              </Box>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} md={4}>
          <Card>
            <CardContent>
              <Box display="flex" justifyContent="space-between" alignItems="center" mb={2}>
                <Typography variant="h6" color="text.secondary">New Customers</Typography>
                <PeopleIcon color="primary" />
              </Box>
              <Typography variant="h4" fontWeight={700}>+812</Typography>
              <Typography variant="body2" color="text.secondary" mt={1}>vs Last month</Typography>
              <Box mt={2}>
                <LinearProgress variant="determinate" value={60} color="primary" />
              </Box>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} md={4}>
          <Card>
            <CardContent>
              <Box display="flex" justifyContent="space-between" alignItems="center" mb={2}>
                <Typography variant="h6" color="text.secondary">Average Order Value</Typography>
                <ShoppingBagIcon color="secondary" />
              </Box>
              <Typography variant="h4" fontWeight={700}>₹840.00</Typography>
              <Typography variant="body2" color="text.secondary" mt={1}>vs Last month</Typography>
              <Box mt={2}>
                <LinearProgress variant="determinate" value={85} color="secondary" />
              </Box>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      <Card>
        <CardContent sx={{ p: 4 }}>
          <Typography variant="h6" fontWeight={600} mb={2}>Monthly Performance Summary</Typography>
          <Typography variant="body1" color="text.secondary" paragraph>
            Overall harvest supply matches demand indices. Fruits category is seeing peak volume due to summer harvests. Delivery turnaround is averaging 42 minutes across New York.
          </Typography>
        </CardContent>
      </Card>
    </Box>
  );
}
