import { useEffect, useState } from "react";
import {
  Box,
  Button,
  Card,
  CardContent,
  Container,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Grid,
  Skeleton,
  Stack,
  Typography,
  TextField,
  Alert,
} from "@mui/material";
import FileDownloadOutlinedIcon from "@mui/icons-material/FileDownloadOutlined";
import MapOutlinedIcon from "@mui/icons-material/MapOutlined";
import ApartmentOutlinedIcon from "@mui/icons-material/ApartmentOutlined";
import CloseIcon from "@mui/icons-material/Close";
import ChevronRightIcon from "@mui/icons-material/ChevronRight";
import Seo from "../../components/common/Seo";

// Skeleton loader component
function SkeletonCard() {
  return (
    <Card sx={{ height: "100%" }}>
      <Skeleton variant="rectangular" height={120} />
      <CardContent>
        <Skeleton width="80%" height={24} sx={{ mb: 1 }} />
        <Skeleton width="60%" height={20} />
      </CardContent>
    </Card>
  );
}

export default function HomePage() {
  const [selectedCategory, setSelectedCategory] = useState(null);
  const [isLoading, setIsLoading] = useState(false);
  const [userDetails, setUserDetails] = useState({ name: "", mobile: "" });
  const [formErrors, setFormErrors] = useState({});
  const [hasSubmittedForm, setHasSubmittedForm] = useState(false);

  // Validate mobile number (10 digits starting with 6-9)
  const validateMobile = (mobile) => {
    const mobileRegex = /^[6-9]\d{9}$/;
    return mobileRegex.test(mobile);
  };

  // Validate form
  const validateForm = () => {
    const errors = {};
    if (!userDetails.name.trim()) {
      errors.name = "Name is required";
    }
    if (!userDetails.mobile.trim()) {
      errors.mobile = "Mobile number is required";
    } else if (!validateMobile(userDetails.mobile)) {
      errors.mobile = "Please enter a valid 10-digit mobile number (starting with 6-9)";
    }
    return errors;
  };

  // Handle form submission
  const handleFormSubmit = () => {
    const errors = validateForm();
    if (Object.keys(errors).length === 0) {
      setFormErrors({});
      setHasSubmittedForm(true);
      // In production, send to backend
      console.log("User details submitted:", userDetails);
    } else {
      setFormErrors(errors);
    }
  };

  // Reset form when closing
  const handleCloseDialog = () => {
    setSelectedCategory(null);
    setHasSubmittedForm(false);
    setFormErrors({});
  };

  // Simulate loading when category is selected
  useEffect(() => {
    if (selectedCategory && hasSubmittedForm) {
      setIsLoading(true);
      const timer = setTimeout(() => setIsLoading(false), 800);
      return () => clearTimeout(timer);
    }
  }, [selectedCategory, hasSubmittedForm]);

  // Generate dummy items
  const generateDummyItems = (count) => Array.from({ length: count }, (_, i) => i + 1);
  const items = generateDummyItems(20);

  const categories = [
    {
      id: "pdf",
      name: "Project PDFs",
      description: "20 project documents and briefs",
      icon: FileDownloadOutlinedIcon,
      itemLabel: (num) => `Document ${num}`,
      itemDesc: "PDF File",
      action: "Download",
      color: "#1976d2",
    },
    {
      id: "nakhsa",
      name: "Nakhsa Maps",
      description: "20 property layout maps",
      icon: ApartmentOutlinedIcon,
      itemLabel: (num) => `Map ${num}`,
      itemDesc: "Property Layout",
      action: "View",
      color: "#388e3c",
    },
    {
      id: "dpmap",
      name: "DP Maps",
      description: "20 development plan layouts",
      icon: MapOutlinedIcon,
      itemLabel: (num) => `DP Map ${num}`,
      itemDesc: "Development Plan",
      action: "View",
      color: "#f57c00",
    },
  ];

  const activeCategory = categories.find((cat) => cat.id === selectedCategory);

  return (
    <Box sx={{ pb: 8 }}>
      <Seo
        title="Dholera Growth Evidence Platform"
        description="Project resources and property information for Dholera"
        path="/"
      />

      <Container maxWidth="lg" sx={{ pt: { xs: 4, md: 8 } }}>
        {/* Hero Section */}
        <Box sx={{ textAlign: "center", mb: 8 }}>
          <Typography
            variant="h3"
            sx={{
              fontWeight: 700,
              mb: 2,
              background: "linear-gradient(135deg, #1976d2 0%, #388e3c 100%)",
              backgroundClip: "text",
              WebkitBackgroundClip: "text",
              WebkitTextFillColor: "transparent",
            }}
          >
            Explore Project Resources
          </Typography>
          <Typography variant="h6" color="text.secondary" sx={{ maxWidth: "600px", mx: "auto" }}>
            Click on any category below to view and access 20 detailed resources
          </Typography>
        </Box>

        {/* Three Main Category Buttons */}
        <Grid container spacing={3} sx={{ mb: 6 }}>
          {categories.map((category) => {
            const Icon = category.icon;
            return (
              <Grid item xs={12} sm={6} md={4} key={category.id}>
                <Card
                  onClick={() => setSelectedCategory(category.id)}
                  sx={{
                    height: "100%",
                    cursor: "pointer",
                    transition: "all 0.3s ease",
                    border: selectedCategory === category.id ? `3px solid ${category.color}` : "1px solid #e0e0e0",
                    "&:hover": {
                      transform: "translateY(-8px)",
                      boxShadow: 4,
                      borderColor: category.color,
                    },
                    py: 4,
                  }}
                >
                  <CardContent sx={{ textAlign: "center" }}>
                    <Icon sx={{ fontSize: 64, color: category.color, mb: 2 }} />
                    <Typography variant="h6" sx={{ fontWeight: 700, mb: 1 }}>
                      {category.name}
                    </Typography>
                    <Typography color="text.secondary" sx={{ mb: 3 }}>
                      {category.description}
                    </Typography>
                    <Button
                      endIcon={<ChevronRightIcon />}
                      sx={{
                        background: category.color,
                        color: "white",
                        "&:hover": { background: category.color, opacity: 0.9 },
                      }}
                    >
                      Open
                    </Button>
                  </CardContent>
                </Card>
              </Grid>
            );
          })}
        </Grid>
      </Container>

      {/* Dialog to show form first, then 20 items */}
      <Dialog
        open={!!selectedCategory}
        onClose={handleCloseDialog}
        maxWidth="lg"
        fullWidth
        fullScreen={false}
        sx={{ "& .MuiDialog-paper": { maxHeight: "90vh" } }}
      >
        {activeCategory && (
          <>
            <DialogTitle
              sx={{
                display: "flex",
                justifyContent: "space-between",
                alignItems: "center",
                background: activeCategory.color,
                color: "white",
              }}
            >
              <Stack direction="row" alignItems="center" spacing={1}>
                {activeCategory.icon && (
                  <activeCategory.icon sx={{ fontSize: 28 }} />
                )}
                <Typography variant="h6">{activeCategory.name}</Typography>
              </Stack>
              <Button onClick={handleCloseDialog} sx={{ color: "white", minWidth: "auto", p: 0 }}>
                <CloseIcon />
              </Button>
            </DialogTitle>

            <DialogContent sx={{ pt: 3 }}>
              {!hasSubmittedForm ? (
                // Form Section
                <Box sx={{ maxWidth: "500px", mx: "auto" }}>
                  <Typography variant="h6" sx={{ mb: 1, fontWeight: 700 }}>
                    Verify Your Details
                  </Typography>
                  <Typography color="text.secondary" sx={{ mb: 3 }}>
                    Please enter your details to access {activeCategory.name}
                  </Typography>

                  <Stack spacing={2}>
                    <TextField
                      label="Full Name"
                      fullWidth
                      size="small"
                      value={userDetails.name}
                      onChange={(e) => {
                        setUserDetails({ ...userDetails, name: e.target.value });
                        if (formErrors.name) {
                          setFormErrors({ ...formErrors, name: "" });
                        }
                      }}
                      error={!!formErrors.name}
                      helperText={formErrors.name}
                      placeholder="e.g., Rajesh Kumar"
                    />

                    <TextField
                      label="Mobile Number"
                      fullWidth
                      size="small"
                      type="tel"
                      value={userDetails.mobile}
                      onChange={(e) => {
                        const value = e.target.value.replace(/\D/g, "").slice(0, 10);
                        setUserDetails({ ...userDetails, mobile: value });
                        if (formErrors.mobile) {
                          setFormErrors({ ...formErrors, mobile: "" });
                        }
                      }}
                      error={!!formErrors.mobile}
                      helperText={formErrors.mobile || "10-digit mobile number"}
                      placeholder="e.g., 9876543210"
                      inputProps={{ maxLength: 10 }}
                    />

                    {Object.keys(formErrors).length > 0 && (
                      <Alert severity="error">
                        Please fix the errors above to continue
                      </Alert>
                    )}
                  </Stack>
                </Box>
              ) : isLoading ? (
                // Loading State
                <Grid container spacing={2}>
                  {generateDummyItems(20).map((i) => (
                    <Grid item xs={12} sm={6} md={4} lg={3} key={i}>
                      <SkeletonCard />
                    </Grid>
                  ))}
                </Grid>
              ) : (
                // Resources Grid
                <Grid container spacing={2}>
                  {items.map((item) => (
                    <Grid item xs={12} sm={6} md={4} lg={3} key={item}>
                      <Card sx={{ height: "100%", cursor: "pointer", "&:hover": { boxShadow: 3 } }}>
                        <CardContent sx={{ textAlign: "center", py: 3 }}>
                          <activeCategory.icon
                            sx={{ fontSize: 48, color: activeCategory.color, mb: 1.5 }}
                          />
                          <Typography variant="subtitle2" sx={{ fontWeight: 600, mb: 0.5 }}>
                            {activeCategory.itemLabel(item)}
                          </Typography>
                          <Typography color="text.secondary" fontSize="0.85rem" sx={{ mb: 2 }}>
                            {activeCategory.itemDesc}
                          </Typography>
                          <Button
                            size="small"
                            variant="contained"
                            sx={{ background: activeCategory.color }}
                            onClick={() => {
                              // In production, replace with actual file URL
                              const fileUrl =
                                selectedCategory === "pdf"
                                  ? `/pdfs/document-${item}.pdf`
                                  : selectedCategory === "nakhsa"
                                  ? `/maps/nakhsa-${item}.jpg`
                                  : `/maps/dp-map-${item}.jpg`;
                              window.open(fileUrl, "_blank");
                            }}
                          >
                            {activeCategory.action}
                          </Button>
                        </CardContent>
                      </Card>
                    </Grid>
                  ))}
                </Grid>
              )}
            </DialogContent>

            <DialogActions sx={{ p: 2, background: "#f5f5f5" }}>
              {!hasSubmittedForm ? (
                <>
                  <Button onClick={handleCloseDialog}>Cancel</Button>
                  <Button
                    variant="contained"
                    onClick={handleFormSubmit}
                    sx={{ background: activeCategory.color }}
                  >
                    Continue
                  </Button>
                </>
              ) : (
                <Button onClick={handleCloseDialog}>Close</Button>
              )}
            </DialogActions>
          </>
        )}
      </Dialog>
    </Box>
  );
}
