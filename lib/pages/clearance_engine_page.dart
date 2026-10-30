import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/localization/localization_bloc.dart';
import '../blocs/localization/localization_state.dart';
import '../services/api_service.dart';
import 'contact_page.dart';

class ClearanceEnginePage extends StatefulWidget {
  const ClearanceEnginePage({super.key});

  @override
  State<ClearanceEnginePage> createState() => _ClearanceEnginePageState();
}

class _ClearanceEnginePageState extends State<ClearanceEnginePage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _sizeController = TextEditingController();
  String _useType = 'residential';
  double? _calculatedFee;

  @override
  void initState() {
    super.initState();
    _apiService.trackActivity('Clearance Engine');
  }

  @override
  void dispose() {
    _sizeController.dispose();
    super.dispose();
  }

  void _calculate() {
    final size = double.tryParse(_sizeController.text);
    if (size == null) {
      setState(() => _calculatedFee = null);
      return;
    }

    double baseRate = 0;
    switch (_useType) {
      case 'residential':
        baseRate = 150;
        break;
      case 'industrial':
        baseRate = 80;
        break;
      case 'commercial':
        baseRate = 250;
        break;
    }

    setState(() {
      _calculatedFee = size * baseRate;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<LocalizationBloc, LocalizationState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0B132B) : const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: Text(
              state.translate('nav_clearance'),
              style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHero(state, isDark),
                const SizedBox(height: 28),
                _buildCalculatorCard(state, isDark),
                if (_calculatedFee != null) ...[
                  const SizedBox(height: 24),
                  _buildResultCard(state, isDark),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHero(LocalizationState state, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          state.translate('clearance_hero_title'),
          style: GoogleFonts.inter(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          state.translate('clearance_hero_subtitle'),
          style: TextStyle(
            color: isDark ? Colors.blueGrey[200] : Colors.grey[600],
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCalculatorCard(LocalizationState state, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2541) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? const Color(0xFF3A506B) : Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calculate, color: Color(0xFFFF7A00), size: 24),
              const SizedBox(width: 10),
              Text(
                state.translate('fee_engine_title'),
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            state.translate('fee_engine_desc'),
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 20),
          Text(
            'Plot Size (Sq. Yards)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: isDark ? Colors.grey[300] : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _sizeController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: 'e.g. 500',
              hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
              filled: true,
              fillColor: isDark ? const Color(0xFF0B132B) : const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: isDark ? const Color(0xFF3A506B) : Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: isDark ? const Color(0xFF3A506B) : Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFFF7A00), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: (_) => _calculate(),
          ),
          const SizedBox(height: 20),
          Text(
            'Use Category',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: isDark ? Colors.grey[300] : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 10),
          _buildTypeSelector(isDark),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7A00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
              ),
              child: const Text('CALCULATE ESTIMATE'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(bool isDark) {
    final types = ['residential', 'commercial', 'industrial'];
    return Row(
      children: types.map((type) {
        final isSelected = _useType == type;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _useType = type);
              _calculate();
            },
            child: Container(
              margin: EdgeInsets.only(right: type != types.last ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFF7A00)
                    : (isDark ? const Color(0xFF0B132B) : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFF7A00)
                      : (isDark ? const Color(0xFF3A506B) : Colors.grey[300]!),
                ),
              ),
              child: Center(
                child: Text(
                  type.toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[700]),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResultCard(LocalizationState state, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0B132B), Color(0xFF1C2541)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFF7A00).withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Text(
            'ESTIMATED SCRUTINY FEE',
            style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 10),
          Text(
            '₹${_calculatedFee!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            style: const TextStyle(color: Color(0xFFFF7A00), fontSize: 34, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          const Text(
            '*Note: This is an algorithmic estimate based on base GDCR scrutiny rates. Exact clearance fees may vary based on FSI and road frontage.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 9, height: 1.4),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactPage()),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFFF7A00)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('REQUEST OFFICIAL SCRUTINY BREAKDOWN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
            ),
          ),
        ],
      ),
    );
  }
}
