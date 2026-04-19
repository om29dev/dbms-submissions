import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/constants/app_colors.dart';

class ProcessNavigator extends StatefulWidget {
  final List<String> steps;
  const ProcessNavigator({super.key, required this.steps});

  @override
  State<ProcessNavigator> createState() => _ProcessNavigatorState();
}

class _ProcessNavigatorState extends State<ProcessNavigator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 20),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Process Navigator',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(20.0),
              minScale: 0.5,
              maxScale: 2.0,
              child: Stack(
                children: [
                  _buildPath(),
                  ...widget.steps.asMap().entries.map((entry) {
                    return _buildNode(entry.key, entry.value);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNode(int index, String label) {
    // Positioning nodes in a simple zigzag or tree structure
    double top = 50.0 + (index * 80.0);
    double left = (index % 2 == 0) ? 50.0 : 150.0;
    bool isCurrent = index == _currentStep;

    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: () => setState(() => _currentStep = index),
        child: FadeIn(
          delay: Duration(milliseconds: index * 200),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCurrent
                      ? AppColors.secondary
                      : AppColors.primary.withValues(alpha: 0.1),
                  border: Border.all(
                    color: isCurrent ? AppColors.white : AppColors.primary,
                    width: 2,
                  ),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                              color: AppColors.secondary.withValues(alpha: 0.5),
                              blurRadius: 10)
                        ]
                      : [],
                ),
                child: Icon(
                  _getIconForIndex(index),
                  color: isCurrent ? AppColors.white : AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                width: 100,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPath() {
    return CustomPaint(
      size: const Size(300, 600),
      painter: PathPainter(stepsCount: widget.steps.length),
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.edit_note;
      case 1:
        return Icons.cloud_upload;
      case 2:
        return Icons.payment;
      case 3:
        return Icons.how_to_reg;
      default:
        return Icons.circle;
    }
  }
}

class PathPainter extends CustomPainter {
  final int stepsCount;
  PathPainter({required this.stepsCount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.2)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(85, 85); // Center of first node approx

    for (int i = 1; i < stepsCount; i++) {
      double nextTop = 85.0 + (i * 80.0);
      double nextLeft = (i % 2 == 0) ? 85.0 : 185.0;
      path.lineTo(nextLeft, nextTop);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
