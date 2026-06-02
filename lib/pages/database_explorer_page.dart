import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class DatabaseExplorerPage extends StatefulWidget {
  const DatabaseExplorerPage({super.key});

  @override
  State<DatabaseExplorerPage> createState() => _DatabaseExplorerPageState();
}

class _DatabaseExplorerPageState extends State<DatabaseExplorerPage> {
  final ApiService _apiService = ApiService();
  List<String> _tables = [];
  String? _selectedTable;
  List<dynamic> _data = [];
  bool _isLoading = true;
  bool _isDataLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTables();
  }

  Future<void> _fetchTables() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.getDatabaseTables();
      if (response['success'] == true) {
        setState(() {
          _tables = List<String>.from(response['data'] ?? []);
          _isLoading = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response['error']}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchTableData(String tableName) async {
    setState(() {
      _selectedTable = tableName;
      _isDataLoading = true;
      _data = [];
    });

    try {
      final response = await _apiService.getTableRawData(tableName);
      if (response['success'] == true) {
        setState(() {
          _data = response['data'] ?? [];
          _isDataLoading = false;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response['error']}')),
          );
        }
        setState(() => _isDataLoading = false);
      }
    } catch (e) {
      setState(() => _isDataLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_selectedTable ?? 'Database Explorer', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        leading: _selectedTable != null 
          ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _selectedTable = null))
          : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _selectedTable == null
              ? _buildTableList()
              : _buildDataTable(),
    );
  }

  Widget _buildTableList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tables.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: const Icon(Icons.table_chart, color: AppColors.primary),
            title: Text(_tables[index].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            trailing: const Icon(Icons.chevron_right, size: 16),
            onTap: () => _fetchTableData(_tables[index]),
          ),
        );
      },
    );
  }

  Widget _buildDataTable() {
    if (_isDataLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (_data.isEmpty) return const Center(child: Text('Table is empty'));

    final columns = (_data.first as Map<String, dynamic>).keys.toList();

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.primary.withAlpha(10)),
          columns: columns.map((col) => DataColumn(label: Text(col.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))).toList(),
          rows: _data.map((row) {
            return DataRow(
              cells: columns.map((col) {
                final val = row[col];
                return DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: Text(
                      val?.toString() ?? '',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
}
