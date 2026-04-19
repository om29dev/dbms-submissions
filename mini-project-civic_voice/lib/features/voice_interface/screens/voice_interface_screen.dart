import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:civic_voice_interface/core/theme/app_theme.dart';
import 'package:civic_voice_interface/widgets/animated/voice_waveform.dart';
import 'package:civic_voice_interface/widgets/animated/particle_background.dart';
import 'package:civic_voice_interface/providers/conversation_provider.dart';
import 'package:civic_voice_interface/providers/voice_provider.dart';
import 'package:civic_voice_interface/models/conversation_model.dart'; // Ensure this model is available

import 'package:intl/intl.dart';

class VoiceInterfaceScreen extends StatefulWidget {
  const VoiceInterfaceScreen({super.key});

  @override
  State<VoiceInterfaceScreen> createState() => _VoiceInterfaceScreenState();
}

class _VoiceInterfaceScreenState extends State<VoiceInterfaceScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _avatarController;
  late AnimationController _gridController;
  late Animation<double> _avatarAnimation;

  final List<String> _quickResponses = [
    'How do I apply?',
    'Eligibility rules',
    'Required documents',
    'Nearest center',
  ];

  @override
  void initState() {
    super.initState();
    
    _avatarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _gridController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _avatarAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _avatarController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _avatarController.dispose();
    _gridController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Link VoiceProvider to ConversationProvider for TTS output
    final voice = Provider.of<VoiceProvider>(context, listen: false);
    final convo = Provider.of<ConversationProvider>(context, listen: false);
    convo.updateVoiceProvider(voice);
  }

  void _toggleListening(VoiceProvider voice, ConversationProvider convo) {
    if (voice.isListening) {
      voice.stopSilently();
    } else {
      voice.startListening(
        onFinalResult: (text) {
          if (text.isNotEmpty) {
             convo.sendMessage(text);
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Consume Providers
    final voiceProvider = Provider.of<VoiceProvider>(context);
    final conversationProvider = Provider.of<ConversationProvider>(context);
    final isListening = voiceProvider.isListening;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.deepSpaceBlue,
      extendBodyBehindAppBar: true,
      drawer: _buildHistoryDrawer(context, conversationProvider),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.pureWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Voice Assistant',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.pureWhite,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppTheme.pureWhite),
            tooltip: 'Chat History',
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppTheme.pureWhite),
            tooltip: 'New Chat',
            onPressed: () => conversationProvider.startNewChat(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Animated grid background
          Positioned.fill(
            child: CustomPaint(
              painter: _AnimatedGridPainter(
                animation: _gridController,
                color: AppTheme.electricBlue,
              ),
            ),
          ),
          
          // Particle effects
          const Positioned.fill(
            child: ParticleBackground(
              numberOfParticles: 40,
              particleColor: AppTheme.neonCyan,
              connectParticles: false,
            ),
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Animated Avatar
                _buildAnimatedAvatar(isListening),
                
                const SizedBox(height: 30),
                
                // Voice Waveform Visualizer
                _buildWaveformVisualizer(isListening),
                
                const SizedBox(height: 30),
                
                // Conversation Bubbles
                Expanded(
                  child: _buildConversationList(conversationProvider.messages),
                ),
                
                // Quick Responses
                _buildQuickResponses(conversationProvider),
                
                const SizedBox(height: 20),
                
                // Voice Control Button
                _buildVoiceControlButton(voiceProvider, conversationProvider, isListening),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedAvatar(bool isListening) {
    return AnimatedBuilder(
      animation: _avatarAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _avatarAnimation.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.electricBlue.withValues(alpha: 0.8),
                  AppTheme.neonCyan.withValues(alpha: 0.6),
                  AppTheme.gradientStart.withValues(alpha: 0.4),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.electricBlue.withValues(alpha: 0.6),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
                BoxShadow(
                  color: AppTheme.neonCyan.withValues(alpha: 0.4),
                  blurRadius: 60,
                  spreadRadius: 20,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Rotating rings
                Positioned.fill(
                  child: CustomPaint(
                    painter: _RotatingRingsPainter(
                      animation: _avatarController,
                      isActive: isListening,
                    ),
                  ),
                ),
                
                // Center icon
                Center(
                  child: Icon(
                    isListening ? Icons.mic : Icons.mic_none,
                    size: 50,
                    color: AppTheme.pureWhite,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaveformVisualizer(bool isListening) {
    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: isListening
          ? VoiceWaveform(
              isListening: isListening,
              size: 200,
              color: AppTheme.electricBlue,
            )
          : CircularWaveform(
              isActive: isListening,
              size: 200,
              color: AppTheme.electricBlue,
            ),
    );
  }

  Widget _buildConversationList(List<Message> messages) {
    // We reverse the list for display (Newest at bottom)
    // ListView reverse:true means index 0 is at bottom.
    // So we pass chronological messages list and let ListView handle reversing.
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      reverse: true, 
      physics: const BouncingScrollPhysics(),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        // Calculate correct index for chronological list when ListView is reversed
        final reversedIndex = messages.length - 1 - index;
        final message = messages[reversedIndex];
        
        return _AnimatedMessageBubble(
          key: ValueKey(message.timestamp.millisecondsSinceEpoch.toString()), // Unique key for state preservation
          message: message.text,
          isUser: message.isUser,
          // Stagger animation for initial load, but new messages (index 0) appear immediately
          delay: Duration(milliseconds: index * 50),
        );
      },
    );
  }

  Widget _buildQuickResponses(ConversationProvider convo) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _quickResponses.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _QuickResponseChip(
              label: _quickResponses[index],
              onTap: () {
                convo.sendMessage(_quickResponses[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildVoiceControlButton(VoiceProvider voice, ConversationProvider convo, bool isListening) {
    return GestureDetector(
      onTap: () => _toggleListening(voice, convo),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        width: isListening ? 200 : 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: isListening ? AppTheme.primaryGradient : AppTheme.accentGradient,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: (isListening ? AppTheme.gradientStart : AppTheme.electricBlue).withValues(alpha: 0.6),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isListening ? Icons.stop : Icons.mic,
              color: AppTheme.pureWhite,
              size: 32,
            ),
            if (isListening) ...[
              const SizedBox(width: 12),
              Text(
                'Listening...',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.pureWhite,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  Widget _buildHistoryDrawer(BuildContext context, ConversationProvider convo) {
    return Drawer(
      backgroundColor: AppTheme.deepSpaceBlue.withValues(alpha: 0.95),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'History',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.pureWhite,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildNewChatButton(convo),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: convo.sessions.isEmpty
                ? Center(
                    child: Text(
                      'No history yet',
                      style: GoogleFonts.inter(color: AppTheme.pureWhite.withValues(alpha: 0.5)),
                    ),
                  )
                : ListView.builder(
                    itemCount: convo.sessions.length,
                    itemBuilder: (context, index) {
                      final session = convo.sessions[index];
                      final isSelected = session.id == convo.currentSessionId;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: isSelected ? BoxDecoration(
                          color: AppTheme.electricBlue.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.electricBlue.withValues(alpha: 0.3)),
                        ) : null,
                        child: ListTile(
                          title: Text(
                            session.title ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: isSelected ? AppTheme.pureWhite : AppTheme.pureWhite.withValues(alpha: 0.8),
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            DateFormat('MMM d, h:mm a').format(session.createdAt),
                            style: GoogleFonts.inter(
                              color: AppTheme.pureWhite.withValues(alpha: 0.4),
                              fontSize: 12,
                            ),
                          ),
                          onTap: () {
                            convo.loadSession(session.id);
                            Navigator.pop(context); // Close drawer
                          },
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline, size: 20, color: AppTheme.pureWhite.withValues(alpha: 0.5)),
                            onPressed: () {
                               convo.deleteSession(session.id);
                            },
                          ),
                        ),
                      );
                    },
                  ),
            ),
            const Divider(color: Colors.white10),
            ListTile(
               leading: const Icon(Icons.delete_sweep, color: AppTheme.error),
               title: Text('Clear All History', style: GoogleFonts.inter(color: AppTheme.error)),
               onTap: () => convo.clearConversation(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewChatButton(ConversationProvider convo) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
           convo.startNewChat();
           Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.pureWhite.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(12),
            color: AppTheme.pureWhite.withValues(alpha: 0.05),
          ),
          child: Row(
            children: [
              const Icon(Icons.add, color: AppTheme.pureWhite),
              const SizedBox(width: 12),
              Text(
                'New Chat',
                style: GoogleFonts.inter(
                  color: AppTheme.pureWhite,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedMessageBubble extends StatefulWidget {
  final String message;
  final bool isUser;
  final Duration delay;

  const _AnimatedMessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    required this.delay,
  });

  @override
  State<_AnimatedMessageBubble> createState() => _AnimatedMessageBubbleState();
}

class _AnimatedMessageBubbleState extends State<_AnimatedMessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(widget.isUser ? 1 : -1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Align(
            alignment: widget.isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.isUser
                      ? [AppTheme.electricBlue.withValues(alpha: 0.4), AppTheme.electricBlue.withValues(alpha: 0.2)]
                      : [AppTheme.gradientStart.withValues(alpha: 0.4), AppTheme.gradientEnd.withValues(alpha: 0.2)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(widget.isUser ? 20 : 4),
                  bottomRight: Radius.circular(widget.isUser ? 4 : 20),
                ),
                border: Border.all(
                  color: widget.isUser
                      ? AppTheme.electricBlue.withValues(alpha: 0.4)
                      : AppTheme.gradientStart.withValues(alpha: 0.4),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (widget.isUser ? AppTheme.electricBlue : AppTheme.gradientStart).withValues(alpha: 0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                widget.message,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppTheme.pureWhite,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickResponseChip extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickResponseChip({
    required this.label,
    required this.onTap,
  });

  @override
  State<_QuickResponseChip> createState() => _QuickResponseChipState();
}

class _QuickResponseChipState extends State<_QuickResponseChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: _isPressed
              ? AppTheme.accentGradient
              : const LinearGradient(
                  colors: [
                    AppTheme.glassBackground,
                    AppTheme.glassBackground,
                  ],
                ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: _isPressed ? AppTheme.electricBlue : AppTheme.glassBorder,
            width: 1,
          ),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: AppTheme.electricBlue.withValues(alpha: 0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Text(
          widget.label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.pureWhite,
          ),
        ),
      ),
    );
  }
}

class _AnimatedGridPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  _AnimatedGridPainter({
    required this.animation,
    required this.color,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    const spacing = 40.0;
    final offset = (animation.value * spacing) % spacing;

    // Vertical lines
    for (double x = -spacing + offset; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (double y = -spacing + offset; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_AnimatedGridPainter oldDelegate) => true;
}

class _RotatingRingsPainter extends CustomPainter {
  final Animation<double> animation;
  final bool isActive;

  _RotatingRingsPainter({
    required this.animation,
    required this.isActive,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    if (!isActive) return;

    for (int i = 0; i < 3; i++) {
      final ringRadius = radius * (0.7 + i * 0.15);
      final rotation = animation.value * 2 * 3.14159 * (i.isEven ? 1 : -1);

      final paint = Paint()
        ..color = AppTheme.pureWhite.withValues(alpha: 0.2 - i * 0.05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation);
      canvas.translate(-center.dx, -center.dy);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: ringRadius),
        0,
        3.14159,
        false,
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_RotatingRingsPainter oldDelegate) => true;
}
