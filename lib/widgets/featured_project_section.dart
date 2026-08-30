import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/project.dart';
import '../models/hero.dart' as hero_model;
import '../pages/project_details_page.dart';

class FeaturedProjectSection extends StatefulWidget {
  const FeaturedProjectSection({super.key});

  @override
  State<FeaturedProjectSection> createState() => _FeaturedProjectSectionState();
}

class _FeaturedProjectSectionState extends State<FeaturedProjectSection> {
  final ApiService _apiService = ApiService();
  List<Project> _projects = [];
  hero_model.HeroContent? _heroContent;
  bool _isLoading = true;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final projectsFuture = _apiService.getProjects();
      final heroFuture = _apiService.getHeroContent();
      
      final results = await Future.wait([projectsFuture, heroFuture]);
      
      if (mounted) {
        setState(() {
          _projects = (results[0] as List<Project>).where((p) => p.status == 'Active').toList();
          _heroContent = results[1] as hero_model.HeroContent;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    
    if (_isLoading) {
      return const SizedBox(
        height: 600,
        child: Center(child: CircularProgressIndicator(color: Color(0xFF14B885))),
      );
    }
    
    if (_projects.isEmpty) {
      return Container(
        width: double.infinity,
        height: isDesktop ? 700 : 500,
        color: const Color(0xFF0F161B),
        child: const Center(
          child: Text(
            'Case Studies will appear here once added from the Admin Dashboard.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    final categories = ['All', ..._projects.map((p) => p.category).toSet()];
    final filteredProjects = _selectedCategory == 'All' 
        ? _projects 
        : _projects.where((p) => p.category == _selectedCategory).toList();

    return Container(
      width: double.infinity,
      color: const Color(0xFF0F161B),
      child: Stack(
        children: [
          // Dynamic Background Image
          if (_heroContent?.impactBackgroundUrl.isNotEmpty == true)
            Positioned.fill(
              child: Image.network(
                _heroContent!.impactBackgroundUrl,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.6),
                colorBlendMode: BlendMode.darken,
              ),
            ),
          
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 100 : 24,
              vertical: isDesktop ? 120 : 80,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Impact Stories',
                  style: TextStyle(
                    fontSize: isDesktop ? 48 : 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: isDesktop ? 600 : double.infinity,
                  child: Text(
                    'Real challenges. Intelligent solutions. Measurable impact.\n\nExplore how Green Fusion is solving real-world problems and creating value across industries.',
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : 16,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                
                // Categories
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: InkWell(
                          onTap: () => setState(() => _selectedCategory = category),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF14B885) : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF14B885) : Colors.white24,
                              ),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 48),
                
                // Project Cards Grid
                if (isDesktop) ...[
                  ..._buildDesktopRows(filteredProjects, context),
                ] else ...[
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredProjects.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 32),
                    itemBuilder: (context, index) {
                      final project = filteredProjects[index];
                      return _buildProjectCard(project, context);
                    },
                  ),
                ],
                const SizedBox(height: 64),
                Center(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white38),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('View All Case Studies'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDesktopRows(List<Project> projects, BuildContext context) {
    List<Widget> rows = [];
    for (int i = 0; i < projects.length; i += 3) {
      final rowChildren = <Widget>[];
      for (int j = 0; j < 3; j++) {
        if (i + j < projects.length) {
          rowChildren.add(Expanded(child: _buildProjectCard(projects[i + j], context)));
        } else {
          rowChildren.add(const Expanded(child: SizedBox())); // Empty space
        }
        if (j < 2) rowChildren.add(const SizedBox(width: 32));
      }
      rows.add(IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rowChildren,
        ),
      ));
      if (i + 3 < projects.length) rows.add(const SizedBox(height: 32));
    }
    return rows;
  }

  Widget _buildProjectCard(Project project, BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image Section
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                  ),
                  child: project.imageUrl.isNotEmpty
                      ? Image.network(
                          project.imageUrl,
                          fit: BoxFit.cover,
                        )
                      : const Center(child: Icon(Icons.image, color: Colors.white24, size: 48)),
                ),
              ),
              
              // Content Section
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF14B885).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFF14B885).withOpacity(0.3)),
                      ),
                      child: Text(
                        project.category,
                        style: const TextStyle(
                          color: Color(0xFF14B885),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      project.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      project.shortDescription,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 24),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProjectDetailsPage(project: project),
                          ),
                        );
                      },
                      child: const Row(
                        children: [
                          Text(
                            'View Case Study',
                            style: TextStyle(
                              color: Color(0xFF14B885),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, color: Color(0xFF14B885), size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
