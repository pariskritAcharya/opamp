// lib/widgets/custom_arrow_button.dart
import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CustomArrowButton extends StatefulWidget {
  final VoidCallback onPressed; // 👈 Navigation or action function

  const CustomArrowButton({
    super.key,
    required this.onPressed,
  });

  @override
  State<CustomArrowButton> createState() => _CustomArrowButtonState();
}

class _CustomArrowButtonState extends State<CustomArrowButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Dynamically adjust shadow offset and scale based on user interaction
    final Offset shadowOffset = _isPressed
        ? const Offset(-1, 0) // Pressed down flat
        : _isHovered
            ? const Offset(-8, 2) // Lifted up slightly on hover
            : const Offset(-6, 1); // Normal resting state

    final double scale = _isPressed ? 0.95 : (_isHovered ? 1.05 : 1.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.purple,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.brown, // Sharp sticker shadow
                  offset: shadowOffset,
                  blurRadius: 0,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.yellow,
                size: 36,
              ),
            ),
          ),
        ),
      ),
    );
  }
}