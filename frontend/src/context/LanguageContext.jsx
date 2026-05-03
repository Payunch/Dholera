import { createContext, useContext, useState } from "react";
import { uiCopy } from "../content/uiCopy";

const LanguageContext = createContext(null);

export function LanguageProvider({ children }) {
  const [locale, setLocale] = useState(() => window.localStorage.getItem("site_locale") || "en");

  const updateLocale = (value) => {
    setLocale(value);
    window.localStorage.setItem("site_locale", value);
  };

  const value = {
    locale,
    setLocale: updateLocale,
    t: (key) => uiCopy[locale]?.[key] || uiCopy.en[key] || key,
  };

  return <LanguageContext.Provider value={value}>{children}</LanguageContext.Provider>;
}

export function useLanguage() {
  const context = useContext(LanguageContext);
  if (!context) {
    throw new Error("useLanguage must be used within LanguageProvider");
  }
  return context;
}
