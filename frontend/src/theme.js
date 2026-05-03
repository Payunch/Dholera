import { createTheme } from "@mui/material/styles";

const theme = createTheme({
  palette: {
    mode: "light",
    primary: {
      main: "#1b4a6e",
      dark: "#153955",
      light: "#3f7099",
    },
    secondary: {
      main: "#b69254",
      dark: "#8a6d3d",
      light: "#d7ba7d",
    },
    background: {
      default: "#f6f4ef",
      paper: "#ffffff",
    },
    text: {
      primary: "#152533",
      secondary: "#556572",
    },
    success: {
      main: "#2d7a55",
    },
    warning: {
      main: "#d38a30",
    },
  },
  typography: {
    fontFamily: '"Manrope", sans-serif',
    h1: {
      fontFamily: '"Source Serif 4", serif',
      fontWeight: 600,
      letterSpacing: "-0.03em",
      lineHeight: 1.08,
    },
    h2: {
      fontFamily: '"Source Serif 4", serif',
      fontWeight: 600,
      letterSpacing: "-0.02em",
      lineHeight: 1.14,
    },
    h3: {
      fontWeight: 700,
      letterSpacing: "-0.02em",
    },
    button: {
      fontWeight: 700,
      textTransform: "none",
    },
  },
  shape: {
    borderRadius: 18,
  },
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          borderRadius: 999,
          paddingInline: 18,
        },
      },
    },
    MuiCard: {
      styleOverrides: {
        root: {
          borderRadius: 24,
          boxShadow: "0 18px 48px rgba(21, 37, 51, 0.08)",
          border: "1px solid rgba(27, 74, 110, 0.08)",
        },
      },
    },
    MuiChip: {
      styleOverrides: {
        root: {
          borderRadius: 999,
          fontWeight: 700,
        },
      },
    },
  },
});

export default theme;

