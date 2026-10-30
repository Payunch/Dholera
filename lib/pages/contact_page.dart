import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../blocs/localization/localization_bloc.dart';
import '../blocs/localization/localization_state.dart';
import '../services/api_service.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _apiService.trackActivity('Contact Us');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final message = _messageController.text.trim();

    setState(() => _isSubmitting = true);

    try {
      await _apiService.createLead({
        'name': name,
        'phone': phone,
        'message': message,
        'tags': ['mobile', 'app_contact'],
        'status': 'new',
        'source': 'flutter_app',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inquiry submitted successfully! Our Dholera SIR investment desk will contact you shortly.'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        _nameController.clear();
        _phoneController.clear();
        _messageController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<LocalizationBloc, LocalizationState>(
      builder: (context, state) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'CONTACT US',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  centerTitle: true,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/free-visit.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFF1E293B),
                        ),
                      ),
                      Container(color: Colors.black.withValues(alpha: 0.65)),
                      const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'GET IN TOUCH',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Direct Investor Desk & TP Intelligence',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCards(isDark),
                      const SizedBox(height: 36),
                      Text(
                        'SCHEDULE SITE VISIT & CONSULTATION',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: isDark ? Colors.amber.shade300 : const Color(0xFFD97706),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Leave your details below. An authorized Dholera SIR specialist will share verified plot catalogs and land records.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.black87,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildForm(isDark),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCards(bool isDark) {
    return Column(
      children: [
        _buildInfoTile(
          icon: Icons.phone_in_talk,
          label: 'Direct Consultation Helpline',
          value: '+91 8200448270',
          isDark: isDark,
          iconColor: Colors.green,
          onTap: () => _launchUrl('tel:+918200448270'),
        ),
        const SizedBox(height: 12),
        _buildInfoTile(
          icon: Icons.chat_bubble_outline,
          label: 'WhatsApp Investor Desk',
          value: 'Chat with Senior Advisor',
          isDark: isDark,
          iconColor: const Color(0xFF25D366),
          onTap: () => _launchUrl('https://wa.me/918200448270?text=Hello%20Dholera%20Desk%2C%20I%20would%20like%20to%20know%20more%20about%20investment%20opportunities%20in%20Dholera%20SIR.'),
        ),
        const SizedBox(height: 12),
        _buildInfoTile(
          icon: Icons.mail_outline,
          label: 'Official Inquiries',
          value: 'gohelnaresh7707@gmail.com',
          isDark: isDark,
          iconColor: Colors.blueAccent,
          onTap: () => _launchUrl('mailto:gohelnaresh7707@gmail.com'),
        ),
        const SizedBox(height: 12),
        _buildInfoTile(
          icon: Icons.location_on_outlined,
          label: 'Regional Office',
          value: 'Dholera SIR, Ahmedabad District, Gujarat, India',
          isDark: isDark,
          iconColor: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    final bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 13,
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            hint: 'Your Full Name',
            icon: Icons.person_outline,
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _phoneController,
            hint: 'Mobile Number (10 Digits)',
            icon: Icons.phone_android_outlined,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            isDark: isDark,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Phone number is required';
              if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v)) {
                return 'Please enter a valid 10-digit mobile number';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _messageController,
            hint: 'Describe your requirement (e.g. Residential plot in TP2, Industrial plot, Budget)',
            icon: Icons.chat_bubble_outline,
            maxLines: 4,
            isDark: isDark,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFFF59E0B) : const Color(0xFF0F172A),
                foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: isDark ? const Color(0xFF0F172A) : Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'REQUEST FREE SITE VISIT & CALLBACK',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    final fillColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF0F172A),
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? Colors.grey[500] : Colors.grey[400],
          fontSize: 13.5,
        ),
        prefixIcon: Icon(icon, size: 20, color: isDark ? Colors.grey[400] : Colors.grey[500]),
        filled: true,
        fillColor: fillColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: isDark ? const Color(0xFFF59E0B) : const Color(0xFF0F172A), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        counterText: '',
      ),
      validator: validator ?? ((v) => (v == null || v.isEmpty) ? 'Required' : null),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
