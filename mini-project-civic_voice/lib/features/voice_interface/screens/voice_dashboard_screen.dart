import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../providers/voice_provider.dart';
import '../../../../providers/conversation_provider.dart';
import '../../../../providers/language_provider.dart';
import '../../../../models/conversation_model.dart';
import '../../../../widgets/decorative/chakra_painter.dart';
import '../../../../widgets/decorative/jali_pattern.dart';
import '../../../../widgets/bilingual_label.dart';

import 'package:url_launcher/url_launcher.dart';

class VoiceDashboardScreen extends StatelessWidget {
  const VoiceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final voice = Provider.of<VoiceProvider>(context);
    final convo = Provider.of<ConversationProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);

    // Sync language choice
    WidgetsBinding.instance.addPostFrameCallback((_) {
      voice.setLocale(lang.fullLocaleId);
      convo.setLanguage(lang.currentLanguage == 'hi' ? 'hi' : 'en');
    });

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      drawer: _buildHistoryDrawer(context, convo),
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative Backgrounds
            const Positioned.fill(
              child: JaliPattern(opacity: 0.03),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.2,
              right: -100,
              child: const Opacity(
                opacity: 0.05,
                child: SizedBox(
                  width: 400,
                  height: 400,
                  child: ChakraPainterWidget(size: 400),
                ),
              ),
            ),

            Column(
              children: [
                _buildHeader(context),
                
                // 2. AI Indicator
                Expanded(
                  flex: 3,
                  child: _AICoreVisualizer(state: voice.state),
                ),

                // 3. Conversation List
                Expanded(
                  flex: 4,
                  child: _ConversationConsole(convo: convo),
                ),

                // 4. Input Area
                _buildInteractionDeck(context, voice, convo),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.history_rounded, color: AppColors.textSecondary),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          const BilingualLabel(
            englishText: 'CIVIC VOICE AI',
            hindiText: 'नागरिक आवाज़',
            scale: 1.2,
            englishColor: AppColors.saffron,
            hindiColor: AppColors.gold,
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary, size: 32),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionDeck(BuildContext context, VoiceProvider voice, ConversationProvider convo) {
    final textController = TextEditingController();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: const Border(top: BorderSide(color: AppColors.surfaceBorder)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            offset: const Offset(0, -8),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if ((voice.errorMessage ?? '').isNotEmpty)
            _buildErrorTip(voice.errorMessage!),
          
          Row(
            children: [
              IconButton(
                onPressed: () => convo.clearMessages(),
                icon: const Icon(Icons.add_circle_outline, color: AppColors.textSecondary, size: 28),
                tooltip: 'New Chat',
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.bgMid,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: TextField(
                    controller: textController,
                    style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Ask CVI anything...',
                      border: InputBorder.none,
                      hintStyle: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onSubmitted: (text) {
                      if (text.trim().isNotEmpty) {
                        convo.sendMessage(text.trim());
                        textController.clear();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Pulsing Mic Button
              GestureDetector(
                onTap: () async {
                  if (voice.state == VoiceState.error) {
                    await voice.initVoice();
                  } else if (voice.isListening) {
                    voice.stopSilently();
                  } else {
                    await voice.startListening(onFinalResult: (text) => convo.sendMessage(text));
                  }
                },
                child: _buildOrbButton(context, voice.isListening, voice.state == VoiceState.error),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorTip(String error) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.semanticError.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.semanticError.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.semanticError, size: 16),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              error,
              style: GoogleFonts.inter(color: AppColors.semanticError, fontSize: 12),
            ),
          ),
        ],
      ),
    ).animate().shake();
  }

  Widget _buildOrbButton(BuildContext context, bool active, bool isError) {
    Color orbColor = isError ? AppColors.semanticError : (active ? AppColors.saffron : AppColors.bgMid);
    Color iconColor = (isError || active) ? AppColors.textPrimary : AppColors.saffron;
    
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: orbColor,
        border: Border.all(
          color: active ? AppColors.saffron : AppColors.saffronDeep,
          width: 2,
        ),
        boxShadow: active ? [
          const BoxShadow(color: AppColors.saffronGlow, blurRadius: 20, spreadRadius: 4),
        ] : null,
      ),
      child: Center(
        child: Icon(
          isError ? Icons.refresh_rounded : (active ? Icons.stop_rounded : Icons.mic_rounded),
          color: iconColor,
          size: 28,
        ),
      ),
    ).animate(onPlay: (c) => active ? c.repeat(reverse: true) : c.stop())
     .scale(begin: const Offset(1,1), end: const Offset(1.1, 1.1), duration: 800.ms, curve: Curves.easeInOutSine);
  }

  Widget _buildHistoryDrawer(BuildContext context, ConversationProvider convo) {
    return Drawer(
      backgroundColor: AppColors.bgDeep,
      surfaceTintColor: Colors.transparent,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(24),
              child: BilingualLabel(
                englishText: 'Chat History',
                hindiText: 'इतिहास',
                scale: 1.5,
              ),
            ),
            const Divider(color: AppColors.surfaceBorder, height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: convo.messages.length,
                separatorBuilder: (context, index) => const Divider(color: AppColors.surfaceBorder, height: 1),
                itemBuilder: (context, index) {
                   final msg = convo.messages[index];
                   return ListTile(
                     contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                     leading: Container(
                       padding: const EdgeInsets.all(8),
                       decoration: BoxDecoration(
                         color: msg.isUser ? AppColors.bgMid : AppColors.saffron.withValues(alpha: 0.1),
                         borderRadius: BorderRadius.circular(8),
                       ),
                       child: Icon(
                         msg.isUser ? Icons.person_outline : Icons.auto_awesome, 
                         color: msg.isUser ? AppColors.textSecondary : AppColors.saffron,
                         size: 20,
                       ),
                     ),
                     title: Text(
                       msg.text, 
                       maxLines: 1, 
                       overflow: TextOverflow.ellipsis,
                       style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13),
                     ),
                     subtitle: Padding(
                       padding: const EdgeInsets.only(top: 4),
                       child: Text(
                         DateFormat('HH:mm a').format(msg.timestamp),
                         style: GoogleFonts.spaceMono(color: AppColors.textMuted, fontSize: 10),
                       ),
                     ),
                     onLongPress: () {
                        convo.deleteMessage(index);
                     },
                     onTap: () {
                       Navigator.pop(context);
                     },
                   );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: OutlinedButton.icon(
                onPressed: () {
                  convo.clearMessages();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.delete_sweep_rounded, size: 20),
                label: const Text('Clear History'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.semanticError,
                  side: BorderSide(color: AppColors.semanticError.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AICoreVisualizer extends StatefulWidget {
  final VoiceState state;
  const _AICoreVisualizer({required this.state});

  @override
  State<_AICoreVisualizer> createState() => _AICoreVisualizerState();
}

class _AICoreVisualizerState extends State<_AICoreVisualizer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color coreColor;
    double scale = 1.0;
    
    switch (widget.state) {
      case VoiceState.listening: coreColor = AppColors.saffron; scale = 1.1; break;
      case VoiceState.processing: coreColor = AppColors.gold; scale = 1.05; break; 
      case VoiceState.responding: coreColor = AppColors.emerald; scale = 1.2; break;
      case VoiceState.error: coreColor = AppColors.semanticError; scale = 1.0; break;
      default: coreColor = AppColors.textSecondary.withValues(alpha: 0.3);
    }

    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _CorePainter(_controller.value, coreColor, widget.state),
            child: const SizedBox(width: 240, height: 240),
          );
        },
      ),
    ).animate(target: scale).scale(duration: 600.ms, curve: Curves.easeOutBack);
  }
}

