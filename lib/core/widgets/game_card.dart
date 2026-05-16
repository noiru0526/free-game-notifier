import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import 'category_chip.dart';
import 'notification_badge.dart';

enum GameStatus { free, expiringSoon, expired, claimed }
enum Platform   { epic, steam, gog, origin, itchio }

class GameOffer {
  final String id;
  final String title;
  final String description;
  final String? thumbnailUrl;
  final GameStatus status;
  final Platform platform;
  final List<String> genres;
  final DateTime? expiresAt;
  final double? originalPrice;
  final double? discountedPrice;
  final double? discountPercentage;
  final bool isNew;
  final String? aiRecommendation;

  const GameOffer({
    required this.id,
    required this.title,
    required this.description,
    this.thumbnailUrl,
    required this.status,
    required this.platform,
    this.genres = const [],
    this.expiresAt,
    this.originalPrice,
    this.discountedPrice,
    this.discountPercentage,
    this.isNew = false,
    this.aiRecommendation,
  });

  bool get isDiscounted => (discountPercentage ?? 0) > 0 && status != GameStatus.free;
}

// ─────────────────────────────────────────────
// Hero Card (featured / top-of-feed)
// ─────────────────────────────────────────────
class HeroGameCard extends StatelessWidget {
  final GameOffer offer;
  final VoidCallback? onTap;
  final VoidCallback? onClaim;

  const HeroGameCard({
    super.key,
    required this.offer,
    this.onTap,
    this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius + 4),
          boxShadow: [
            BoxShadow(
              color: _accentColor().withOpacity(0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius + 4),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              if (offer.thumbnailUrl != null)
                Image.network(
                  offer.thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallbackBg(),
                )
              else
                _fallbackBg(),

              // Gradient overlay
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.85),
                    ],
                    stops: const [0.3, 0.6, 1.0],
                  ),
                ),
              ),

              // Top row: platform + FREE badge
              Positioned(
                top: AppSpacing.md,
                left: AppSpacing.md,
                right: AppSpacing.md,
                child: Row(
                  children: [
                    _PlatformBadge(platform: offer.platform, large: true),
                    const Spacer(),
                    _FreeBadge(offer: offer, large: true),
                  ],
                ),
              ),

              // Bottom content
              Positioned(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: AppSpacing.lg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Genre chips
                    Wrap(
                      spacing: AppSpacing.xs,
                      children: offer.genres.take(2).map((g) =>
                        CategoryChip(label: g, small: true)
                      ).toList(),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      offer.title,
                      style: AppTypography.h2.copyWith(
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 8),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (offer.expiresAt != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      _CountdownTimer(expiresAt: offer.expiresAt!, large: true),
                    ],
                    if (offer.status == GameStatus.free || offer.status == GameStatus.expiringSoon) ...[
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: onClaim,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: offer.status == GameStatus.expiringSoon
                                ? AppColors.feedbackExpiring
                                : AppColors.interactivePrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                            ),
                          ),
                          child: Text(
                            offer.status == GameStatus.expiringSoon ? '今すぐ無料で入手' : '無料で入手',
                            style: AppTypography.label.copyWith(fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // NEW badge
              if (offer.isNew)
                Positioned(
                  top: AppSpacing.md,
                  right: AppSpacing.md + 60,
                  child: NotificationBadge(label: 'NEW', color: AppColors.feedbackNew),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallbackBg() => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_accentColor().withOpacity(0.3), AppColors.bgElevated],
      ),
    ),
    child: Icon(Icons.videogame_asset, size: 64, color: _accentColor().withOpacity(0.4)),
  );

  Color _accentColor() {
    switch (offer.platform) {
      case Platform.epic:   return AppColors.interactivePrimary;
      case Platform.steam:  return AppColors.interactiveAccent;
      case Platform.gog:    return AppColors.platformGOG;
      case Platform.origin: return AppColors.platformOrigin;
      case Platform.itchio: return AppColors.platformITchio;
    }
  }
}

// ─────────────────────────────────────────────
// Standard Game Card (vertical layout)
// ─────────────────────────────────────────────
class GameCard extends StatelessWidget {
  final GameOffer offer;
  final VoidCallback? onTap;
  final VoidCallback? onClaim;

