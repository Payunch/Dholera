import { useEffect, useState } from "react";
import {
  Box,
  Button,
  CircularProgress,
  Container,
  FormControl,
  Grid,
  InputAdornment,
  MenuItem,
  Pagination,
  Select,
  Stack,
  TextField,
  Typography,
} from "@mui/material";
import SearchRoundedIcon from "@mui/icons-material/SearchRounded";
import TuneRoundedIcon from "@mui/icons-material/TuneRounded";
import Seo from "../../components/common/Seo";
import SectionHeader from "../../components/common/SectionHeader";
import UpdateCard from "../../components/updates/UpdateCard";
import { api } from "../../api/api";
import { useLanguage } from "../../context/LanguageContext";
import { CATEGORY_OPTIONS } from "../../data/siteData";

export default function UpdatesPage() {
  const { t } = useLanguage();
  const [query, setQuery] = useState("");
  const [appliedQuery, setAppliedQuery] = useState("");
  const [category, setCategory] = useState("all");
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(true);
  const [data, setData] = useState({ featured: null, items: [], meta: { total_pages: 1 } });

  useEffect(() => {
    let active = true;
    setLoading(true);
    api.public
      .getUpdates({
        page,
        page_size: 9,
        search: appliedQuery || undefined,
        category: category === "all" ? undefined : category,
        include_featured: page === 1,
      })
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
  }, [appliedQuery, category, page]);

  const showFeatured = page === 1 && !appliedQuery && category === "all" && data.featured;
  const items = (data.items || []).filter((item) => item.id !== data.featured?.id);

  const handleSubmit = (event) => {
    event.preventDefault();
    setPage(1);
    setAppliedQuery(query.trim());
  };

  return (
    <Box sx={{ pb: 8 }}>
      <Seo
        title="Growth Tracker | Infrastructure Intelligence Monitor"
        description="Daily monitor of infrastructure activity, expressway progress, and corridor planning. Follow the movement that drives investment confidence."
        path="/updates"
      />

      <Container maxWidth="xl" sx={{ pt: { xs: 4, md: 6 } }}>
        <SectionHeader
          eyebrow={{ en: t("feed_intro"), hi: "इन्फ्रास्ट्रक्चर इंटेलिजेंस मॉनिटर", gu: "ઇન્ફ્રાસ્ટ્રક્ચર ઇન્ટેલિજન્સ મોનિટર" }}
          title={{
            en: "Newest-first growth signals that build investment momentum.",
            hi: "नये विकास संकेत जो निवेश की गति और भरोसा बनाते हैं।",
            gu: "નવા વિકાસ સંકેતો જે રોકાણની ગતિ અને વિશ્વાસ બનાવે છે.",
          }}
          description={{
            en: "Track expressway activity, industrial movement, and corridor expansion. Move directly from evidence to WhatsApp consultation or site-visit scheduling.",
            hi: "एक्सप्रेसवे गतिविधि, औद्योगिक गति और कॉरिडोर विस्तार को ट्रैक करें। प्रमाण से सीधे व्हाट्सऐप परामर्श या साइट विजिट शेड्यूलिंग तक जाएँ।",
            gu: "એક્સપ્રેસવે પ્રવૃત્તિ, ઔદ્યોગિક ગતિ અને કોરિડોર વિસ્તરણને ટ્રૅક કરો. પુરાવા થી સીધા વોટ્સએપ પરામર્શ અથવા સાઇટ-વિઝિટ શેડ્યુલિંગ પર જાઓ.",
          }}
        />

        <Stack
          component="form"
          onSubmit={handleSubmit}
          direction={{ xs: "column", md: "row" }}
          spacing={2}
          sx={{ mt: 4, p: 2, bgcolor: "background.paper", borderRadius: 4, border: "1px solid rgba(27, 74, 110, 0.08)" }}
        >
          <TextField
            fullWidth
            value={query}
            onChange={(event) => setQuery(event.target.value)}
            placeholder={t("filters_search")}
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <SearchRoundedIcon />
                </InputAdornment>
              ),
            }}
          />
          <FormControl sx={{ minWidth: { xs: "100%", md: 220 } }}>
            <Select value={category} onChange={(event) => { setCategory(event.target.value); setPage(1); }}>
              <MenuItem value="all">{t("filters_all")}</MenuItem>
              {CATEGORY_OPTIONS.map((item) => (
                <MenuItem key={item} value={item}>
                  {item}
                </MenuItem>
              ))}
            </Select>
          </FormControl>
          <Button type="submit" variant="contained" startIcon={<TuneRoundedIcon />}>
            Apply
          </Button>
        </Stack>

        {loading ? (
          <Stack sx={{ py: 8, alignItems: "center" }}>
            <CircularProgress />
          </Stack>
        ) : (
          <>
            {showFeatured ? (
              <Box sx={{ mt: 4 }}>
                <UpdateCard update={data.featured} featured />
              </Box>
            ) : null}

            {items.length ? (
              <Grid container spacing={3} sx={{ mt: 0.5 }}>
                {items.map((item) => (
                  <Grid item xs={12} md={6} lg={4} key={item.id}>
                    <UpdateCard update={item} />
                  </Grid>
                ))}
              </Grid>
            ) : (
              <Typography sx={{ mt: 4, color: "text.secondary" }}>{t("no_updates")}</Typography>
            )}

            <Stack sx={{ mt: 4, alignItems: "center" }}>
              <Pagination
                page={page}
                count={data.meta?.total_pages || 1}
                onChange={(_, nextPage) => setPage(nextPage)}
                color="primary"
              />
            </Stack>
          </>
        )}
      </Container>
    </Box>
  );
}
