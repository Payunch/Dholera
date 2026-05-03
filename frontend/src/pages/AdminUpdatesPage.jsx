import { useEffect, useState } from "react";
import {
  Alert,
  Box,
  Button,
  Card,
  CardContent,
  CircularProgress,
  FormControlLabel,
  Grid,
  IconButton,
  MenuItem,
  Pagination,
  Stack,
  Switch,
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableRow,
  TextField,
  Typography,
} from "@mui/material";
import DeleteRoundedIcon from "@mui/icons-material/DeleteRounded";
import EditRoundedIcon from "@mui/icons-material/EditRounded";
import PublishRoundedIcon from "@mui/icons-material/PublishRounded";
import PictureAsPdfRoundedIcon from "@mui/icons-material/PictureAsPdfRounded";
import { adminApi } from "../api/adminApi";
import { CATEGORY_OPTIONS } from "../content/siteData";
import { formatDate, resolveMediaUrl, tagsInputToArray } from "../utils/localization";

const blankForm = {
  title_en: "",
  title_hi: "",
  title_gu: "",
  desc_en: "",
  desc_hi: "",
  desc_gu: "",
  image_url: "",
  thumbnail_url: "",
  pdf_url: "",
  category: CATEGORY_OPTIONS[0],
  tags: "",
  is_featured: false,
};

