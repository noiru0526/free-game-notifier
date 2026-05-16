import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

/// Notification count badge — wraps a widget and shows count in top-right corner
class NotificationCountBadge extends StatelessWidget {
  final Widget child;
  final int count;
  final bool visible;

  const NotificationCountBadge({
    super.key,
    required this.child,
    required this.count,
    this.visible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible || count <= 0) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -4,
          right: -4,
          child: _BadgeBubble(
            label: count > 99 ? '99+' : '$count',
            color: AppColors.feedbackExpired,
          ),
        ),
      ],
    );
  }
}

/// Standalone label badge (NEW, FREE, HOT, etc.)
class NotificationBadge extends StatelessWidget {
  final String label;
  final Color? color;

  const NotificationBadge({
    super.key,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return _BadgeBubble(label: label, color: color ?? AppColors.feedbackNew);
  }
}

class _BadgeBubble extends StatelessWidget {
  final String label;
  final Color color;

  const _BadgeBubble({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      constraints: const BoxConstraints(
        minWidth: AppSpacing.badgeRadius * 2,
        minHeight: AppSpacing.badgeRadius * 2,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSpacing.badgeRadius),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        label,
        style: AppTypography.badge,
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Status indicator dot (online-style)
class StatusDot extends StatelessWidget {
  final Color color;
  final double size;

  const StatusDot({
    super.key,
    required this.color,
    this.size = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.5), blurRadius: 4),
        ],
      ),
    );
  }
}

/// Animated pulsing dot for "new" status
class PulsingDot extends StatefulWidget {
  final Color color;
  final double size;

  const PulsingDot({super.key, required this.color, this.size = 8});

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(seconds: 2), vsync: this)
      ..repeat();
    _scale   = Tween<double>(begin: 1.0, end: 1.6).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _opacity = Tween<double>(begin: 0.6, end: 0.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 2,
      height: widget.size * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Transform.scale(
              scale: _scale.value,
              child: Opacity(
                opacity: _opacity.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          StatusDot(color: widget.color, size: widget.size),
        ],
      ),
    );
  }
}
