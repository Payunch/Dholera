import React from 'react';
import LegalDocument from '../components/LegalDocument';

const sections = [
  {
    title: '1. Information We Collect',
    paragraphs: [
      'When you use this portal, submit an inquiry, verify access, or view gated documents, we may collect the information needed to operate the service and respond to your interest.'
    ],
    bullets: [
      'Lead details such as your name, mobile number, and email address when you submit a contact or OTP form.',
      'Verification data such as OTP status, verification timestamps, and related access tokens used to unlock protected content.',
      'Usage data such as visited pages, time spent, viewed PDFs, device type, referral source, IP address, session ID, and browser fingerprint.',
      'Communication history generated when we send OTPs, WhatsApp follow-ups, or respond to your inquiry.'
    ]
  },
  {
    title: '2. How We Use Your Information',
    bullets: [
      'To respond to your investment or planning inquiry.',
      'To verify your identity before granting access to protected project documents.',
      'To understand visitor interest, improve the website, and prioritize follow-up.',
      'To send OTP messages, WhatsApp updates, call-backs, and email responses related to your inquiry.',
      'To detect abuse, prevent unauthorized document access, and maintain audit/security logs.'
    ]
  },
  {
    title: '3. Consent and Communication',
    paragraphs: [
      'By submitting your details through this website, you consent to the collection and use of your information for inquiry management, OTP verification, and follow-up communication related to Dholera investment or planning information.'
    ],
    bullets: [
      'You may receive communication by phone, WhatsApp, or email in response to your request.',
      'If you no longer wish to receive follow-up communication, contact us and we will update your preferences where reasonably possible.'
    ]
  },
  {
    title: '4. Browser Storage, Tracking, and Fingerprinting',
    paragraphs: [
      'This website uses local storage, session storage, and similar browser-side identifiers to remember verified access, detect returning visitors, and associate browsing sessions with legitimate lead activity.'
    ],
    bullets: [
      'Session storage may be used to store temporary browsing/session state.',
      'Local storage may be used to remember verified user details and access tokens on your device.',
      'A browser fingerprint may be generated to identify repeat visitors and reduce misuse of protected document access.'
    ]
  },
  {
    title: '5. Sharing of Information',
    paragraphs: [
      'We do not sell your personal information. We may share limited data only when necessary to operate the service or comply with legal obligations.'
    ],
    bullets: [
      'Messaging and communication providers used to deliver OTPs or WhatsApp outreach.',
      'Hosting, database, or infrastructure providers that support this website.',
      'Professional advisers, law enforcement, or regulators when required by law or to protect our rights and systems.'
    ]
  },
  {
    title: '6. Retention and Security',
    paragraphs: [
      'We retain lead and activity information for as long as reasonably necessary for inquiry handling, analytics, document security, compliance, and business record-keeping. We use reasonable technical and administrative measures to protect stored information, but no system can guarantee absolute security.'
    ]
  },
  {
    title: '7. Your Choices',
    bullets: [
      'You may request correction or deletion of the personal information you previously submitted, subject to legal, operational, and security requirements.',
      'You may clear local browser storage on your device, although this can remove remembered access state and may require fresh verification.',
      'You may stop using the site at any time, but protected content may remain unavailable without verification.'
    ]
  },
  {
    title: '8. Children',
    paragraphs: [
      'This website is intended for adults evaluating land, planning, or investment opportunities. It is not directed to children, and we do not knowingly collect personal data from minors.'
    ]
  },
  {
    title: '9. Changes to This Policy',
    paragraphs: [
      'We may update this Privacy Policy when the website, lead process, or legal requirements change. The revised version becomes effective when posted on this page.'
    ]
  }
];

const PrivacyPolicy = () => {
  return (
    <LegalDocument
      title="Privacy Policy"
      description="How Dholera Portal collects, uses, and protects inquiry, verification, and visitor-tracking data."
      path="/privacy-policy"
      scopeLabel="Applies to lead, contact, and tracking data"
      intro="This Privacy Policy explains how Dholera Portal handles personal information collected through inquiry forms, OTP verification, visitor tracking, and secure document access."
      sections={sections}
    />
  );
};

export default PrivacyPolicy;
