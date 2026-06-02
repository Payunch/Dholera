import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class ApprovalsPage extends StatefulWidget {
  const ApprovalsPage({super.key});

  @override
  State<ApprovalsPage> createState() => _ApprovalsPageState();
}

class _ApprovalsPageState extends State<ApprovalsPage> {
  final ApiService _apiService = ApiService();
  List<dynamic> _records = [];
  bool _isLoading = true;
  String? _error;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchApprovals();
    // Auto-refresh every 30 seconds to keep history in sync
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) => _fetchApprovals(isBackground: true));
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchApprovals({bool isBackground = false}) async {
    if (!isBackground) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final response = await _apiService.getPendingApprovals();
      if (response['success'] == true || response['data'] != null) {
        if (mounted) {
          setState(() {
            _records = response['data'] ?? response;
            _isLoading = false;
          });
        }
      } else {
        if (!isBackground && mounted) {
          setState(() {
            _error = response['error'] ?? 'Failed to load history';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (!isBackground && mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _approvePayment(String txnId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Access'),
        content: Text('Are you sure you want to approve transaction $txnId? Please verify the payment in your bank/UPI app first.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final result = await _apiService.approvePayment(txnId);
      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment approved and access granted.')),
          );
          await _fetchApprovals();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${result['error']}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Access History', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(onPressed: _fetchApprovals, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(height: 24),
                        ElevatedButton(onPressed: _fetchApprovals, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              : _records.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          const Text('No access history found', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchApprovals,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _records.length,
                        itemBuilder: (context, index) {
                          final p = _records[index];
                          final lead = p['lead'] ?? {};
                          final items = (p['items'] as List?)?.join(', ') ?? 'Document';
                          final date = DateTime.parse(p['updatedAt']);
                          final isApproved = p['status'] == 'completed';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 0,
                            color: isApproved ? Colors.green.withAlpha(5) : Colors.white,
                            borderOnForeground: true,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isApproved ? Colors.green.withAlpha(20) : AppColors.primary.withAlpha(20),
                                          borderRadius: BorderRadius.circular(8)
                                        ),
                                        child: Text(
                                          '₹${(p['amount'] / 100).toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900, 
                                            color: isApproved ? Colors.green[700] : AppColors.primary, 
                                            fontSize: 16
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (isApproved)
                                        const Icon(Icons.check_circle, size: 16, color: Colors.green),
                                      const Spacer(),
                                      Text(
                                        DateFormat('MMM d, hh:mm a').format(date.toLocal()),
                                        style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    lead['name'] ?? 'Unknown User',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    lead['phone'] ?? '',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                  const Divider(height: 24),
                                  Row(
                                    children: [
                                      const Icon(Icons.description, size: 14, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          items,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.fingerprint, size: 14, color: AppColors.primary),
                                      const SizedBox(width: 8),
                                      Text(
                                        'UTR: ${p['utr']}',
                                        style: TextStyle(
                                          fontSize: 12, 
                                          fontWeight: FontWeight.bold, 
                                          color: isApproved ? Colors.green[700] : AppColors.primary
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (!isApproved) ...[
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () => _approvePayment(p['transaction_id']),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.textPrimary,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                            ),
                                            child: const Text('APPROVE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
