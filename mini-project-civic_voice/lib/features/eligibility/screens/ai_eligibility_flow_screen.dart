import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/eligibility_checker_provider.dart';
import '../../../../widgets/glass_card.dart';

class AIEligibilityFlowScreen extends StatefulWidget {
  const AIEligibilityFlowScreen({super.key});

  @override
  State<AIEligibilityFlowScreen> createState() => _AIEligibilityFlowScreenState();
}

class _AIEligibilityFlowScreenState extends State<AIEligibilityFlowScreen> {
  final TextEditingController _textController = TextEditingController();

  void _submitInput(EligibilityCheckerProvider provider) {
    if (_textController.text.trim().isEmpty) return;
    provider.processUserInput(_textController.text.trim());
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EligibilityCheckerProvider(),
      child: Consumer<EligibilityCheckerProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            backgroundColor: AppColors.bgDeep,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppColors.textPrimary),
              title: Text(
                'AI Scheme Eligibility Checker',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.saffron,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => provider.clearChat(),
                )
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.chatHistory.length,
                      itemBuilder: (context, index) {
                        final msg = provider.chatHistory[index];
                        final isUser = msg.startsWith('User:');
                        return Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isUser ? AppColors.accentBlue.withValues(alpha: 0.2) : AppColors.bgMid,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isUser ? AppColors.accentBlue : AppColors.surfaceBorder,
                              ),
                            ),
                            child: Text(
                              msg.replaceAll('User: ', '').replaceAll('System: ', ''),
                              style: GoogleFonts.poppins(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                          ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                        );
                      },
                    ),
                  ),

                  // Display Matched Schemes
                  if (provider.matchedSchemes.isNotEmpty)
                    Container(
                      height: 120,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: provider.matchedSchemes.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 200,
                            margin: const EdgeInsets.only(right: 12, bottom: 8),
                            child: GlassCard(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle, color: AppColors.emeraldLight),
                                  const SizedBox(height: 8),
                                  Text(
                                    provider.matchedSchemes[index],
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ).animate().scale(delay: Duration(milliseconds: 100 * index));
                        },
                      ),
                    ),

                  if (provider.isProcessing)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(color: AppColors.saffron),
                    ),

                  // Input Box Layer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppColors.bgMid,
                      border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'E.g., I am a 45 yr old farmer...',
                              hintStyle: const TextStyle(color: AppColors.textMuted),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: AppColors.bgDeep,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            ),
                            onSubmitted: (_) => _submitInput(provider),
                          ),
                        ),
                        const SizedBox(width: 12),
                        CircleAvatar(
                          backgroundColor: AppColors.saffron,
                          radius: 24,
                          child: IconButton(
                            icon: const Icon(Icons.mic, color: Colors.white),
                            onPressed: () {
                              // Future AWS Integration Point: Amazon Transcribe for voice-to-text here
                              // Fallback simulated input for now constraints.
                              _textController.text = "I am a local farmer looking for seed subsidies.";
                              _submitInput(provider);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: AppColors.accentBlue,
                          radius: 24,
                          child: IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: () => _submitInput(provider),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