  const GameCard({
    super.key,
    required this.offer,
    this.onTap,
    this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final isExpiring = offer.status == GameStatus.expiringSoon;
    final isClaimed  = offer.status == GameStatus.claimed;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: isExpiring
                ? AppColors.feedbackExpiring.withOpacity(0.6)
                : AppColors.borderDefault,
            width: isExpiring ? 1.5 : 1.0,
          ),
          boxShadow: isExpiring
              ? [BoxShadow(
                  color: AppColors.feedbackExpiring.withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                )]
              : [BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Image area ──
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.cardRadius),
                  ),
                  child: SizedBox(
                    height: 140,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Thumbnail
                        if (offer.thumbnailUrl != null)
                          Image.network(
                            offer.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _PlaceholderImage(offer: offer),
                          )
                        else
                          _PlaceholderImage(offer: offer),

                        // Bottom gradient on image
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  AppColors.bgSurface.withOpacity(0.7),
                                ],
                                stops: const [0.5, 1.0],
                              ),
                            ),
                          ),
                        ),

                        // Platform badge — top left
                        Positioned(
                          top: AppSpacing.sm,
                          left: AppSpacing.sm,
                          child: _PlatformBadge(platform: offer.platform),
                        ),

                        // FREE / discount badge — top right
                        Positioned(
                          top: AppSpacing.sm,
                          right: AppSpacing.sm,
                          child: _FreeBadge(offer: offer),
                        ),

                        // Countdown — bottom left of image
                        if (offer.expiresAt != null && isExpiring)
                          Positioned(
                            bottom: AppSpacing.sm,
                            left: AppSpacing.sm,
                            child: _CountdownTimer(expiresAt: offer.expiresAt!),
                          ),
                      ],
                    ),
                  ),
                ),

                // ── Text content ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.title,
                        style: AppTypography.h4,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        offer.description,
                        style: AppTypography.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      // Genre chips
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: offer.genres.take(3)
                            .map((g) => CategoryChip(label: g))
                            .toList(),
                      ),

                      // AI recommendation
                      if (offer.aiRecommendation != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        _AiRecommendationBadge(text: offer.aiRecommendation!),
                      ],

                      // Claim button
                      if (!isClaimed &&
                          (offer.status == GameStatus.free || isExpiring)) ...[
                        const SizedBox(height: AppSpacing.md),
                        SizedBox(
                          width: double.infinity,
                          height: 36,
                          child: ElevatedButton(
                            onPressed: onClaim,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isExpiring
                                  ? AppColors.feedbackExpiring
                                  : AppColors.interactivePrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.buttonRadius),
                              ),
                            ),
                            child: Text(
                              isExpiring ? '今すぐ無料で入手' : '無料で入手',
                              style: AppTypography.label,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            // Claimed overlay
            if (isClaimed)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    alignment: Alignment.center,
                    child: const _ClaimedStamp(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────

class _PlaceholderImage extends StatelessWidget {
  final GameOffer offer;
  const _PlaceholderImage({required this.offer});

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.2), AppColors.bgElevated],
        ),
      ),
      child: Icon(Icons.videogame_asset, size: 48, color: color.withOpacity(0.3)),
    );
  }

  Color _color() {
    switch (offer.platform) {
      case Platform.epic:   return AppColors.interactivePrimary;
      case Platform.steam:  return AppColors.interactiveAccent;
      case Platform.gog:    return AppColors.platformGOG;
      case Platform.origin: return AppColors.platformOrigin;
      case Platform.itchio: return AppColors.platformITchio;
    }
  }
}

class _PlatformBadge extends StatelessWidget {
  final Platform platform;
  final bool large;
  const _PlatformBadge({required this.platform, this.large = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 8 : 6,
        vertical: large ? 4 : 2,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Text(
        _name(),
        style: TextStyle(
          color: Colors.white,
          fontSize: large ? 10 : 8,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _name() {
    switch (platform) {
      case Platform.epic:   return 'EPIC';
      case Platform.steam:  return 'STEAM';
      case Platform.gog:    return 'GOG';
      case Platform.origin: return 'EA';
      case Platform.itchio: return 'ITCH';
    }
  }
}

class _FreeBadge extends StatelessWidget {
  final GameOffer offer;
  final bool large;
  const _FreeBadge({required this.offer, this.large = false});

  @override
  Widget build(BuildContext context) {
    if (offer.isDiscounted) {
      return _badge(
        '-${offer.discountPercentage!.round()}%',
        const Color(0xFFFF6B00),
      );
    }
    if (offer.status == GameStatus.free || offer.status == GameStatus.expiringSoon) {
      return _badge('FREE', AppColors.interactivePrimary);
    }
    return const SizedBox.shrink();
  }

  Widget _badge(String text, Color color) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: large ? 10 : 7,
      vertical: large ? 5 : 3,
    ),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(4),
      boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)],
    ),
    child: Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: large ? 12 : 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    ),
  );
}

class _CountdownTimer extends StatefulWidget {
  final DateTime expiresAt;
  final bool large;
  const _CountdownTimer({required this.expiresAt, this.large = false});

  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.expiresAt.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _remaining = widget.expiresAt.difference(DateTime.now());
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining.isNegative) {
      return const SizedBox.shrink();
    }

    final d = _remaining.inDays;
    final h = _remaining.inHours % 24;
    final m = _remaining.inMinutes % 60;
    final s = _remaining.inSeconds % 60;

    final label = d > 0
        ? 'あと${d}日${h}時間'
        : h > 0
            ? 'あと${h}h ${m}m'
            : 'あと${m}分${s}秒';

    final isUrgent = _remaining.inHours < 24;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 10 : 7,
        vertical: large ? 4 : 3,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isUrgent
              ? AppColors.feedbackExpiring.withOpacity(0.7)
              : Colors.white.withOpacity(0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: large ? 13 : 10,
            color: isUrgent ? AppColors.feedbackExpiring : Colors.white70,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isUrgent ? AppColors.feedbackExpiring : Colors.white,
              fontSize: large ? 12 : 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiRecommendationBadge extends StatelessWidget {
  final String text;
  const _AiRecommendationBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7B2FBE).withOpacity(0.25),
            const Color(0xFF00BFFF).withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF7B2FBE).withOpacity(0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✦', style: TextStyle(
            color: Color(0xFFB06FFF),
            fontSize: 11,
            height: 1.4,
          )),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: AppTypography.caption.copyWith(
                color: const Color(0xFFD0AAFF),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClaimedStamp extends StatelessWidget {
  const _ClaimedStamp();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.2,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.interactiveAccent, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '取得済み',
          style: AppTypography.h3.copyWith(
            color: AppColors.interactiveAccent,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
