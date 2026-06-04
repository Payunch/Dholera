import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/portal.dart';
import '../services/api_service.dart';
import '../blocs/localization/localization_bloc.dart';
import '../blocs/localization/localization_state.dart';

class PortalsPage extends StatefulWidget {
  const PortalsPage({super.key});

  @override
  State<PortalsPage> createState() => _PortalsPageState();
}

class _PortalsPageState extends State<PortalsPage> {
  final ApiService _apiService = ApiService();
  Map<String, List<Portal>> _groupedPortals = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPortals();
    _apiService.trackActivity('Portals Directory');
  }

  Future<void> _fetchPortals() async {
    final response = await _apiService.getPortals();
    if (response['success'] == true) {
      final List<Portal> allPortals = (response['portals'] as List)
          .map((json) => Portal.fromJson(json))
          .toList();
      
      final Map<String, List<Portal>> grouped = {};
      for (var p in allPortals) {
        if (!grouped.containsKey(p.category)) {
          grouped[p.category] = [];
        }
        grouped[p.category]!.add(p);
      }

      setState(() {
        _groupedPortals = grouped;
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
            title: const Text('OFFICIAL PORTALS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: _groupedPortals.entries.map((entry) => _buildCategorySection(entry.key, entry.value)).toList(),
                ),
        );
      },
    );
  }

  Widget _buildCategorySection(String category, List<Portal> portals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.toUpperCase(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        if (portals.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 20),
            child: Text(
              portals.first.categorySubtitle,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
        ...portals.map((p) => _buildPortalCard(p)),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildPortalCard(Portal portal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      color: Colors.grey[50],
      child: InkWell(
        onTap: () => _launchUrl(portal.url),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      portal.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const Icon(Icons.open_in_new, size: 16, color: Colors.orange),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                portal.desc,
                style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.verified_user, size: 12, color: Colors.green),
                  SizedBox(width: 4),
                  Text('OFFICIAL GOVERNMENT LINK', style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
