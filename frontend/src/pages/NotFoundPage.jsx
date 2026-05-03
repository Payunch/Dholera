import { Box, Button, Container, Stack, Typography } from "@mui/material";
import { Link } from "react-router-dom";

export default function NotFoundPage() {
  return (
    <Container maxWidth="md">
      <Stack sx={{ minHeight: "70vh", justifyContent: "center", alignItems: "flex-start" }} spacing={2}>
        <Typography variant="overline" sx={{ color: "primary.main", fontWeight: 800, letterSpacing: "0.14em" }}>
          PAGE NOT FOUND
        </Typography>
        <Typography variant="h1" sx={{ fontSize: { xs: "2.8rem", md: "4.2rem" } }}>
          The route you requested does not exist.
        </Typography>
        <Typography color="text.secondary">
          Return to the homepage or continue into the growth tracker to review the latest activity.
        </Typography>
        <Box>
          <Button component={Link} to="/" variant="contained">
            Back home
          </Button>
        </Box>
      </Stack>
    </Container>
  );
}
