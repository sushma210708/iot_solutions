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
        child: Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))),
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
      color: const Color(0xFF0B1120),
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
          
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 64 : 24,
                  vertical: isDesktop ? 120 : 80,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Impact Stories',
                      style: TextStyle(
                        fontSize: isDesktop ? 48 : 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
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
                          height: 1.6,
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
                              color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF2563EB) : Colors.white24,
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
                      return ProjectCard(project: project);
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
          rowChildren.add(Expanded(child: ProjectCard(project: projects[i + j])));
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
}

class ProjectCard extends StatefulWidget {
  final Project project;
  const ProjectCard({super.key, required this.project});

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectDetailsPage(project: widget.project),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _isHovered ? -8 : 0, 0),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isHovered ? const Color(0xFF2563EB).withOpacity(0.5) : Colors.white12,
              width: 1,
            ),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: const Color(0xFF2563EB).withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image Section
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(23)),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                    ),
                    child: widget.project.imageUrl.isNotEmpty
                        ? Image.network(
                            widget.project.imageUrl,
                            fit: BoxFit.cover,
                          )
                        : const Center(child: Icon(Icons.image, color: Colors.white24, size: 48)),
                  ),
                ),
              ),
              
              // Content Section
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.2)),
                      ),
                      child: Text(
                        widget.project.category.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      widget.project.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.project.shortDescription,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                        height: 1.6,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        const Text(
                          'View Case Study',
                          style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          transform: Matrix4.translationValues(_isHovered ? 4 : 0, 0, 0),
                          child: const Icon(Icons.arrow_forward, color: Color(0xFF2563EB), size: 18),
                        ),
                      ],
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
