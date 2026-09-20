import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CustomCarousel extends StatefulWidget {
  final List<Widget> items;
  final double height;
  final bool autoPlay;
  final bool enlargeCenterPage;
  final bool padEnds;
  final double? customViewportFraction;
  final Widget Function(IconData, VoidCallback)? customNavBuilder;
  
  const CustomCarousel({
    super.key,
    required this.items,
    required this.height,
    this.autoPlay = true,
    this.enlargeCenterPage = false,
    this.padEnds = false,
    this.customViewportFraction,
    this.customNavBuilder,
  });

  @override
  State<CustomCarousel> createState() => _CustomCarouselState();
}

class _CustomCarouselState extends State<CustomCarousel> {
  final CarouselSliderController _controller = CarouselSliderController();
  int _currentIndex = 0;
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    double viewportFraction = 0.85; // Mobile (1 card + partial next)
    
    if (widget.customViewportFraction != null) {
      viewportFraction = widget.customViewportFraction!;
    } else {
      if (screenWidth >= 1200) {
        viewportFraction = 0.25; // Desktop ~4 cards
      } else if (screenWidth >= 900) {
        viewportFraction = 0.33; // Small Desktop ~3 cards
      } else if (screenWidth >= 600) {
        viewportFraction = 0.5; // Tablet ~2 cards
      }
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CarouselSlider(
                carouselController: _controller,
                options: CarouselOptions(
                  height: widget.height,
                  viewportFraction: viewportFraction,
                  initialPage: 0,
                  enableInfiniteScroll: widget.items.length > 3,
                  reverse: false,
                  autoPlay: widget.autoPlay && !_isHovering,
                  autoPlayInterval: const Duration(seconds: 4),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: widget.enlargeCenterPage,
                  enlargeFactor: 0.25,
                  padEnds: widget.padEnds,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                items: widget.items.map((item) {
                  return Padding(
                    padding: EdgeInsets.only(right: widget.padEnds ? 0 : 24.0),
                    child: item,
                  );
                }).toList(),
              ),
              if (screenWidth >= 900 && widget.items.length > (widget.enlargeCenterPage ? 1 : 3))
                Positioned(
                  left: widget.enlargeCenterPage ? 20 : -20,
                  child: widget.customNavBuilder != null 
                      ? widget.customNavBuilder!(Icons.chevron_left, () => _controller.previousPage())
                      : _buildNavButton(Icons.chevron_left, () => _controller.previousPage()),
                ),
              if (screenWidth >= 900 && widget.items.length > (widget.enlargeCenterPage ? 1 : 3))
                Positioned(
                  right: widget.enlargeCenterPage ? 20 : 4,
                  child: widget.customNavBuilder != null 
                      ? widget.customNavBuilder!(Icons.chevron_right, () => _controller.nextPage())
                      : _buildNavButton(Icons.chevron_right, () => _controller.nextPage()),
                ),
            ],
          ),
          const SizedBox(height: 32),
          // Pagination Indicators
          if (widget.items.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.items.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _controller.animateToPage(entry.key),
                  child: Container(
                    width: _currentIndex == entry.key ? 24.0 : 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : const Color(0xFF2563EB))
                          .withOpacity(_currentIndex == entry.key ? 0.9 : 0.2),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onPressed) {
    return AnimatedOpacity(
      opacity: _isHovering ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161E24),
          shape: BoxShape.circle,
          border: Border.all(color: Color(0x3D1E293B)),
        ),
        child: IconButton(
          icon: Icon(icon, color: Color(0xFF1E293B)),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
