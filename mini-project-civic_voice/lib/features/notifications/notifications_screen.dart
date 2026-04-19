import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/notification_provider.dart';

// ═════════════════════════════════════════════════════════════════════════════
// NOTIFICATIONS SCREEN
// ═════════════════════════════════════════════════════════════════════════════

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _filterIdx = 0; // 0=All 1=Services 2=Applications 3=System

  static const _filterLabels = ['All', 'Services', 'Applications', 'System'];

  static const _filterTypes = [
    null, // All
    NotificationType.serviceUpdate,
    NotificationType.applicationStatus,
    NotificationType.system,
  ];

  List<CVINotification> _filtered(List<CVINotification> all) {
    final type = _filterTypes[_filterIdx];
    if (type == null) return all;
    // Map "Services" also to newScheme
    if (_filterIdx == 1) {
      return all
          .where((n) =>
              n.type == NotificationType.serviceUpdate ||
              n.type == NotificationType.newScheme)
          .toList();
    }
    return all.where((n) => n.type == type).toList();
  }

  @override
  Widget build(BuildContext context) {
    final np       = context.watch<NotificationProvider>();
    final filtered = _filtered(np.notifications);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded,
                        color: AppColors.textSecondary, size: 20),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Notifications',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Rajdhani',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  // Badge count + mark all read
                  if (np.hasUnread)
                    TextButton(
                      onPressed: np.markAllAsRead,
                      child: Text(
                        'Mark all read',
                        style: TextStyle(
                            color: AppColors.accent.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontFamily: 'Rajdhani'),
                      ),
                    ),
                ],
              ),
            ),

            // ── Filter chips ─────────────────────────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: List.generate(4, (i) {
                  final active = i == _filterIdx;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filterIdx = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.accent.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: active ? AppColors.accent : AppColors.border,
                            width: active ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          _filterLabels[i],
                          style: TextStyle(
                            color: active
                                ? AppColors.accent
                                : AppColors.textSecondary,
                            fontSize: 13,
                            fontFamily: 'Rajdhani',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // ── Notification list ─────────────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? _EmptyState()
                  : ListView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _DismissibleCard(
                            key: ValueKey(filtered[i].id),
                            notification: filtered[i],
                            index: i,
                            onDismissed: (dir) {
                              final np = context.read<NotificationProvider>();
                              if (dir == DismissDirection.startToEnd) {
                                np.markAsRead(filtered[i].id);
                              } else {
                                np.deleteNotification(filtered[i].id);
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dismissible notification card ────────────────────────────────────────────

class _DismissibleCard extends StatelessWidget {
  final CVINotification notification;
  final int index;
  final void Function(DismissDirection) onDismissed;

  const _DismissibleCard({
    super.key,
    required this.notification,
    required this.index,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(notification.id),
      background: const _SwipeBackground(direction: DismissDirection.startToEnd),
      secondaryBackground: const _SwipeBackground(direction: DismissDirection.endToStart),
      onDismissed: onDismissed,
      child: _NotificationCard(notification: notification, index: index),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  final DismissDirection direction;
  const _SwipeBackground({required this.direction});

  bool get _isLeft => direction == DismissDirection.startToEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _isLeft
            ? AppColors.success.withValues(alpha: 0.2)
            : AppColors.error.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: _isLeft ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isLeft) ...[
            const Icon(Icons.done_all_rounded, color: AppColors.success, size: 22),
            const SizedBox(width: 6),
            const Text('Read',
                style: TextStyle(
                    color: AppColors.success,
                    fontFamily: 'Rajdhani',
                    fontWeight: FontWeight.w700)),
          ] else ...[
            const Text('Delete',
                style: TextStyle(
                    color: AppColors.error,
                    fontFamily: 'Rajdhani',
                    fontWeight: FontWeight.w700)),
            const SizedBox(width: 6),
            const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 22),
          ],
        ],
      ),
    );
  }
}

// ── Notification card ─────────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final CVINotification notification;
  final int index;
  const _NotificationCard({required this.notification, required this.index});

  static Color _borderColor(NotificationType type) => switch (type) {
        NotificationType.serviceUpdate     => AppColors.primary,
        NotificationType.applicationStatus => const Color(0xFFFFB300),
        NotificationType.newScheme         => AppColors.accent,
        NotificationType.system            => AppColors.border,
        NotificationType.tip               => AppColors.accent,
      };

  static IconData _icon(NotificationType type) => switch (type) {
        NotificationType.serviceUpdate     => Icons.update_rounded,
        NotificationType.applicationStatus => Icons.assignment_turned_in_outlined,
        NotificationType.newScheme         => Icons.new_releases_rounded,
        NotificationType.system            => Icons.info_outline_rounded,
        NotificationType.tip               => Icons.lightbulb_outline_rounded,
      };

  static String _typeLabel(NotificationType type) => switch (type) {
        NotificationType.serviceUpdate     => 'Service Update',
        NotificationType.applicationStatus => 'Application',
        NotificationType.newScheme         => 'New Scheme',
        NotificationType.system            => 'System',
        NotificationType.tip               => 'Quick Tip',
      };

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60)  return 'Just now';
    if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)    return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final color = _borderColor(notification.type);
    final unread = !notification.isRead;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: unread
                ? AppColors.surface.withValues(alpha: 0.5)
                : AppColors.backgroundCard.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(color: color, width: 3),
              top: BorderSide(color: AppColors.border.withValues(alpha: 0.5), width: 1),
              right: BorderSide(color: AppColors.border.withValues(alpha: 0.5), width: 1),
              bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5), width: 1),
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon(notification.type), color: color, size: 20),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _typeLabel(notification.type),
                            style: TextStyle(
                                color: color,
                                fontSize: 9,
                                fontFamily: 'SpaceMono',
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _relativeTime(notification.createdAt),
                          style: const TextStyle(
                              color: AppColors.textDisabled,
                              fontSize: 10,
                              fontFamily: 'SpaceMono'),
                        ),
                        if (unread) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: color.withValues(alpha: 0.5),
                                    blurRadius: 6)
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.title,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontFamily: 'Rajdhani',
                        fontWeight:
                            unread ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 60 * index))
        .slideY(
            begin: 0.06,
            end: 0,
            delay: Duration(milliseconds: 60 * index));
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withValues(alpha: 0.06),
              border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.15), width: 1),
            ),
            child: const Icon(Icons.notifications_none_rounded,
                color: AppColors.border, size: 38),
          ),
          const SizedBox(height: 16),
          const Text(
            'All caught up! 🎉',
            style: TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'No notifications in this category.',
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.92, 0.92)),
    );
  }
}
