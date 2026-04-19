import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CVIBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  const CVIBottomNav({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  @override
  State<CVIBottomNav> createState() => _CVIBottomNavState();
}

class _CVIBottomNavState extends State<CVIBottomNav>
    with TickerProviderStateMixin {
  // One animation controller per tab for tap bounce
  late List<AnimationController> _bounceControllers;
  late List<Animation<double>> _bounceAnimations;

  // Sliding indicator controller
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
  int _previousIndex = 0;

  final List<_NavItem> _items = [
    const _NavItem(icon: Icons.home_rounded, label: 'Home', hindi: 'होम'),
    const _NavItem(
        icon: Icons.grid_view_rounded, label: 'Services', hindi: 'सेवाएं'),
    const _NavItem(icon: Icons.mic_rounded, label: 'Voice', hindi: 'आवाज़'),
    const _NavItem(
        icon: Icons.auto_awesome_rounded, label: 'Recs', hindi: 'सुझाव'),
    const _NavItem(
        icon: Icons.person_rounded, label: 'Profile', hindi: 'प्रोफाइल'),
  ];

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;

    // Bounce controllers for each tab
    _bounceControllers = List.generate(
      5,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );

    _bounceAnimations = _bounceControllers
        .map(
          (c) => TweenSequence<double>([
            TweenSequenceItem(
              tween: Tween<double>(begin: 0.0, end: -10.0)
                  .chain(CurveTween(curve: Curves.easeOut)),
              weight: 40,
            ),
            TweenSequenceItem(
              tween: Tween<double>(begin: -10.0, end: 3.0)
                  .chain(CurveTween(curve: Curves.easeIn)),
              weight: 30,
            ),
            TweenSequenceItem(
              tween: Tween<double>(begin: 3.0, end: 0.0)
                  .chain(CurveTween(curve: Curves.easeOut)),
              weight: 30,
            ),
          ]).animate(c),
        )
        .toList();

    // Slide indicator controller
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<double>(
      begin: widget.currentIndex.toDouble(),
      end: widget.currentIndex.toDouble(),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOutCubic,
    ));

    // Trigger initial bounce
    _bounceControllers[widget.currentIndex].forward();
  }

  @override
  void didUpdateWidget(CVIBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      // Animate sliding indicator
      _slideAnimation = Tween<double>(
        begin: _previousIndex.toDouble(),
        end: widget.currentIndex.toDouble(),
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeInOutCubic,
      ));
      _slideController.forward(from: 0);

      // Bounce the new tab icon
      _bounceControllers[widget.currentIndex].forward(from: 0);
      _previousIndex = widget.currentIndex;
    }
  }

  @override
  void dispose() {
    for (var c in _bounceControllers) {
      c.dispose();
    }
    _slideController.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    HapticFeedback.lightImpact();
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      // Outer container — full nav bar
      height: 80,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1208),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF3D2E1E),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFFFF6B1A).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // ── SLIDING PILL INDICATOR ──
            AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, _) {
                final tabWidth = (MediaQuery.of(context).size.width - 32) / 5;
                // Voice tab (index 2) gets special treatment
                final isVoiceActive = widget.currentIndex == 2;
                return Positioned(
                  left: _slideAnimation.value * tabWidth + tabWidth * 0.15,
                  top: 12,
                  child: Container(
                    width: tabWidth * 0.7,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: isVoiceActive
                          ? const LinearGradient(
                              colors: [Color(0xFFFF6B1A), Color(0xFFE8510A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : LinearGradient(
                              colors: [
                                const Color(0xFFFF6B1A).withValues(alpha: 0.15),
                                const Color(0xFFD4930A).withValues(alpha: 0.10),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isVoiceActive
                            ? const Color(0xFFFF6B1A).withValues(alpha: 0.6)
                            : const Color(0xFFFF6B1A).withValues(alpha: 0.25),
                        width: 1,
                      ),
                      boxShadow: isVoiceActive
                          ? [
                              BoxShadow(
                                color: const Color(0xFFFF6B1A)
                                    .withValues(alpha: 0.4),
                                blurRadius: 16,
                                spreadRadius: 0,
                              ),
                            ]
                          : [],
                    ),
                  ),
                );
              },
            ),

            // ── TAB ITEMS ──
            Row(
              children: List.generate(5, (index) {
                final isActive = widget.currentIndex == index;
                final item = _items[index];
                final isVoice = index == 2;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onTap(index),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedBuilder(
                      animation: _bounceAnimations[index],
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            0,
                            isActive ? _bounceAnimations[index].value : 0,
                          ),
                          child: child,
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            width: isVoice && isActive ? 44 : 36,
                            height: isVoice && isActive ? 44 : 36,
                            decoration: isVoice
                                ? BoxDecoration(
                                    gradient: isActive
                                        ? const LinearGradient(
                                            colors: [
                                              Color(0xFFFF6B1A),
                                              Color(0xFFE8510A)
                                            ],
                                          )
                                        : null,
                                    color: isActive
                                        ? null
                                        : const Color(0xFF2A1F14),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: isActive
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFFFF6B1A)
                                                  .withValues(alpha: 0.5),
                                              blurRadius: 12,
                                              spreadRadius: 1,
                                            ),
                                          ]
                                        : [],
                                  )
                                : null,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Glow behind active icon
                                if (isActive && !isVoice)
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          const Color(0xFFFF6B1A)
                                              .withValues(alpha: 0.2),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                Icon(
                                  item.icon,
                                  size: isVoice ? 22 : 22,
                                  color: isActive
                                      ? (isVoice
                                          ? Colors.white
                                          : const Color(0xFFFF6B1A))
                                      : const Color(0xFF6B5A4A),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Label — English
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: isActive ? 10 : 9,
                              fontWeight:
                                  isActive ? FontWeight.w700 : FontWeight.w500,
                              color: isActive
                                  ? const Color(0xFFFF6B1A)
                                  : const Color(0xFF6B5A4A),
                              letterSpacing: 0.2,
                            ),
                            child: Text(item.label,
                                overflow: TextOverflow.ellipsis, maxLines: 1),
                          ),

                          // Hindi label below
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w400,
                              color: isActive
                                  ? const Color(0xFFD4930A)
                                      .withValues(alpha: 0.8)
                                  : const Color(0xFF6B5A4A)
                                      .withValues(alpha: 0.5),
                            ),
                            child: Text(item.hindi,
                                overflow: TextOverflow.ellipsis, maxLines: 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),

            // ── TOP TRICOLOR LINE ──
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Row(
                children: [
                  Expanded(
                      child: Container(
                    height: 2,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.transparent,
                        Color(0xFFFF6B1A),
                      ]),
                    ),
                  )),
                  Container(
                    width: 20,
                    height: 2,
                    color: const Color(0xFFF5F5F5).withValues(alpha: 0.3),
                  ),
                  Expanded(
                      child: Container(
                    height: 2,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Color(0xFF138808),
                        Colors.transparent,
                      ]),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String hindi;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.hindi,
  });
}
