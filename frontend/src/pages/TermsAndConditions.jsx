import React from 'react';
import LegalDocument from '../components/LegalDocument';

const sections = [
  {
    title: '1. Acceptance of Terms',
    paragraphs: [
      'By accessing or using Dholera Portal, you agree to these Terms & Conditions. If you do not agree, please do not use the website or submit your personal information through it.'
    ]
  },
  {
    title: '2. Purpose of the Website',
    paragraphs: [
      'This website is designed to share Dholera-related planning, infrastructure, and investment information, collect inquiries, verify users before giving access to selected documents, and help the project team respond to interested visitors.'
    ]
  },
  {
    title: '3. User Responsibilities',
    bullets: [
      'Provide true, current, and complete information when submitting any form.',
      'Use only your own mobile number and email address for inquiry or verification.',
      'Do not attempt to bypass OTP checks, gated access, tracking controls, or security measures.',
      'Do not misuse the website for unlawful, fraudulent, or disruptive activity.'
    ]
  },
  {
    title: '4. OTP Verification and Secure Access',
    paragraphs: [
      'Certain project documents or resources may only be available after OTP verification. Access is granted for legitimate review purposes and may be restricted, suspended, or revoked if misuse is suspected.'
    ],
    bullets: [
      'Verification codes are time-limited and must not be requested abusively.',
      'Protected documents may be displayed with identity-linked information such as phone number or email as part of content protection.',
      'You must not redistribute, capture, resell, or publicly republish gated materials without permission.'
    ]
  },
  {
    title: '5. Inquiry and Communication Terms',
    paragraphs: [
      'If you submit a form or complete OTP verification, you authorize us to contact you regarding your inquiry, requested materials, site visits, planning information, and related follow-up.'
    ],
    bullets: [
      'Communication may occur by phone, WhatsApp, or email.',
      'Submitting an inquiry does not create an agency, advisory, fiduciary, or contractual sale relationship by itself.'
    ]
  },
  {
    title: '6. Information Disclaimer',
    paragraphs: [
      'Content on this website is provided for general informational and promotional purposes. Project status, infrastructure progress, pricing context, planning references, and opportunity summaries may change over time.'
    ],
    bullets: [
      'Nothing on the website constitutes legal, tax, financial, or investment advice.',
      'You should independently verify land records, approvals, pricing, zoning, and suitability before making decisions.',
      'We do not guarantee appreciation, returns, allocation, or transaction completion.'
    ]
  },
  {
    title: '7. Intellectual Property and Content Use',
    paragraphs: [
      'Website text, layouts, visual material, gated PDFs, and original compilations made available through the portal are protected by applicable intellectual property rights.'
    ],
    bullets: [
      'You may view content for your personal evaluation.',
      'You may not copy substantial portions, scrape, reproduce, frame, or commercially exploit the content without authorization.'
    ]
  },
  {
    title: '8. Availability and Security',
    paragraphs: [
      'We may update, suspend, or remove features, documents, or pages at any time. We may also block access where necessary to protect infrastructure, data, or business operations.'
    ]
  },
  {
    title: '9. Limitation of Liability',
    paragraphs: [
      'To the maximum extent permitted by law, Dholera Portal and its operators are not liable for indirect, incidental, special, or consequential losses arising from website use, reliance on posted information, delayed communication, or temporary unavailability of the service.'
    ]
  },
  {
    title: '10. Governing Law',
    paragraphs: [
      'These Terms & Conditions are intended to be interpreted in accordance with applicable laws of India. Any dispute connected to the website will be subject to the appropriate courts or legal forums having jurisdiction over the operator.'
    ]
  },
  {
    title: '11. Updates to These Terms',
    paragraphs: [
      'We may revise these Terms & Conditions from time to time. Continued use of the website after updated terms are posted means you accept the revised version.'
    ]
  }
];

const TermsAndConditions = () => {
  return (
    <LegalDocument
      title="Terms & Conditions"
      description="Project-specific terms for lead submission, OTP verification, secure document access, and informational use of Dholera Portal."
      path="/terms-and-conditions"
      scopeLabel="Applies to all website users"
      intro="These Terms & Conditions govern your use of Dholera Portal, including inquiry submissions, OTP-based access, and use of protected project documents."
      sections={sections}
    />
  );
};

export default TermsAndConditions;