export default function AdminUpdatesPage() {
  const [items, setItems] = useState([]);
  const [page, setPage] = useState(1);
  const [meta, setMeta] = useState({ total_pages: 1 });
  const [search, setSearch] = useState("");
  const [category, setCategory] = useState("all");
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [form, setForm] = useState(blankForm);
  const [feedback, setFeedback] = useState({ type: "", message: "" });

  const loadUpdates = () => {
    setLoading(true);
    adminApi
      .getUpdates({
        page,
        page_size: 8,
        search: search || undefined,
        category: category === "all" ? undefined : category,
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
    loadUpdates();
  }, [page, category]);

  const resetForm = () => {
    setEditingId(null);
    setForm(blankForm);
  };

  const onFormChange = (field) => (event) => {
    const value = field === "is_featured" ? event.target.checked : event.target.value;
    setForm((previous) => ({ ...previous, [field]: value }));
  };

  const startEdit = (item) => {
    setEditingId(item.id);
    setForm({
      title_en: item.title_en || "",
      title_hi: item.title_hi || "",
      title_gu: item.title_gu || "",
      desc_en: item.desc_en || "",
      desc_hi: item.desc_hi || "",
      desc_gu: item.desc_gu || "",
      image_url: item.image_url || "",
      thumbnail_url: item.thumbnail_url || "",
      pdf_url: item.pdf_url || "",
      category: item.category,
      tags: (item.tags || []).join(", "),
      is_featured: item.is_featured,
    });
    setFeedback({ type: "", message: "" });
  };

  const handleImageUpload = async (event) => {
    const file = event.target.files?.[0];
    if (!file) return;
    setSaving(true);
    try {
      const data = await adminApi.uploadImage(file);
      setForm((previous) => ({
        ...previous,
        image_url: data.image_url,
        thumbnail_url: data.thumbnail_url,
      }));
      setFeedback({ type: "success", message: "Image uploaded successfully." });
    } catch (error) {
      setFeedback({ type: "error", message: error.response?.data?.detail || "Image upload failed." });
    } finally {
      setSaving(false);
      event.target.value = "";
    }
  };

  const handlePdfUpload = async (event) => {
    const file = event.target.files?.[0];
    if (!file) return;
    setSaving(true);
    try {
      const data = await adminApi.uploadPdf(file);
      setForm((previous) => ({
        ...previous,
        pdf_url: data.pdf_url,
      }));
      setFeedback({ type: "success", message: "PDF uploaded successfully." });
    } catch (error) {
      setFeedback({ type: "error", message: error.response?.data?.detail || "PDF upload failed." });
    } finally {
      setSaving(false);
      event.target.value = "";
    }
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    setSaving(true);
    setFeedback({ type: "", message: "" });
    const payload = {
      ...form,
      tags: tagsInputToArray(form.tags),
    };

    try {
      if (editingId) {
        await adminApi.updateUpdate(editingId, payload);
        setFeedback({ type: "success", message: "Update revised successfully." });
      } else {
        await adminApi.createUpdate(payload);
        setFeedback({ type: "success", message: "Update published successfully." });
      }
      resetForm();
      loadUpdates();
    } catch (error) {
      setFeedback({ type: "error", message: error.response?.data?.detail || "Could not save update." });
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm("Delete this update?")) return;
    try {
      await adminApi.deleteUpdate(id);
      loadUpdates();
    } catch (error) {
      setFeedback({ type: "error", message: error.response?.data?.detail || "Delete failed." });
    }
  };

  return (
    <Grid container spacing={3}>
      <Grid item xs={12} lg={5}>
        <Card sx={{ position: "sticky", top: 96 }}>
          <CardContent>
            <Typography variant="h4">{editingId ? "Edit update" : "Publish new development update"}</Typography>
            <Typography sx={{ mt: 1, color: "text.secondary" }}>
              Upload media, manage multilingual titles and descriptions, toggle featured visibility, and keep the feed searchable.
            </Typography>

            <Box component="form" onSubmit={handleSubmit} sx={{ mt: 3 }}>
              <Stack spacing={2}>
                <TextField label="Title (English)" value={form.title_en} onChange={onFormChange("title_en")} required />
                <TextField label="Title (Hindi)" value={form.title_hi} onChange={onFormChange("title_hi")} />
                <TextField label="Title (Gujarati)" value={form.title_gu} onChange={onFormChange("title_gu")} />
                <TextField label="Description (English)" value={form.desc_en} onChange={onFormChange("desc_en")} multiline minRows={4} required />
                <TextField label="Description (Hindi)" value={form.desc_hi} onChange={onFormChange("desc_hi")} multiline minRows={3} />
                <TextField label="Description (Gujarati)" value={form.desc_gu} onChange={onFormChange("desc_gu")} multiline minRows={3} />
                <TextField label="Video URL" value={form.video_url} onChange={onFormChange("video_url")} placeholder="Direct .mp4 link" />
                <TextField label="Video Embed Code" value={form.embed_code} onChange={onFormChange("embed_code")} multiline minRows={2} placeholder="YouTube/Instagram iframe code" />
                <TextField select label="Category" value={form.category} onChange={onFormChange("category")}>
                  {CATEGORY_OPTIONS.map((option) => (
                    <MenuItem key={option} value={option}>
                      {option}
                    </MenuItem>
                  ))}
                </TextField>
                <TextField label="Tags (comma separated)" value={form.tags} onChange={onFormChange("tags")} />
                <FormControlLabel control={<Switch checked={form.is_featured} onChange={onFormChange("is_featured")} />} label="Mark as featured" />

                <Stack direction={{ xs: "column", sm: "row" }} spacing={1.5}>
                  <Button component="label" variant="outlined" startIcon={<PublishRoundedIcon />} disabled={saving}>
                    Upload image
                    <input hidden type="file" accept="image/*" onChange={handleImageUpload} />
                  </Button>
                  <Button component="label" variant="outlined" startIcon={<PictureAsPdfRoundedIcon />} disabled={saving}>
                    Upload PDF
                    <input hidden type="file" accept="application/pdf" onChange={handlePdfUpload} />
                  </Button>
                </Stack>

                {form.image_url ? (
                  <Box
                    sx={{
                      height: 180,
                      borderRadius: 3,
                      background: `center / cover no-repeat url(${resolveMediaUrl(form.thumbnail_url || form.image_url)})`,
                    }}
                  />
                ) : null}
                {form.pdf_url ? (
                  <Alert severity="info">PDF attached: {form.pdf_url}</Alert>
                ) : null}

                <Stack direction="row" spacing={1.5}>
                  <Button type="submit" variant="contained" disabled={saving}>
                    {editingId ? "Save changes" : "Publish update"}
                  </Button>
                  <Button onClick={resetForm} disabled={saving}>
                    Clear
                  </Button>
                </Stack>
                {feedback.message ? (
                  <Alert severity={feedback.type === "success" ? "success" : "error"}>{feedback.message}</Alert>
                ) : null}
              </Stack>
            </Box>
          </CardContent>
        </Card>
      </Grid>

      <Grid item xs={12} lg={7}>
        <Card>
          <CardContent>
            <Stack direction={{ xs: "column", md: "row" }} spacing={2} justifyContent="space-between">
              <Typography variant="h4">Published updates</Typography>
              <Stack direction={{ xs: "column", sm: "row" }} spacing={1.5}>
                <TextField
                  size="small"
                  placeholder="Search updates"
                  value={search}
                  onChange={(event) => setSearch(event.target.value)}
                  onKeyDown={(event) => {
                    if (event.key === "Enter") {
                      event.preventDefault();
                      setPage(1);
                      loadUpdates();
                    }
                  }}
                />
                <TextField select size="small" value={category} onChange={(event) => { setCategory(event.target.value); setPage(1); }}>
                  <MenuItem value="all">All categories</MenuItem>
                  {CATEGORY_OPTIONS.map((option) => (
                    <MenuItem key={option} value={option}>
                      {option}
                    </MenuItem>
                  ))}
                </TextField>
                <Button onClick={() => { setPage(1); loadUpdates(); }}>Search</Button>
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
                      <TableCell>Title</TableCell>
                      <TableCell>Category</TableCell>
                      <TableCell>Featured</TableCell>
                      <TableCell>Created</TableCell>
                      <TableCell align="right">Actions</TableCell>
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {items.map((item) => (
                      <TableRow key={item.id}>
                        <TableCell>
                          <Typography fontWeight={700}>{item.title_en}</Typography>
                          <Typography variant="body2" color="text.secondary">
                            /updates/{item.slug}
                          </Typography>
                        </TableCell>
                        <TableCell>{item.category}</TableCell>
                        <TableCell>{item.is_featured ? "Yes" : "No"}</TableCell>
                        <TableCell>{formatDate(item.created_at)}</TableCell>
                        <TableCell align="right">
                          <IconButton onClick={() => startEdit(item)}>
                            <EditRoundedIcon />
                          </IconButton>
                          <IconButton color="error" onClick={() => handleDelete(item.id)}>
                            <DeleteRoundedIcon />
                          </IconButton>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
                <Stack sx={{ mt: 3, alignItems: "center" }}>
                  <Pagination page={page} count={meta.total_pages || 1} onChange={(_, nextPage) => setPage(nextPage)} />
                </Stack>
              </>
            )}
          </CardContent>
        </Card>
      </Grid>
    </Grid>
  );
}

