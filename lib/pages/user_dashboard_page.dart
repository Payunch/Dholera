import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/lead.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  final ApiService _apiService = ApiService();
  List<Lead> _leads = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Re-using getLeads with a larger limit for the dashboard view
      final response = await _apiService.getLeads(page: 1, limit: 100);
      if (response['success'] == true) {
        setState(() {
          _leads = Lead.fromList(response['leads'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['error'] ?? 'Failed to load user data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User & OTP Management'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(onPressed: _fetchUserData, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(Colors.indigo.withValues(alpha: 0.1)),
                      columns: const [
                        DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('OTP (Active)', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Registered', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Created At', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: _leads.map((lead) {
                        return DataRow(cells: [
                          DataCell(Text(lead.name)),
                          DataCell(Text(lead.phone)),
                          DataCell(Text(lead.email ?? 'N/A')),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: lead.otpRaw != null ? Colors.red.withValues(alpha: 0.1) : Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                lead.otpRaw ?? '---',
                                style: TextStyle(
                                  color: lead.otpRaw != null ? Colors.red : Colors.grey,
                                  fontWeight: lead.otpRaw != null ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Icon(
                              lead.isRegistered ? Icons.check_circle : Icons.pending,
                              color: lead.isRegistered ? Colors.green : Colors.orange,
                            ),
                          ),
                          DataCell(Text(DateFormat('dd/MM/yy HH:mm').format(lead.createdAt))),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
    );
  }
}
