import 'package:flutter/material.dart';

// This is the low-level drawing class (like a drawing script in Godot)
class GraphPaperPainter extends CustomPainter {
  final Color lineColor;
  final double gridSize;

  GraphPaperPainter({
    this.lineColor = Colors.grey, // Default faint grey
    this.gridSize = 20.0,         // Default 20x20 pixel grid
  });

  // This is where the actual drawing happens every time the screen updates
  @override
  void paint(Canvas canvas, Size size) {
    // Define the brush properties
    final paint = Paint()
      ..color = lineColor.withValues(alpha: 0.3) // Make lines very subtle
      ..strokeWidth = 0.5                 // Thin lines
      ..style = PaintingStyle.stroke;     // We are drawing lines, not filled shapes

    // --- Draw Vertical Lines ---
    // Start at x = 0, keep drawing lines every 'gridSize' pixels until we hit the screen width
    for (double x = 0; x < size.width; x += gridSize) {
      // canvas.drawLine(startPoint, endPoint, paintBrush)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // --- Draw Horizontal Lines ---
    // Start at y = 0, keep drawing lines every 'gridSize' pixels until we hit the screen height
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  // Determines if the screen needs to redraw if the widget config changes.
  // Since our grid size/color won't change dynamically in this project, return false.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// This is the high-level Widget that you put into your widget tree
class GraphPaperBackground extends StatelessWidget {
  final Widget child;

  const GraphPaperBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Fills the whole screen background
        Positioned.fill(
          child: CustomPaint(
            painter: GraphPaperPainter(),
          ),
        ),
        
        // 2. Forces the content to expand and take up the full screen space
        SizedBox.expand(
          child: child,
        ),
      ],
    );
  }
}