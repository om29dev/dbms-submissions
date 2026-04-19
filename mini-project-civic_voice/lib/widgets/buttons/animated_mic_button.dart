import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/voice_provider.dart';

class AnimatedMicButton extends StatefulWidget {
  const AnimatedMicButton({super.key});

  @override
  State<AnimatedMicButton> createState() => _AnimatedMicButtonState();
}

class _AnimatedMicButtonState extends State<AnimatedMicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voiceProvider = Provider.of<VoiceProvider>(context);
    final isListening = voiceProvider.isListening;

    return Stack(
      alignment: Alignment.center,
      children: [
        if (isListening) _buildPulse(1.0),
        if (isListening) _buildPulse(1.5),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isListening ? Colors.redAccent : AppColors.primary,
            boxShadow: [
              BoxShadow(
                color: (isListening ? Colors.redAccent : AppColors.primary)
                    .withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            isListening ? Icons.mic : Icons.mic_none,
            color: AppColors.white,
            size: 40,
          ),
        ),
      ],
    );
  }

  Widget _buildPulse(double scale) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_controller.value * scale),
          child: Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: (Provider.of<VoiceProvider>(context).isListening ? Colors.redAccent : AppColors.secondary)
                    .withValues(alpha: 1.0 - _controller.value),
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }
}
