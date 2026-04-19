import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/notification_provider.dart';
import '../../../widgets/t_text.dart';
import '../../../core/router/app_router.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// NOTIFICATIONS SCREEN V2
// ═══════════════════════════════════════════════════════════════════════════════

class NotificationsScreenV2 extends StatefulWidget {
  const NotificationsScreenV2({super.key});

  @override
  State<NotificationsScreenV2> createState() => _NotificationsScreenV2State();
}

class _NotificationsScreenV2State extends State<NotificationsScreenV2> {
  int _filterIdx = 0; // 0=All, 1=Updates, 2=Deadlines, 3=Tips

  static const _filterLabels = ['All', 'Updates', 'Deadlines', 'Tips'];

  List<CVINotification> _filtered(List<CVINotification> all) {
    if (_filterIdx == 0) return all;
    if (_filterIdx == 1) {
      return all
          .where((n) =>
              n.type == NotificationType.serviceUpdate ||
              n.type == NotificationType.system)
          .toList();
    }
    if (_filterIdx == 2) {
      return all
          .where((n) =>
              n.type == NotificationType.newScheme ||
              n.type == NotificationType.applicationStatus)
          .toList();
    }
    if (_filterIdx == 3) {
      return all.where((n) => n.type == NotificationType.tip).toList();
    }
    return all;
  }

  @override
  Widget build(BuildContext context) {
    final np = context.watch<NotificationProvider>();
    final filtered = _filtered(np.notifications);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(np),
            _buildTabs(),
            if (_filterIdx == 0 || _filterIdx == 2)
              _buildStaticDeadlinesBanner(),
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 16, bottom: 24),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          child: _NotificationDismissibleCard(
                            key: ValueKey(filtered[i].id),
                            notification: filtered[i],
                            index: i,
                            onDismissed: (dir) {
                              if (dir == DismissDirection.startToEnd) {
                                context
                                    .read<NotificationProvider>()
                                    .markAsRead(filtered[i].id);
                              } else {
                                context
                                    .read<NotificationProvider>()
                                    .deleteNotification(filtered[i].id);
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

  // ─── UI COMPONENTS ────────────────────────────────────────────────────────

  Widget _buildAppBar(NotificationProvider np) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded,
                    color: AppColors.textPrimary, size: 20),
                onPressed: () => context.pop(),
              ),
              const SizedBox(width: 8),
              const TText(
                'Notifications',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.saffron),
              ),
            ],
          ),
          if (np.hasUnread || np.notifications.isNotEmpty)
            Row(
              children: [
                if (np.hasUnread)
                  GestureDetector(
                    onTap: np.markAllAsRead,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: AppColors.saffron.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20)),
                      child: const TText('Mark read',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.saffron)),
                    ),
                  ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.bgMid,
                        title: const TText('Clear All?'),
                        content: const TText(
                            'This will delete all your notifications permanently.'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const TText('Cancel')),
                          TextButton(
                            onPressed: () {
                              np.clearAll();
                              Navigator.pop(ctx);
                            },
                            child: const TText('Clear',
                                style:
                                    TextStyle(color: AppColors.semanticError)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: AppColors.semanticError.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20)),
                    child: const TText('Clear All',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.semanticError)),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(4, (i) {
          final active = i == _filterIdx;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filterIdx = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.accentBlue.withValues(alpha: 0.15)
                      : AppColors.bgMid,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: active
                          ? AppColors.accentBlue
                          : AppColors.surfaceBorder,
                      width: active ? 1.5 : 1),
                ),
                child: TText(
                  _filterLabels[i],
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active
                          ? AppColors.accentBlue
                          : AppColors.textSecondary),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStaticDeadlinesBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      height: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TText('Important Deadlines',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildDeadlineCard('ITR Filing', 'July 31, 2025',
                    Icons.account_balance_rounded, AppColors.saffron),
                const SizedBox(width: 12),
                _buildDeadlineCard('GST Return', '20th Every Month',
                    Icons.receipt_long_rounded, AppColors.accentBlue),
                const SizedBox(width: 12),
                _buildDeadlineCard('PM-KISAN', 'Installment Soon',
                    Icons.agriculture_rounded, AppColors.emeraldLight),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(delay: 100.ms),
    );
  }

  Widget _buildDeadlineCard(
      String title, String date, IconData icon, Color color) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgMid,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                    maxLines: 1),
                const SizedBox(height: 2),
                Text(date,
                    style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: color,
                        fontWeight: FontWeight.w600),
                    maxLines: 1),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentBlue.withValues(alpha: 0.05),
              border: Border.all(
                  color: AppColors.accentBlue.withValues(alpha: 0.2)),
            ),
            child: const Icon(Icons.notifications_active_outlined,
                color: AppColors.textMuted, size: 38),
          ),
          const SizedBox(height: 24),
          const TText('All Caught Up!',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const TText('No notifications in this category.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        ],
      ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }
}

