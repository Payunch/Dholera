export const CATEGORY_OPTIONS = [
  "Expressway",
  "Industrial",
  "Corridor",
  "Construction",
  "Planning",
  "Government",
  "Activity",
  "Video",
];

const localized = (en, hi, gu) => ({ en, hi, gu });

export const heroMetrics = [
  {
    stat: "Priority Corridors",
    label: localized(
      "Expressway, industrial and planning signals in one view.",
      "एक्सप्रेसवे, औद्योगिक और प्लानिंग संकेत एक ही दृश्य में।",
      "એક્સપ્રેસવે, ઔદ્યોગિક અને આયોજન સંકેતો એક જ દ્રશ્યમાં."
    ),
  },
  {
    stat: "Trust-Led Feed",
    label: localized(
      "Updates are structured to reduce uncertainty before inquiry.",
      "पूछताछ से पहले अनिश्चितता कम करने के लिए अपडेट्स व्यवस्थित हैं।",
      "ઇન્ક્વાયરી પહેલાં અનિશ્ચિતતા ઘટાડવા માટે અપડેટ્સ ગોઠવાયેલા છે."
    ),
  },
  {
    stat: "Mobile First",
    label: localized(
      "Fast tap targets for WhatsApp, site visits, and brief requests.",
      "व्हाट्सऐप, साइट विजिट और ब्रीफ रिक्वेस्ट के लिए तेज़ टच CTA.",
      "વોટ્સએપ, સાઇટ વિઝિટ અને બ્રીફ રિક્વેસ્ટ માટે ઝડપી CTA."
    ),
  },
];

export const growthDrivers = [
  {
    title: localized("Infrastructure corridor visibility", "इन्फ्रास्ट्रक्चर कॉरिडोर दृश्यता", "ઇન્ફ્રાસ્ટ્રક્ચર કોરિડોર દૃશ્યતા"),
    description: localized(
      "Visible corridor references help visitors interpret the area as an active, advancing zone rather than a distant speculation story.",
      "कॉरिडोर संदर्भ आगंतुकों को क्षेत्र को सक्रिय प्रगति ज़ोन के रूप में देखने में मदद करते हैं।",
      "કોરિડોર સંદર્ભો મુલાકાતીઓને વિસ્તારને સક્રિય પ્રગતિ ઝોન તરીકે સમજવામાં મદદ કરે છે."
    ),
  },
  {
    title: localized("Industrial movement nearby", "निकट औद्योगिक गतिविधि", "નજીકની ઔદ્યોગિક ગતિ"),
    description: localized(
      "Industry-linked movement is one of the strongest trust levers for land investors evaluating longer time horizons.",
      "लंबी अवधि के निवेशकों के लिए औद्योगिक संकेत सबसे मजबूत भरोसा-कारकों में से एक हैं।",
      "લાંબા ગાળાના જમીન રોકાણકારો માટે ઔદ્યોગિક ગતિ સૌથી મજબૂત વિશ્વાસ કારકોમાંની એક છે."
    ),
  },
  {
    title: localized("Map-led decision support", "मैप आधारित निर्णय सहायता", "મેપ આધારિત નિર્ણય સહાય"),
    description: localized(
      "Distance cues, DP maps and location context help prospects move from curiosity to comparison quickly.",
      "डिस्टेंस संकेत, DP मैप्स और लोकेशन संदर्भ जिज्ञासा से तुलना तक की यात्रा तेज़ करते हैं।",
      "ડિસ્ટન્સ સંકેતો, DP મેપ્સ અને લોકેશન સંદર્ભ રસથી સરખામણી સુધી ઝડપ લાવે છે."
    ),
  },
  {
    title: localized("Planning activity momentum", "प्लानिंग गतिविधि की गति", "આયોજન પ્રવૃત્તિની ગતિ"),
    description: localized(
      "Repeated planning and government-linked references create the psychological signal of an area becoming more important.",
      "दोहराए गए प्लानिंग और सरकारी संदर्भ क्षेत्र के महत्व बढ़ने का मनोवैज्ञानिक संकेत बनाते हैं।",
      "વારંવારના આયોજન અને સરકારી સંદર્ભો વિસ્તાર મહત્ત્વ પામી રહ્યો હોવાનો સંકેત આપે છે."
    ),
  },
];

export const connectivitySignals = [
  {
    title: localized("Google map orientation", "गूगल मैप ओरिएंटेशन", "ગૂગલ મેપ ઓરિએન્ટેશન"),
    description: localized(
      "Visitors can anchor the corridor story with a familiar map reference before requesting a detailed pack.",
      "विस्तृत पैक मांगने से पहले उपयोगकर्ता परिचित मैप संदर्भ से कॉरिडोर समझ सकते हैं।",
      "વિગતવાર પેક માંગતા પહેલાં મુલાકાતી ઓળખી શકાય એવા મેપ સંદર્ભથી કોરિડોર સમજી શકે છે."
    ),
  },
  {
    title: localized("Nearby industrial references", "नज़दीकी औद्योगिक संदर्भ", "નજીકના ઔદ્યોગિક સંદર્ભ"),
    description: localized(
      "Industrial anchors help explain why land attention may compound over time.",
      "औद्योगिक एंकर बताते हैं कि समय के साथ भूमि पर ध्यान क्यों बढ़ सकता है।",
      "ઔદ્યોગિક એન્કર સમજાવે છે કે સમય સાથે જમીન પર ધ્યાન કેમ વધે છે."
    ),
  },
  {
    title: localized("Distance-based confidence", "दूरी आधारित भरोसा", "અંતર આધારિત વિશ્વાસ"),
    description: localized(
      "Clear distance indicators reduce ambiguity and make site visits easier to imagine.",
      "स्पष्ट दूरी संकेत भ्रम कम करते हैं और साइट विजिट की कल्पना आसान बनाते हैं।",
      "સ્પષ્ટ અંતર સંકેતો ગૂંચવણ ઘટાડે છે અને સાઇટ વિઝિટ કલ્પવી સરળ બનાવે છે."
    ),
  },
];

