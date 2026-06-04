import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/project.dart';
import '../blocs/localization/localization_bloc.dart';
import '../blocs/localization/localization_state.dart';

class ProjectDetailPage extends StatefulWidget {
  final Project project;

  const ProjectDetailPage({super.key, required this.project});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _apiService.trackActivity('Project: ${widget.project.name}');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalizationBloc, LocalizationState>(
      builder: (context, state) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    widget.project.image != null && widget.project.image!.startsWith('http')
                        ? widget.project.image!
                        : 'https://api.dholeraplatform.com${widget.project.image}',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.between,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.project.category.toUpperCase(),
                              style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (widget.project.reraApproved)
                            const Row(
                              children: [
                                Icon(Icons.verified, color: Colors.green, size: 16),
                                SizedBox(width: 4),
                                Text('RERA VERIFIED', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.project.name,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.translate(widget.project.taglineKey),
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Project Specifications'),
                      const SizedBox(height: 16),
                      _buildSpecGrid(),
                      const SizedBox(height: 32),
                      _buildSectionTitle('About Project'),
                      const SizedBox(height: 12),
                      Text(
                        state.translate(widget.project.descKey),
                        style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomSheet: _buildBottomActions(context),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.black, letterSpacing: 1.2, color: Colors.grey),
    );
  }

  Widget _buildSpecGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: [
        _buildSpecItem(Icons.straighten, 'Plot Sizes', widget.project.plotSizes ?? 'N/A'),
        _buildSpecItem(Icons.home_work, 'Offering', widget.project.offering ?? 'N/A'),
        _buildSpecItem(Icons.add_road, 'Road Width', widget.project.roadWidth ?? 'N/A'),
        _buildSpecItem(Icons.layers, 'Zoning', widget.project.zoning ?? 'N/A'),
      ],
    );
  }

  Widget _buildSpecItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _launchWhatsapp(),
              icon: const Icon(Icons.chat_bubble),
              label: const Text('WHATSAPP INQUIRY'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              onPressed: () {}, // Add to Favorites/Vault
              icon: const Icon(Icons.bookmark_border, color: Colors.white),
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchWhatsapp() async {
    final text = Uri.encodeComponent(widget.project.whatsappText ?? 'Hi, I am interested in ${widget.project.name}');
    final url = Uri.parse('https://wa.me/917435808031?text=$text');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
