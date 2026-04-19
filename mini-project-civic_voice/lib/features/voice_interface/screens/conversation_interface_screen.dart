import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../../core/constants/app_colors.dart';

class ConversationInterfaceScreen extends StatefulWidget {
  final String query;
  const ConversationInterfaceScreen({super.key, required this.query});

  @override
  State<ConversationInterfaceScreen> createState() => _ConversationInterfaceScreenState();
}

class _ConversationInterfaceScreenState extends State<ConversationInterfaceScreen> {
  bool _showSystemResponse = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _showSystemResponse = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Voice Assistant'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: FadeInLeft(
                child: _buildUserBubble(widget.query),
              ),
            ),
            const SizedBox(height: 30),
            if (_showSystemResponse)
              Align(
                alignment: Alignment.centerRight,
                child: FadeInRight(
                  child: _buildSystemBubble(
                    'I understand you want to apply for a Ration Card. I can help you with that. Would you like to check your eligibility first?',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserBubble(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person, size: 16, color: AppColors.primary),
              SizedBox(width: 5),
              Text('You', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildSystemBubble(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_balance, size: 16, color: AppColors.secondary),
              SizedBox(width: 5),
              Text('CVI Assistant', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                text,
                textStyle: const TextStyle(color: AppColors.white, fontSize: 16),
                speed: const Duration(milliseconds: 50),
              ),
            ],
            totalRepeatCount: 1,
          ),
        ],
      ),
    );
  }
}
