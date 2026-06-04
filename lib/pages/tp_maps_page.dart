import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/tp_map.dart';
import '../services/api_service.dart';
import '../blocs/localization/localization_bloc.dart';
import '../blocs/localization/localization_state.dart';
import 'pdf_manager_page.dart'; // Or a specific PDF viewer

class TpMapsPage extends StatefulWidget {
  const TpMapsPage({super.key});

  @override
  State<TpMapsPage> createState() => _TpMapsPageState();
}

class _TpMapsPageState extends State<TpMapsPage> {
  final ApiService _apiService = ApiService();
  List<TpMap> _tpMaps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTpMaps();
    _apiService.trackActivity('TP Maps List');
  }

  Future<void> _fetchTpMaps() async {
    final response = await _apiService.getTpMaps();
    if (response['success'] == true) {
      setState(() {
        _tpMaps = (response['tpMaps'] as List)
            .map((json) => TpMap.fromJson(json))
            .toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalizationBloc, LocalizationState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(state.translate('tp_maps_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _tpMaps.isEmpty
                  ? const Center(child: Text('No TP maps found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _tpMaps.length,
                      itemBuilder: (context, index) => _buildTpCard(_tpMaps[index], state),
                    ),
        );
      },
    );
  }

  Widget _buildTpCard(TpMap tp, LocalizationState state) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.map_outlined, size: 28),
                ),
                Wrap(
                  spacing: 8,
                  children: tp.badges.map((badge) {
                    final isCompliance = badge['type'] == 'compliance';
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCompliance ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badge['text'].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              tp.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.layers, tp.area),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.shield, tp.focus, iconColor: Colors.orange),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to PDF list with filter or search
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('EXPLORE DATA MATRIX', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {Color? iconColor}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor ?? Colors.grey[400]),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: iconColor ?? Colors.grey[600]),
        ),
      ],
    );
  }
}