// ─── LIST ITEM CARDS ────────────────────────────────────────────────────────

class _NotificationDismissibleCard extends StatelessWidget {
  final CVINotification notification;
  final int index;
  final void Function(DismissDirection) onDismissed;

  const _NotificationDismissibleCard({
    super.key,
    required this.notification,
    required this.index,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(notification.id),
      background: const _SwipeBackground(isLeft: true),
      secondaryBackground: const _SwipeBackground(isLeft: false),
      onDismissed: onDismissed,
      child: InkWell(
        onTap: () {
          context.read<NotificationProvider>().markAsRead(notification.id);
          if (notification.serviceId != null) {
            context.push(Routes.services);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: _NotificationCard(notification: notification, index: index),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  final bool isLeft;
  const _SwipeBackground({required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isLeft
            ? AppColors.emerald.withValues(alpha: 0.2)
            : AppColors.semanticError.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLeft) ...[
            const Icon(Icons.mark_email_read_rounded,
                color: AppColors.emeraldLight, size: 24),
            const SizedBox(width: 8),
            Text('Read',
                style: GoogleFonts.poppins(
                    color: AppColors.emeraldLight,
                    fontWeight: FontWeight.w600)),
          ] else ...[
            Text('Delete',
                style: GoogleFonts.poppins(
                    color: AppColors.semanticError,
                    fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            const Icon(Icons.delete_outline_rounded,
                color: AppColors.semanticError, size: 24),
          ],
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final CVINotification notification;
  final int index;
  const _NotificationCard({required this.notification, required this.index});

  Color _color() => switch (notification.type) {
        NotificationType.serviceUpdate => AppColors.accentBlue,
        NotificationType.applicationStatus => AppColors.gold,
        NotificationType.newScheme => AppColors.emeraldLight,
        NotificationType.tip => AppColors.saffron,
        NotificationType.system => AppColors.textMuted,
      };

  IconData _icon() => switch (notification.type) {
        NotificationType.serviceUpdate => Icons.update_rounded,
        NotificationType.applicationStatus => Icons.folder_special_rounded,
        NotificationType.newScheme => Icons.new_releases_rounded,
        NotificationType.tip => Icons.lightbulb_outline_rounded,
        NotificationType.system => Icons.info_outline_rounded,
      };

  String _time() {
    final diff = DateTime.now().difference(notification.createdAt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays <= 30) return '${diff.inDays}d ago';
    return '${diff.inDays ~/ 30}mo ago';
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    final isUnread = !notification.isRead;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread
            ? AppColors.bgDark
            : AppColors.bgMid.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
              color: isUnread ? color : Colors.transparent, width: 4),
          top: const BorderSide(color: AppColors.surfaceBorder),
          right: const BorderSide(color: AppColors.surfaceBorder),
          bottom: const BorderSide(color: AppColors.surfaceBorder),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(_icon(), color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(notification.type.name.toUpperCase(),
                        style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: color)),
                    Text(_time(),
                        style: GoogleFonts.jetBrainsMono(
                            fontSize: 10, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  notification.title,
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.body,
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4),
                ),
              ],
            ),
          ),
          if (isUnread) ...[
            const SizedBox(width: 12),
            Container(
                margin: const EdgeInsets.only(top: 8),
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle)),
          ]
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 50 * index))
        .slideY(begin: 0.1, end: 0);
  }
}
