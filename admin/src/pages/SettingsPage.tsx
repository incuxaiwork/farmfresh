import { Box, Typography, Card, CardContent, Button, TextField, Grid } from '@mui/material';

export default function SettingsPage() {
  return (
    <Box>
      <Typography variant="h5" fontWeight={700} mb={3}>
        Portal Configurations & Settings
      </Typography>

      <Grid container spacing={3}>
        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Typography variant="h6" fontWeight={600} mb={2}>General Settings</Typography>
              <TextField
                fullWidth
                label="Marketplace Name"
                defaultValue="FarmFresh Multi-Vendor Platform"
                margin="normal"
              />
              <TextField
                fullWidth
                label="Support Contact Email"
                defaultValue="support@farmfresh.com"
                margin="normal"
              />
              <Button variant="contained" color="success" sx={{ mt: 2 }}>
                Save Configurations
              </Button>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Typography variant="h6" fontWeight={600} mb={2}>System Integrations</Typography>
              <TextField
                fullWidth
                label="Database Host"
                defaultValue="postgres.railway.internal"
                margin="normal"
                InputProps={{ readOnly: true }}
              />
              <Typography variant="caption" color="text.secondary">
                Database parameters are managed securely in backend environment configurations.
              </Typography>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
}
