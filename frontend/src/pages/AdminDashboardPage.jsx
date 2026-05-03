import { useEffect, useState } from "react";
import {
  Card,
  CardContent,
  CircularProgress,
  Grid,
  Stack,
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableRow,
  Typography,
} from "@mui/material";
import { adminApi } from "../api/adminApi";
import { formatDate } from "../utils/localization";

export default function AdminDashboardPage() {
  const [loading, setLoading] = useState(true);
  const [data, setData] = useState(null);

  useEffect(() => {
    let active = true;
    adminApi
      .getDashboard()
      .then((response) => {
        if (active) {
          setData(response);
        }
      })
      .finally(() => {
        if (active) {
          setLoading(false);
        }
      });
    return () => {
      active = false;
    };
  }, []);

  if (loading) {
    return (
      <Stack sx={{ py: 10, alignItems: "center" }}>
        <CircularProgress />
      </Stack>
    );
  }

  return (
    <Stack spacing={3}>
      <Typography variant="h3">Intelligence overview</Typography>
      <Grid container spacing={3}>
        {[
          ["Growth updates", data.summary.total_updates],
          ["Featured evidence", data.summary.featured_updates],
          ["Intelligence leads", data.summary.total_leads],
          ["New inquiries", data.summary.new_leads],
          ["System locales", data.summary.supported_languages],
        ].map(([label, value]) => (
          <Grid item xs={12} sm={6} lg={3} key={label}>
            <Card sx={{ height: "100%" }}>
              <CardContent>
                <Typography color="text.secondary">{label}</Typography>
                <Typography variant="h3" sx={{ mt: 1 }}>{value}</Typography>
              </CardContent>
            </Card>
          </Grid>
        ))}
      </Grid>

      <Grid container spacing={3}>
        <Grid item xs={12} lg={7}>
          <Card>
            <CardContent>
              <Typography variant="h5">Recent leads</Typography>
              <Table size="small" sx={{ mt: 2 }}>
                <TableHead>
                  <TableRow>
                    <TableCell>Name</TableCell>
                    <TableCell>Phone</TableCell>
                    <TableCell>Status</TableCell>
                    <TableCell>Created</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {data.recent_leads.map((lead) => (
                    <TableRow key={lead.id}>
                      <TableCell>{lead.name}</TableCell>
                      <TableCell>{lead.phone}</TableCell>
                      <TableCell>{lead.status}</TableCell>
                      <TableCell>{formatDate(lead.created_at)}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} lg={5}>
          <Card>
            <CardContent>
              <Typography variant="h5">Recent activity</Typography>
              <Stack spacing={2} sx={{ mt: 2 }}>
                {data.recent_updates.map((update) => (
                  <Stack key={update.id} spacing={0.4}>
                    <Typography fontWeight={700}>{update.title_en}</Typography>
                    <Typography color="text.secondary">
                      {update.category} • {formatDate(update.created_at)}
                    </Typography>
                  </Stack>
                ))}
              </Stack>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Stack>
  );
}
