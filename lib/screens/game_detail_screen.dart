import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../core/widgets/category_chip.dart';
import '../core/widgets/notification_badge.dart';
import '../data/game_offer.dart';

class GameDetailScreen extends StatefulWidget {
  final GameOffer offer;

  const GameDetailScreen({super.key, required this.offer});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  Timer? _timer;
  Duration? _remaining;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateRemaining());
  }

  void _updateRemaining() {
    if (!mounted) return;
    setState(() => _remaining = widget.offer.timeRemaining);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                offer.title,
                style: AppTypography.label.copyWith(color: Colors.white),
              ),
              background: offer.thumbnailUrl != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(offer.thumbnailUrl!, fit: BoxFit.cover),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppColors.bgBase.withOpacity(0.8),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      color: AppColors.bgElevated,
                      child: Icon(
                        Icons.videogame_asset,
                        size: 80,
                        color: AppColors.interactivePrimary.withOpacity(0.3),
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status badges row
                  Row(
                    children: [
                      if (offer.isFree) ...[
                        NotificationBadge(
                          label: 'FREE',
                          color: AppColors.feedbackNew,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      _PlatformBadge(platform: offer.platform),
                      const Spacer(),
                      if (offer.originalPrice > 0)
                        Text(
                          '¥${offer.originalPrice.toStringAsFixed(0)}',
                          style: AppTypography.h3.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.textMuted,
                            decorationColor: AppColors.textMuted,
                          ),
                        ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('FREE', style: AppTypography.price),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Countdown timer
                  if (_remaining != null) ...[
                    _CountdownCard(remaining: _remaining!),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // Description
                  Text('ゲーム概要', style: AppTypography.h4),
                  const SizedBox(height: AppSpacing.sm),
                  Text(offer.description, style: AppTypography.body),
                  const SizedBox(height: AppSpacing.lg),

                  // Genre chips
                  if (offer.genres.isNotEmpty) ...[
                    Text('ジャンル', style: AppTypography.h4),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: offer.genres
                          .map((g) => CategoryChip(label: g))
                          .toList(),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  // CTA button
                  if (offer.isFree)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () => _openStore(context),
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: const Text('ストアで無料入手'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.interactivePrimary,
                          textStyle: AppTypography.label.copyWith(fontSize: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.buttonRadius),
                          ),
                        ),
                      ),
                    ),
                  if (offer.isUpcoming)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () => _openStore(context),
                        icon: const Icon(Icons.schedule, size: 18),
                        label: const Text('ストアを開く（準備中）'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: BorderSide(color: AppColors.borderDefault),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.buttonRadius),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xl4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openStore(BuildContext context) {
    // url_launcher を使う場合: launchUrl(Uri.parse(offer.storeUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('ストアを開きます: ${widget.offer.storeUrl}')),
    );
  }
}

class _CountdownCard extends StatelessWidget {
  final Duration remaining;
  const _CountdownCard({required this.remaining});

  @override
  Widget build(BuildContext context) {
    final days = remaining.inDays;
    final hours = remaining.inHours % 24;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;

    final isUrgent = remaining.inHours < 24;
    final accentColor =
        isUrgent ? AppColors.feedbackExpiring : AppColors.interactivePrimary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.paddingComfortable),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: accentColor),
              const SizedBox(width: AppSpacing.xs),
              Text(
                isUrgent ? '⚠ まもなく終了！' : '無料期間残り',
                style: AppTypography.labelSmall.copyWith(color: accentColor),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (days > 0) _TimeUnit(value: days, label: '日'),
              _TimeUnit(value: hours, label: '時間'),
              _TimeUnit(value: minutes, label: '分'),
              _TimeUnit(value: seconds, label: '秒'),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeUnit extends StatelessWidget {
  final int value;
  final String label;
  const _TimeUnit({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: AppTypography.timer.copyWith(fontSize: 32, letterSpacing: 2),
        ),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}

class _PlatformBadge extends StatelessWidget {
  final String platform;
  const _PlatformBadge({required this.platform});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (platform) {
      'epic' => ('EPIC GAMES', AppColors.interactivePrimary),
      'steam' => ('STEAM', AppColors.interactiveAccent),
      'gog' => ('GOG', AppColors.platformGOG),
      _ => ('OTHER', AppColors.textMuted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style:
            AppTypography.labelSmall.copyWith(color: color, letterSpacing: 0.8),
      ),
    );
  }
}
