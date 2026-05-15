import 'package:flutter/material.dart';

class TripleSplitImage extends StatelessWidget {
  final String imagePath;
  final int index; // 1, 2, or 3
  final double height;
  final double? width;

  const TripleSplitImage({
    super.key,
    required this.imagePath,
    required this.index,
    this.height = 200,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
      ),
      child: FractionallySizedBox(
        heightFactor: 3.0, // Scale up to show 1/3 at a time
        alignment: index == 1 
            ? Alignment.topCenter 
            : (index == 2 ? Alignment.center : Alignment.bottomCenter),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image)),
        ),
      ),
    );
  }
}

class DholeraLogo extends StatelessWidget {
  final String logoPath;
  final bool isFull; // true for upper/full, false for bottom/icon-only
  final double size;

  const DholeraLogo({
    super.key,
    required this.logoPath,
    required this.isFull,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size * (isFull ? 3.0 : 1.0),
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(),
      child: FractionallySizedBox(
        heightFactor: 2.0, // Split top/bottom
        alignment: isFull ? Alignment.topCenter : Alignment.bottomCenter,
        child: Image.asset(
          logoPath,
          fit: isFull ? BoxFit.fitHeight : BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.business),
        ),
      ),
    );
  }
}