class _CorePainter extends CustomPainter {
  final double progress;
  final Color color;
  final VoiceState state;
  
  _CorePainter(this.progress, this.color, this.state);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Background slow pulse ring
    if (state != VoiceState.idle) {
      final pulseRadius = 80.0 + (math.sin(progress * math.pi * 4) * 10);
      canvas.drawCircle(
        center, 
        pulseRadius, 
        Paint()
          ..color = color.withValues(alpha: 0.1)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20)
      );
    }

    // Outer spinning dashed rings
    for (int i = 0; i < 2; i++) {
      double radius = 70.0 + (i * 25);
      double rotation = progress * math.pi * 2 * (i % 2 == 0 ? 1 : -1) * (state == VoiceState.idle ? 0.2 : 1.0);
      
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation);
      
      final rect = Rect.fromCircle(center: Offset.zero, radius: radius);
      
      // Draw dashed arc manually since Flutter doesn't have native dashed arcs easily
      const int dashCount = 24;
      const double dashAngle = (math.pi * 2) / dashCount;
      const double gapAngle = dashAngle * 0.4; // 40% gap
      
      for(int j = 0; j < dashCount; j++) {
        canvas.drawArc(
          rect,
          j * dashAngle,
          dashAngle - gapAngle,
          false,
          paint..color = color.withValues(alpha: 0.2 / (i + 1)),
        );
      }
      
      canvas.restore();
    }

    // Inner morphing core blob
    if (state != VoiceState.idle) {
      final corePaint = Paint()
        ..color = color.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);
        
      final path = Path();
      const int points = 10;
      
      for (int i = 0; i < points; i++) {
        double angle = (i * (360 / points)) * math.pi / 180;
        
        // Speed up morphing based on state
        double morphSpeed = progress * math.pi * 2;
        if (state == VoiceState.listening) morphSpeed *= 4;
        if (state == VoiceState.responding) morphSpeed *= 8;
        
        // Create organic blob shape
        double r = 45 + math.sin(morphSpeed + (i * 1.5)) * 12;
        
        Offset p = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          // Add some bezier curves for smoother blob if desired, using simple lines for now
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();
      canvas.drawPath(path, corePaint);
      
      // Center highlight core
      canvas.drawCircle(center, 20, Paint()..color = color..style = PaintingStyle.fill..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
      canvas.drawCircle(center, 8, Paint()..color = Colors.white.withValues(alpha: 0.8));

    } else {
      // Idle state
      canvas.drawCircle(center, 40, paint..color = color.withValues(alpha: 0.4)..style = PaintingStyle.stroke..strokeWidth = 2);
      canvas.drawCircle(center, 4, Paint()..color = color.withValues(alpha: 0.6));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


// Minimalistic Conversation Console
class _ConversationConsole extends StatelessWidget {
  final ConversationProvider convo;
  const _ConversationConsole({required this.convo});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      reverse: true,
      physics: const BouncingScrollPhysics(),
      itemCount: convo.messages.length,
      itemBuilder: (context, index) {
        final msg = convo.messages.reversed.toList()[index];
        return _buildMessageBubble(context, msg).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildMessageBubble(BuildContext context, Message msg) {
    final isUser = msg.isUser;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            constraints: const BoxConstraints(maxWidth: 320),
            decoration: BoxDecoration(
              color: isUser 
                  ? AppColors.saffron.withValues(alpha: 0.15) 
                  : AppColors.bgMid,
              border: Border.all(
                color: isUser ? AppColors.saffron.withValues(alpha: 0.3) : AppColors.surfaceBorder,
              ),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isUser ? 20 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 20),
              ),
            ),
            child: Text(
              msg.text,
              style: GoogleFonts.inter(
                color: isUser ? AppColors.textPrimary : AppColors.textSecondary,
                height: 1.5,
                fontSize: 14,
              ),
            ),
          ),
          
          if (msg.action != null)
            _buildActionCard(context, msg.action!),
            
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, Map<String, dynamic> action) {
    final String type = action['type'] ?? '';
    
    IconData icon;
    String label;
    VoidCallback onTap;
    Color actionColor = AppColors.gold;
    
    switch (type) {
      case 'link':
        icon = Icons.open_in_new_rounded;
        label = action['text'] ?? 'Open Link';
        onTap = () async {
          final url = Uri.parse(action['url'] ?? '');
          if (await canLaunchUrl(url)) await launchUrl(url);
        };
        break;
      case 'navigate':
        icon = Icons.directions_rounded;
        label = 'Launch Application';
        actionColor = AppColors.emerald;
        onTap = () {
          // Navigation logic would go here
          debugPrint("Navigating to: ${action['screen']}");
        };
        break;
      case 'guide':
        icon = Icons.auto_stories_rounded;
        label = action['title'] ?? 'Review Guide';
        actionColor = AppColors.accentBlue;
        onTap = () {
          debugPrint("Showing guide steps: ${action['steps']}");
        };
        break;
      default:
        return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: actionColor,
          side: BorderSide(color: actionColor.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          backgroundColor: actionColor.withValues(alpha: 0.05),
        ),
      ),
    );
  }
}
