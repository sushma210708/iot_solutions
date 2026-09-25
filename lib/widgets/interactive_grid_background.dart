import 'package:flutter/material.dart';

class InteractiveGridBackground extends StatelessWidget {
  final Widget child;

  const InteractiveGridBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Grid removed entirely per user requirement for a clean, premium white aesthetic.
    // We just return the child directly.
    return child;
  }
}
