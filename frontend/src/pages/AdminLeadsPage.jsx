import { useEffect, useState } from "react";
import {
  Box,
  Card,
  CardContent,
  Chip,
  CircularProgress,
  MenuItem,
  Pagination,
  Select,
  Stack,
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableRow,
  TextField,
  Tooltip,
  Typography,
} from "@mui/material";
import AdsClickIcon from "@mui/icons-material/AdsClick";
import { adminApi } from "../api/adminApi";
import { formatDate } from "../utils/localization";

const statusOptions = ["all", "new", "contacted", "qualified", "site_visit", "closed", "lost"];
const pipelineStages = ["all", "new", "interested", "hot", "site_visit_planned", "negotiation", "converted", "lost"];

export default function AdminLeadsPage() {
  const [items, setItems] = useState([]);
  const [meta, setMeta] = useState({ total_pages: 1 });
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");
  const [pipelineFilter, setPipelineFilter] = useState("all");
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(true);

  const loadLeads = () => {
    setLoading(true);
    adminApi
      .getLeads({
        page,
        page_size: 12,
        search: search || undefined,
        status: statusFilter === "all" ? undefined : statusFilter,
        pipeline_stage: pipelineFilter === "all" ? undefined : pipelineFilter,
      })
      .then((response) => {
        setItems(response.items || []);
        setMeta(response.meta || { total_pages: 1 });
      })
      .finally(() => {
        setLoading(false);
      });
  };

  useEffect(() => {
    loadLeads();
  }, [page, statusFilter, pipelineFilter]);

  const handleFieldChange = async (leadId, field, value) => {
    await adminApi.updateLead(leadId, { [field]: value });
    loadLeads();
  };

  return (
    <Card>
      <CardContent>
        <Stack direction={{ xs: "column", lg: "row" }} spacing={2} justifyContent="space-between" alignItems={{ lg: "center" }}>
          <Typography variant="h4">Lead Intelligence (CRM)</Typography>
          <Stack direction={{ xs: "column", sm: "row" }} spacing={1.5} flexWrap="wrap">
            <TextField
              size="small"
              placeholder="Search leads..."
              value={search}
              onChange={(event) => setSearch(event.target.value)}
              onKeyDown={(event) => {
                if (event.key === "Enter") {
                  event.preventDefault();
                  setPage(1);
                  loadLeads();
                }
              }}
              sx={{ minWidth: 200 }}
            />
            <Select size="small" value={statusFilter} onChange={(event) => { setStatusFilter(event.target.value); setPage(1); }}>
              {statusOptions.map((status) => (
                <MenuItem key={status} value={status}>
                  {status === "all" ? "All statuses" : `Status: ${status}`}
                </MenuItem>
              ))}
            </Select>
            <Select size="small" value={pipelineFilter} onChange={(event) => { setPipelineFilter(event.target.value); setPage(1); }}>
              {pipelineStages.map((stage) => (
                <MenuItem key={stage} value={stage}>
                  {stage === "all" ? "All stages" : `Stage: ${stage.replace(/_/g, " ")}`}
                </MenuItem>
              ))}
            </Select>
          </Stack>
        </Stack>

        {loading ? (
          <Stack sx={{ py: 8, alignItems: "center" }}>
            <CircularProgress />
          </Stack>
        ) : (
          <>
            <Table sx={{ mt: 2 }}>
              <TableHead>
                <TableRow>
                  <TableCell>Contact / Source</TableCell>
                  <TableCell>Ad Tracking</TableCell>
                  <TableCell>Pipeline Stage</TableCell>
                  <TableCell>Process Status</TableCell>
                  <TableCell>Tags</TableCell>
                  <TableCell>Engagement</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {items.map((lead) => (
                  <TableRow key={lead.id} hover>
                    <TableCell>
                      <Typography fontWeight={700}>{lead.name}</Typography>
                      <Typography variant="body2">{lead.phone}</Typography>
                      <Typography variant="caption" color="text.secondary" sx={{ display: "block", mt: 0.5 }}>
                        {lead.email || "No email"} • {lead.cta_type || "General inquiry"}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      {lead.utm_source ? (
                        <Tooltip title={`UTM: ${lead.utm_source} / ${lead.utm_medium} / ${lead.utm_campaign}`}>
                          <Chip
                            icon={<AdsClickIcon />}
                            label={lead.utm_source}
                            size="small"
                            color="info"
                            variant="outlined"
                          />
                        </Tooltip>
                      ) : (
                        <Typography variant="caption" color="text.disabled">Organic / direct</Typography>
                      )}
                    </TableCell>
                    <TableCell>
                      <Select
                        size="small"
                        fullWidth
                        value={lead.pipeline_stage}
                        onChange={(event) => handleFieldChange(lead.id, "pipeline_stage", event.target.value)}
                        sx={{ fontSize: "0.875rem" }}
                      >
                        {pipelineStages.filter((s) => s !== "all").map((stage) => (
                          <MenuItem key={stage} value={stage} sx={{ fontSize: "0.875rem" }}>
                            {stage.replace(/_/g, " ")}
                          </MenuItem>
                        ))}
                      </Select>
                    </TableCell>
                    <TableCell>
                      <Select
                        size="small"
                        fullWidth
                        value={lead.status}
                        onChange={(event) => handleFieldChange(lead.id, "status", event.target.value)}
                        sx={{ fontSize: "0.875rem" }}
                      >
                        {statusOptions.filter((s) => s !== "all").map((status) => (
                          <MenuItem key={status} value={status} sx={{ fontSize: "0.875rem" }}>
                            {status}
                          </MenuItem>
                        ))}
                      </Select>
                    </TableCell>
                    <TableCell>
                      <Box sx={{ display: "flex", flexWrap: "wrap", gap: 0.5 }}>
                        {lead.tags.map((tag) => (
                          <Chip key={tag} label={tag} size="small" />
                        ))}
                        {lead.tags.length === 0 && <Typography variant="caption" color="text.disabled">—</Typography>}
                      </Box>
                    </TableCell>
                    <TableCell>
                      <Typography variant="caption" color="text.secondary" sx={{ display: "block" }}>
                        Inquired: {formatDate(lead.created_at)}
                      </Typography>
                      <Typography variant="caption" sx={{ fontWeight: 600, color: "primary.main" }}>
                        {lead.site_visit_history?.length || 0} visits logged
                      </Typography>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
            <Stack sx={{ mt: 3, alignItems: "center" }}>
              <Pagination page={page} count={meta.total_pages || 1} onChange={(_, nextPage) => setPage(nextPage)} color="primary" />
            </Stack>
          </>
        )}
      </CardContent>
    </Card>
  );
}