export const mapResources = [
  {
    title: localized("DP Maps Pack", "DP मैप्स पैक", "DP મેપ્સ પેક"),
    description: localized(
      "Use the request flow to receive the planning map set relevant to your corridor and access questions.",
      "अपनी कॉरिडोर और एक्सेस संबंधी ज़रूरत के लिए प्लानिंग मैप सेट प्राप्त करें।",
      "તમારા કોરિડોર અને ઍક્સેસ પ્રશ્નો માટે આયોજન મેપ સેટ મેળવો."
    ),
    distance: "12-25 km reference bands",
  },
  {
    title: localized("Expressway Context Layer", "एक्सप्रेसवे कॉन्टेक्स्ट लेयर", "એક્સપ્રેસવે કોન્ટેક્સ્ટ લેયર"),
    description: localized(
      "A corridor-first view built for investors who want to understand frontage and movement narratives.",
      "फ्रंटेज और मूवमेंट स्टोरी समझने वालों के लिए कॉरिडोर-प्रथम दृश्य।",
      "ફ્રન્ટેજ અને મૂવમેન્ટ વાર્તા સમજવા ઇચ્છુક રોકાણકારો માટે કોરિડોર-ફર્સ્ટ દૃશ્ય."
    ),
    distance: "Frontage and access cues",
  },
  {
    title: localized("Industrial Adjacency View", "औद्योगिक निकटता दृश्य", "ઔદ્યોગિક નજીકતા દૃશ્ય"),
    description: localized(
      "Nearby industries and planning signals arranged to strengthen long-term confidence.",
      "नज़दीकी उद्योग और प्लानिंग संकेत लंबी अवधि के भरोसे को मजबूत करने के लिए।",
      "નજીકના ઉદ્યોગો અને આયોજન સંકેતો લાંબા ગાળાના વિશ્વાસને મજબૂત કરવા માટે."
    ),
    distance: "Operational influence zones",
  },
];

export const futureMilestones = [
  {
    year: "Now",
    title: localized("Visible corridor intelligence", "दृश्यमान कॉरिडोर इंटेलिजेंस", "દૃશ્યમાન કોરિડોર ઇન્ટેલિજન્સ"),
    description: localized(
      "Make current infrastructure and planning references easy to verify for high-intent prospects.",
      "उच्च-इरादा निवेशकों के लिए मौजूदा संदर्भों को आसानी से सत्यापित योग्य बनाना।",
      "ઉચ્ચ ઇરાદાવાળા રોકાણકારો માટે વર્તમાન સંદર્ભો સરળતાથી ચકાસી શકાય તેવા બનાવો."
    ),
  },
  {
    year: "Next",
    title: localized("Site-visit ready qualification", "साइट विजिट तैयार क्वालिफिकेशन", "સાઇટ-વિઝિટ તૈયાર ક્વોલિફિકેશન"),
    description: localized(
      "Move prospects from reading to map comparison to scheduled site visits with fewer unanswered questions.",
      "कम अनुत्तरित प्रश्नों के साथ रीडिंग से मैप तुलना और फिर साइट विजिट तक ले जाएँ।",
      "ઓછા અનઉત્તરિત પ્રશ્નો સાથે વાંચનથી મેપ તુલના અને સાઇટ વિઝિટ સુધી આગળ વધો."
    ),
  },
  {
    year: "Later",
    title: localized("Repeatable acquisition engine", "दोहराने योग्य अधिग्रहण इंजन", "પુનરાવર્તિત એક્વિઝિશન એન્જિન"),
    description: localized(
      "Use structured updates, WhatsApp follow-up and lead tagging to sustain three-digit acquisition goals.",
      "संरचित अपडेट्स, व्हाट्सऐप फॉलो-अप और लीड टैगिंग से 3-अंकीय अधिग्रहण लक्ष्य को बनाए रखें।",
      "રચનાત્મક અપડેટ્સ, વોટ્સએપ ફોલો-અપ અને લીડ ટૅગિંગથી 3-અંકીય એક્વિઝિશન લક્ષ્ય જાળવો."
    ),
  },
];

export const nearbyIndustries = [
  { name: "Expressway Access Spine", distance: "Approx. 8 km" },
  { name: "Planned Industrial Influence Belt", distance: "Approx. 14 km" },
  { name: "Regional Utility / Logistics Node", distance: "Approx. 21 km" },
  { name: "Government Planning Reference Zone", distance: "Approx. 26 km" },
];

export const footerHighlights = [
  "Lead generation built around trust and evidence",
  "Multilingual updates for English, Hindi, and Gujarati",
  "Fast WhatsApp and site-visit conversion paths",
];

