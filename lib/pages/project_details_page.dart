import 'package:flutter/material.dart';
import '../models/project.dart';

class ProjectDetailsPage extends StatefulWidget {
  final Project project;

  const ProjectDetailsPage({super.key, required this.project});

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 50 && !_isScrolled) {
        setState(() => _isScrolled = true);
      } else if (_scrollController.offset <= 50 && _isScrolled) {
        setState(() => _isScrolled = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final project = widget.project;

    return Scaffold(
      backgroundColor: const Color(0xFF0F161B),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(project, isDesktop),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildOverviewSection(project, isDesktop),
              if (project.workflowSteps.isNotEmpty) _buildWorkflowSection(project, isDesktop),
              if (project.impactMetrics.isNotEmpty || project.impact.isNotEmpty) _buildImpactSection(project, isDesktop),
              if (project.gallery.isNotEmpty) _buildGallerySection(project, isDesktop),
              _buildCallToAction(isDesktop),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(Project project, bool isDesktop) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: isDesktop ? 600 : 400,
      backgroundColor: _isScrolled ? const Color(0xFF0F161B) : Colors.transparent,
      elevation: _isScrolled ? 4 : 0,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (project.imageUrl.isNotEmpty)
              Image.network(
                project.imageUrl,
                fit: BoxFit.cover,
              )
            else
              Container(color: const Color(0xFF1E272D)),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0F161B).withOpacity(0.9),
                    const Color(0xFF0F161B).withOpacity(0.3),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Positioned(
              bottom: isDesktop ? 80 : 40,
              left: isDesktop ? 100 : 24,
              right: isDesktop ? 100 : 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14B885).withOpacity(0.1),
                      border: Border.all(color: const Color(0xFF14B885).withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      project.category.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF14B885),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    project.title,
                    style: TextStyle(
                      fontSize: isDesktop ? 56 : 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: isDesktop ? MediaQuery.of(context).size.width * 0.6 : double.infinity,
                    child: Text(
                      project.shortDescription,
                      style: TextStyle(
                        fontSize: isDesktop ? 20 : 16,
                        color: Colors.white70,
                        height: 1.5,
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

  Widget _buildOverviewSection(Project project, bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 100 : 24,
        vertical: isDesktop ? 100 : 64,
      ),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildProblemBlock(project)),
                const SizedBox(width: 80),
                Expanded(child: _buildSolutionBlock(project)),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProblemBlock(project),
                const SizedBox(height: 64),
                _buildSolutionBlock(project),
              ],
            ),
    );
  }

  Widget _buildProblemBlock(Project project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'THE CHALLENGE',
          style: TextStyle(
            color: Color(0xFF14B885),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          project.problem,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.w300,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        if (project.whyItMatters.isNotEmpty) ...[
          const Text(
            'WHY IT MATTERS',
            style: TextStyle(
              color: Colors.white38,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            project.whyItMatters,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.6,
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildSolutionBlock(Project project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'OUR SOLUTION',
          style: TextStyle(
            color: Color(0xFF14B885),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          project.solution,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 48),
        if (project.keyCapabilities.isNotEmpty) ...[
          const Text(
            'KEY CAPABILITIES',
            style: TextStyle(
              color: Colors.white38,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          ...project.keyCapabilities.map((cap) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF14B885), size: 20),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        cap,
                        style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4),
                      ),
                    ),
                  ],
                ),
              )),
        ]
      ],
    );
  }

  Widget _buildWorkflowSection(Project project, bool isDesktop) {
    return Container(
      color: const Color(0xFF161E24),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 100 : 24,
        vertical: isDesktop ? 100 : 64,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'EXECUTION WORKFLOW',
            style: TextStyle(
              color: Color(0xFF14B885),
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'How we delivered the solution',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 64),
          Wrap(
            spacing: 32,
            runSpacing: 48,
            children: List.generate(project.workflowSteps.length, (index) {
              final step = project.workflowSteps[index];
              return Container(
                width: isDesktop ? 350 : double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F161B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '0${index + 1}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.white12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      step['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      step['description'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white60,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactSection(Project project, bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 100 : 24,
        vertical: isDesktop ? 100 : 64,
      ),
      child: Column(
        children: [
          if (project.impact.isNotEmpty) ...[
            Text(
              '”${project.impact}”',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isDesktop ? 36 : 24,
                fontWeight: FontWeight.w300,
                color: Colors.white,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 80),
          ],
          if (project.impactMetrics.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: project.impactMetrics.map((metric) {
                return Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Text(
                          metric['value'] ?? '',
                          style: TextStyle(
                            fontSize: isDesktop ? 64 : 40,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF14B885),
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          metric['metric'] ?? '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          metric['description'] ?? '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildGallerySection(Project project, bool isDesktop) {
    return Container(
      color: const Color(0xFF161E24),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 100 : 24,
        vertical: isDesktop ? 100 : 64,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PROJECT GALLERY',
            style: TextStyle(
              color: Color(0xFF14B885),
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 48),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 3 : 1,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: 1.5,
            ),
            itemCount: project.gallery.length,
            itemBuilder: (context, index) {
              final image = project.gallery[index];
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: image['url']?.isNotEmpty == true
                      ? DecorationImage(
                          image: NetworkImage(image['url']!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: const Color(0xFF0F161B),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCallToAction(bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 100 : 24,
        vertical: isDesktop ? 120 : 80,
      ),
      child: Center(
        child: Column(
          children: [
            const Text(
              'Ready to transform your operations?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14B885),
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: const Text(
                'Let\'s Build Together',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
