import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class InteractiveHeroGrid extends StatelessWidget {
  final int crossAxisCount;
  final int totalItems;

  const InteractiveHeroGrid({
    super.key,
    this.crossAxisCount = 2,
    this.totalItems = 24, // 12 rows of 2 columns
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image
        Image.network(
          'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&q=80&w=2070',
          fit: BoxFit.cover,
        ),
        
        // Gradient Fade to blend with page
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                Colors.black.withValues(alpha: 0.7),
                Colors.black.withValues(alpha: 0.9),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),

        // Grid Overlay
        Opacity(
          opacity: 0.3,
          child: IgnorePointer(
            // Use IgnorePointer so the user can scroll the app bar normally.
            // We simulate the "interactive" feel with random glowing boxes.
            ignoring: true, 
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
                childAspectRatio: 1.5, // Make boxes slightly rectangular
              ),
              itemCount: totalItems,
              itemBuilder: (context, index) {
                return _GlowingGridCell(index: index);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _GlowingGridCell extends StatefulWidget {
  final int index;
  const _GlowingGridCell({required this.index});

  @override
  State<_GlowingGridCell> createState() => _GlowingGridCellState();
}

class _GlowingGridCellState extends State<_GlowingGridCell> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  Timer? _randomTimer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    // Randomly trigger glows to mimic the interactive web feel on mobile without blocking scroll
    _startRandomGlow();
  }

  void _startRandomGlow() {
    Future.delayed(Duration(milliseconds: _random.nextInt(5000)), () {
      if (mounted) {
        _triggerGlowCycle();
      }
    });
  }

  void _triggerGlowCycle() {
    if (!mounted) return;
    _controller.forward().then((_) {
      if (mounted) {
        _controller.reverse().then((_) {
          _randomTimer = Timer(Duration(seconds: _random.nextInt(8) + 2), _triggerGlowCycle);
        });
      }
    });
  }

  @override
  void dispose() {
    _randomTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            color: _opacityAnimation.value > 0 
                ? const Color(0xFFFF7A00).withValues(alpha: _opacityAnimation.value * 0.4) 
                : Colors.transparent,
            boxShadow: _opacityAnimation.value > 0
                ? [
                    BoxShadow(
                      color: const Color(0xFFFF7A00).withValues(alpha: _opacityAnimation.value * 0.5),
                      blurRadius: 20 * _opacityAnimation.value,
                      spreadRadius: 2 * _opacityAnimation.value,
                    )
                  ]
                : null,
          ),
        );
      },
    );
  }
}
