import 'dart:io';
void main() {
  final file = File('lib/pages/project_details_page.dart');
  var content = file.readAsStringSync();

  final oldHeader = RegExp(r'  Widget _buildSliverAppBar\(Project project, bool isDesktop\) \{.*?    \);\n  \}', dotAll: true);
  
  final newHeader = '''  Widget _buildSliverAppBar(Project project, bool isDesktop) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: isDesktop ? 500 : 600,
      backgroundColor: Colors.white,
      elevation: _isScrolled ? 4 : 0,
      iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: Colors.white,
          padding: EdgeInsets.only(
            top: isDesktop ? 100 : 80,
            bottom: 40,
            left: isDesktop ? 100 : 24,
            right: isDesktop ? 100 : 24,
          ),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 5,
                      child: _buildHeaderContent(project, isDesktop),
                    ),
                    const SizedBox(width: 48),
                    Expanded(
                      flex: 5,
                      child: project.imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                project.imageUrl,
                                fit: BoxFit.contain,
                              ),
                            )
                          : const SizedBox(),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderContent(project, isDesktop),
                    const SizedBox(height: 32),
                    if (project.imageUrl.isNotEmpty)
                      Expanded(
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              project.imageUrl,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeaderContent(Project project, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Color(0xFF2563EB).withOpacity(0.1),
            border: Border.all(color: Color(0xFF2563EB).withOpacity(0.3)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            project.category.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF2563EB),
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
            fontSize: isDesktop ? 48 : 32,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E293B),
            height: 1.1,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 24),
        Text(
          project.shortDescription,
          style: TextStyle(
            fontSize: isDesktop ? 18 : 16,
            color: Color(0xFF475569),
            height: 1.5,
          ),
        ),
      ],
    );
  }''';

  content = content.replaceFirst(oldHeader, newHeader);
  file.writeAsStringSync(content);
  print('Replaced correctly!');
}
