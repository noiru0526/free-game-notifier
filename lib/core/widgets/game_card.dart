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
  final bool isNew;

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
    this.isNew = false,
  });
}

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: _borderColor(),
            width: offer.status == GameStatus.expiringSoon ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _glowColor().withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Thumbnail(offer: offer),
                Expanded(child: _CardContent(offer: offer, onClaim: onClaim)),
              ],
            ),
            if (offer.isNew)
              Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: NotificationBadge(label: 'NEW', color: AppColors.feedbackNew),
              ),
            if (offer.status == GameStatus.claimed)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  ),
                  alignment: Alignment.center,
                  child: const _ClaimedStamp(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _borderColor() {
    switch (offer.status) {
      case GameStatus.expiringSoon: return AppColors.feedbackExpiring.withOpacity(0.5);
      case GameStatus.expired:      return AppColors.borderMuted;
      case GameStatus.claimed:      return AppColors.borderMuted;
      case GameStatus.free:         return AppColors.borderDefault;
    }
  }

  Color _glowColor() {
    switch (offer.status) {
      case GameStatus.expiringSoon: return AppColors.feedbackExpiring;
      case GameStatus.free:         return AppColors.interactivePrimary;
      default:                      return Colors.transparent;
    }
  }
}

class _Thumbnail extends StatelessWidget {
  final GameOffer offer;
  const _Thumbnail({required this.offer});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppSpacing.cardRadius)),
      child: SizedBox(
        width: AppSpacing.gameThumbnailWidth,
        height: AppSpacing.gameThumbnailHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (offer.thumbnailUrl != null)
              Image.network(
                offer.thumbnailUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _PlaceholderThumbnail(platform: offer.platform),
              )
            else
              _PlaceholderThumbnail(platform: offer.platform),
            // Platform badge bottom-left
            Positioned(
              left: AppSpacing.xs,
              bottom: AppSpacing.xs,
              child: _PlatformBadge(platform: offer.platform),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderThumbnail extends StatelessWidget {
  final Platform platform;
  const _PlaceholderThumbnail({required this.platform});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgElevated,
      child: Icon(
        Icons.videogame_asset,
        size: 40,
        color: _platformColor(platform).withOpacity(0.4),
      ),
    );
  }

  Color _platformColor(Platform p) {
    switch (p) {
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
  const _PlatformBadge({required this.platform});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        _name(platform),
        style: AppTypography.labelSmall.copyWith(color: Colors.white, fontSize: 8),
      ),
    );
  }

  String _name(Platform p) {
    switch (p) {
      case Platform.epic:   return 'EPIC';
      case Platform.steam:  return 'STEAM';
      case Platform.gog:    return 'GOG';
      case Platform.origin: return 'EA';
      case Platform.itchio: return 'ITCH';
    }
  }
}

class _CardContent extends StatelessWidget {
  final GameOffer offer;
  final VoidCallback? onClaim;
  const _CardContent({required this.offer, this.onClaim});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + price
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  offer.title,
                  style: AppTypography.h4,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _PriceTag(offer: offer),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          // Description
          Text(
            offer.description,
            style: AppTypography.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),
          // Genre chips + timer row
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: offer.genres
                      .take(3)
                      .map((g) => CategoryChip(label: g))
                      .toList(),
                ),
              ),
              if (offer.expiresAt != null && offer.status == GameStatus.expiringSoon)
                _ExpiryTimer(expiresAt: offer.expiresAt!),
            ],
          ),
          if (offer.status == GameStatus.free || offer.status == GameStatus.expiringSoon)
            ...[
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 32,
                child: ElevatedButton(
                  onPressed: onClaim,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: offer.status == GameStatus.expiringSoon
                        ? AppColors.feedbackExpiring
                        : AppColors.interactivePrimary,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    minimumSize: const Size(0, 32),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
                  ),
                  child: Text(
                    offer.status == GameStatus.expiringSoon ? '今すぐ無料で入手' : '無料で入手',
                    style: AppTypography.label,
                  ),
                ),
              ),
            ],
        ],
      ),
    );
  }
}

class _PriceTag extends StatelessWidget {
  final GameOffer offer;
  const _PriceTag({required this.offer});

  @override
  Widget build(BuildContext context) {
    if (offer.status == GameStatus.expired) {
      return Text('終了', style: AppTypography.labelSmall.copyWith(color: AppColors.feedbackExpired));
    }
    if (offer.status == GameStatus.claimed) {
      return Text('取得済み', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (offer.originalPrice != null && offer.originalPrice! > 0)
          Text(
            '¥${offer.originalPrice!.toStringAsFixed(0)}',
            style: AppTypography.caption.copyWith(
              decoration: TextDecoration.lineThrough,
              color: AppColors.textMuted,
            ),
          ),
        Text('FREE', style: AppTypography.price),
      ],
    );
  }
}

class _ExpiryTimer extends StatelessWidget {
  final DateTime expiresAt;
  const _ExpiryTimer({required this.expiresAt});

  @override
  Widget build(BuildContext context) {
    final remaining = expiresAt.difference(DateTime.now());
    final hours = remaining.inHours;
    final mins  = remaining.inMinutes % 60;
    final label = hours > 24
        ? '${(hours / 24).floor()}日後'
        : hours > 0 ? '${hours}h ${mins}m' : '${mins}m';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.access_time, size: 11, color: AppColors.feedbackExpiring),
        const SizedBox(width: 3),
        Text(label, style: AppTypography.timer.copyWith(fontSize: 11)),
      ],
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
