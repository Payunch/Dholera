import { CircularProgress, Box } from "@mui/material";

export default function Loader() {
  return (
    <Box sx={{ display: "grid", minHeight: "50vh", placeItems: "center" }}>
      <CircularProgress />
    </Box>
  );
}
