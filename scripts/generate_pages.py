import os

PAGES = [
    {
        "filename": "government_schemes_page.dart",
        "classname": "GovernmentSchemesPage",
        "title": "Government Schemes & Policies",
        "tag": "POLICY & INCENTIVES",
        "hero_image": "https://api.dholeraplatform.com/uploads/images/futuristic_dholera.png",
        "header": "GUJARAT GOVERNMENT SUBSIDIES",
        "desc": "Explore the range of state and central government incentives available for industries and residents in Dholera SIR."
    },
    {
        "filename": "investment_guide_page.dart",
        "classname": "InvestmentGuidePage",
        "title": "Investment Guide",
        "tag": "HOW TO INVEST",
        "hero_image": "https://api.dholeraplatform.com/uploads/images/futuristic_dholera.png",
        "header": "STEP-BY-STEP INVESTMENT PROCESS",
        "desc": "Your comprehensive guide to acquiring land, navigating regulations, and setting up business in Dholera."
    },
    {
        "filename": "plots_for_sale_page.dart",
        "classname": "PlotsForSalePage",
        "title": "Plots for Sale",
        "tag": "REAL ESTATE",
        "hero_image": "https://api.dholeraplatform.com/uploads/images/futuristic_dholera.png",
        "header": "VERIFIED COMMERCIAL & RESIDENTIAL PLOTS",
        "desc": "Browse our curated list of RERA-approved plots in Town Planning areas of Dholera Smart City."
    },
    {
        "filename": "smart_city_page.dart",
        "classname": "SmartCityPage",
        "title": "Smart City Features",
        "tag": "INFRASTRUCTURE",
        "hero_image": "https://api.dholeraplatform.com/uploads/images/futuristic_dholera.png",
        "header": "THE CITY OF THE FUTURE",
        "desc": "Discover the IoT-enabled infrastructure, smart grids, and sustainable design powering Dholera."
    },
    {
        "filename": "travel_lifestyle_page.dart",
        "classname": "TravelLifestylePage",
        "title": "Travel & Lifestyle",
        "tag": "LIVING IN DHOLERA",
        "hero_image": "https://api.dholeraplatform.com/uploads/images/futuristic_dholera.png",
        "header": "CONNECTIVITY & LEISURE",
        "desc": "Information on the upcoming international airport, expressway, and lifestyle amenities."
    },
    {
        "filename": "privacy_policy_page.dart",
        "classname": "PrivacyPolicyPage",
        "title": "Privacy Policy",
        "tag": "LEGAL",
        "hero_image": "",
        "header": "OUR PRIVACY POLICY",
        "desc": "How we collect, use, and protect your personal information on the Dholera Platform."
    },
    {
        "filename": "terms_page.dart",
        "classname": "TermsPage",
        "title": "Terms & Conditions",
        "tag": "LEGAL",
        "hero_image": "",
        "header": "TERMS OF SERVICE",
        "desc": "Please read these terms and conditions carefully before using our services."
    }
]

TEMPLATE = """import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'contact_page.dart';

class {classname} extends StatefulWidget {{
  const {classname}({{super.key}});

  @override
  State<{classname}> createState() => _{classname}State();
}}

class _{classname}State extends State<{classname}> {{
  final ApiService _apiService = ApiService();

  @override
  void initState() {{
    super.initState();
    _apiService.trackActivity('{title}');
  }}

  @override
  Widget build(BuildContext context) {{
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: {expanded_height},
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('{title}', style: TextStyle(fontSize: 16)),
              {background_code}
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTag('{tag}'),
                  const SizedBox(height: 20),
                  const Text(
                    '{header}',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, height: 1.1),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '{desc}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16, height: 1.6),
                  ),
                  const SizedBox(height: 40),
                  _buildContentPlaceholder(),
                  const SizedBox(height: 40),
                  _buildCTA(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }}

  Widget _buildTag(String text) {{
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
    );
  }}

  Widget _buildContentPlaceholder() {{
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.construction, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "Detailed content coming soon.",
              style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }}

  Widget _buildCTA() {{
    return Container(
      padding: const EdgeInsets.all(32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0B132B),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text(
            'HAVE QUESTIONS?',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, height: 1.2),
          ),
          const SizedBox(height: 16),
          const Text(
            'Our experts are here to help you navigate Dholera.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 14, letterSpacing: 0.5),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactPage())),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('CONTACT US', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }}
}}
"""

for page in PAGES:
    filepath = f"c:/Desktop/JR/Dholera/Dholera/lib/pages/{page['filename']}"
    
    if page['hero_image']:
        background_code = f"""background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    '{page['hero_image']}',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0B132B)),
                  ),
                  Container(color: Colors.black.withOpacity(0.6)),
                ],
              ),"""
        expanded_height = "250"
    else:
        background_code = ""
        expanded_height = "60"

    content = TEMPLATE.format(
        classname=page["classname"],
        title=page["title"],
        tag=page["tag"],
        header=page["header"],
        desc=page["desc"],
        expanded_height=expanded_height,
        background_code=background_code
    )
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Generated {filepath}")
