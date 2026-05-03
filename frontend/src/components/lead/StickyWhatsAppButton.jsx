import { Fab, Tooltip } from "@mui/material";
import WhatsAppIcon from "@mui/icons-material/WhatsApp";
import { buildWhatsAppUrl, trackEvent } from "../../utils/analytics";

export default function StickyWhatsAppButton() {
  return (
    <Tooltip title="WhatsApp inquiry">
      <Fab
        className="sticky-whatsapp"
        component="a"
        href={buildWhatsAppUrl("Hello, I would like land details, map pack, and site visit assistance.")}
        target="_blank"
        rel="noreferrer"
        color="success"
        onClick={() => trackEvent("cta_whatsapp_sticky", { location: "floating_button" })}
      >
        <WhatsAppIcon />
      </Fab>
    </Tooltip>
  );
}
