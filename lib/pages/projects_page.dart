import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/project.dart';
import '../services/api_service.dart';
import '../blocs/localization/localization_bloc.dart';
import '../blocs/localization/localization_state.dart';
import 'project_detail_page.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final ApiService _apiService = ApiService();
  List<Project> _projects = [];
  List<Project> _filteredProjects = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Residential', 'Commercial', 'Industrial'];

  @override
  void initState() {
    super.initState();
    _fetchProjects();
    _apiService.trackActivity('Projects List');
  }

  Future<void> _fetchProjects() async {
    final response = await _apiService.getProjects();
    if (response['success'] == true) {
      setState(() {
        _projects = (response['projects'] as List)
            .map((json) => Project.fromJson(json))
            .toList();
        _filteredProjects = _projects;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _filterProjects(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'All') {
        _filteredProjects = _projects;
      } else {
        _filteredProjects = _projects.where((p) => p.category == category).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalizationBloc, LocalizationState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(state.translate('nav_projects'), style: const TextStyle(fontWeight: FontWeight.bold)),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: Column(
            children: [
              _buildCategoryFilter(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredProjects.isEmpty
                        ? const Center(child: Text('No projects found'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredProjects.length,
                            itemBuilder: (context, index) => _buildProjectCard(_filteredProjects[index], state),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat, style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
              selected: isSelected,
              selectedColor: Theme.of(context).primaryColor,
              onSelected: (selected) {
                if (selected) _filterProjects(cat);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProjectCard(Project project, LocalizationState state) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProjectDetailPage(project: project)),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        shadowColor: Colors.black12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  project.image != null && project.image!.startsWith('http')
                      ? project.image!
                      : 'https://api.dholeraplatform.com${project.image}',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 50, color: Colors.grey),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      project.category.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (project.reraApproved)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'RERA',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        project.location?.split(',')[0] ?? '',
                        style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    project.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.translate(project.taglineKey),
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'VIEW DETAILS',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
