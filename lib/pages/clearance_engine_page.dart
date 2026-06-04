import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/localization/localization_bloc.dart';
import '../blocs/localization/localization_state.dart';
import '../services/api_service.dart';

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

  void _calculate() {
    final size = double.tryParse(_sizeController.text);
    if (size == null) return;

    double baseRate = 0;
    switch (_useType) {
      case 'residential': baseRate = 150; break;
      case 'industrial': baseRate = 80; break;
      case 'commercial': baseRate = 250; break;
    }

    setState(() {
      _calculatedFee = size * baseRate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalizationBloc, LocalizationState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(state.translate('nav_clearance')),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHero(state),
                const SizedBox(height: 32),
                _buildCalculatorCard(state),
                if (_calculatedFee != null) _buildResultCard(state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHero(LocalizationState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          state.translate('clearance_hero_title'),
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          state.translate('clearance_hero_subtitle'),
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildCalculatorCard(LocalizationState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calculate, color: Colors.orange),
              const SizedBox(width: 8),
              Text(state.translate('fee_engine_title'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 8),
          Text(state.translate('fee_engine_desc'), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          const SizedBox(height: 24),
          const Text('Plot Size (Sq. Yards)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          TextField(
            controller: _sizeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'e.g. 500',
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            onChanged: (_) => _calculate(),
          ),
          const SizedBox(height: 24),
          const Text('Use Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 12),
          _buildTypeSelector(),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('RUN ALGORITHMIC ESTIMATE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
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
                color: isSelected ? Colors.orange : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  type.toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResultCard(LocalizationState state) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0B132B), Color(0xFF1C2541)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text('ESTIMATED SCRUTINY FEE', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 12),
          Text(
            '₹${_calculatedFee!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            style: const TextStyle(color: Colors.orange, fontSize: 36, fontWeight: FontWeight.black),
          ),
          const SizedBox(height: 12),
          const Text(
            '*Note: This is an algorithmic estimate based on base GDCR rates. Actual fees may vary.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white30, fontSize: 9),
          ),
        ],
      ),
    );
  }
}
