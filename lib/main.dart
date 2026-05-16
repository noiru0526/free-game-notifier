import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_spacing.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';
import 'core/widgets/category_chip.dart';
import 'core/widgets/game_card.dart';
import 'core/widgets/notification_badge.dart';
import 'data/game_offer.dart' as data;
import 'data/game_offer_repository.dart';
import 'screens/game_detail_screen.dart';

void main() {
  runApp(const FreeGameNotifierApp());
}

class FreeGameNotifierApp extends StatelessWidget {
  const FreeGameNotifierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '無料ゲーム通知',
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

// ===== Screens =====

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  static const _screens = [
    _GameListView(),
    _SearchView(),
    _SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    final newCount = _sampleOffers.where((o) => o.isNew).length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('無料ゲーム'),
            const SizedBox(width: AppSpacing.sm),
            NotificationBadge(
              label: '$newCount',
              color: AppColors.feedbackNew,
            ),
          ],
        ),
        actions: [
          NotificationCountBadge(
            count: newCount,
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
              tooltip: '通知',
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: _screens[_navIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.videogame_asset_outlined),
            activeIcon: Icon(Icons.videogame_asset),
            label: 'ゲーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '検索',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
      ),
    );
  }
}

class _GameListView extends StatefulWidget {
  const _GameListView();

  @override
  State<_GameListView> createState() => _GameListViewState();
}

class _GameListViewState extends State<_GameListView> {
  final _repo = MockGameOfferRepository();
  late Future<List<data.GameOffer>> _offersFuture;
  String _selectedCategory = 'すべて';

  static const _categories = [
    'すべて', 'Action', 'RPG', 'Indie', 'Strategy', 'Adventure', 'Shooter',
  ];

  @override
  void initState() {
    super.initState();
    _offersFuture = _repo.fetchFreeGames();
  }

  void _refresh() {
    setState(() {
      _offersFuture = _repo.fetchFreeGames();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<data.GameOffer>>(
      future: _offersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.interactivePrimary),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppColors.feedbackExpired),
                const SizedBox(height: AppSpacing.md),
                Text('データの取得に失敗しました', style: AppTypography.body),
                const SizedBox(height: AppSpacing.sm),
                ElevatedButton(onPressed: _refresh, child: const Text('再試行')),
              ],
            ),
          );
        }

        final allOffers = snapshot.data ?? [];
        final filtered = _selectedCategory == 'すべて'
            ? allOffers
            : allOffers
                .where((o) => o.genres.any(
                    (g) => g.toLowerCase() == _selectedCategory.toLowerCase()))
                .toList();

        final expiringSoon = filtered
            .where((o) => o.isFree && _isExpiringSoon(o))
            .toList();
        final freeNow = filtered
            .where((o) => o.isFree && !_isExpiringSoon(o))
            .toList();
        final upcoming = filtered.where((o) => o.isUpcoming).toList();

        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          color: AppColors.interactivePrimary,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: CategoryChipRow(
                    categories: _categories,
                    selected: [_selectedCategory],
                    onTap: (cat) => setState(() => _selectedCategory = cat),
                  ),
                ),
              ),
              if (expiringSoon.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
                    child: Row(
                      children: [
                        PulsingDot(color: AppColors.feedbackExpiring),
                        const SizedBox(width: AppSpacing.sm),
                        Text('まもなく終了',
                            style: AppTypography.h4
                                .copyWith(color: AppColors.feedbackExpiring)),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _OfferTile(
                      offer: expiringSoon[i],
                      onClaim: () => _showClaimDialog(context, expiringSoon[i]),
                    ),
                    childCount: expiringSoon.length,
                  ),
                ),
              ],
              if (freeNow.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm),
                    child: Text('無料で入手できるゲーム', style: AppTypography.h4),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _OfferTile(
                      offer: freeNow[i],
                      onClaim: () => _showClaimDialog(context, freeNow[i]),
                    ),
                    childCount: freeNow.length,
                  ),
                ),
              ],
              if (upcoming.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm),
                    child: Row(
                      children: [
                        Icon(Icons.schedule, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: AppSpacing.xs),
                        Text('近日無料予定',
                            style: AppTypography.h4.copyWith(color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _OfferTile(offer: upcoming[i]),
                    childCount: upcoming.length,
                  ),
                ),
              ],
              if (filtered.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl4),
                    child: Center(
                      child: Text(
                        '$_selectedCategory のゲームは現在ありません',
                        style: AppTypography.body.copyWith(color: AppColors.textMuted),
                      ),
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl4)),
            ],
          ),
        );
      },
    );
  }

  bool _isExpiringSoon(data.GameOffer offer) {
    final rem = offer.timeRemaining;
    return rem != null && rem.inHours < 48;
  }

  void _showClaimDialog(BuildContext context, data.GameOffer offer) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.modalRadius)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSpacing.paddingComfortable),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(offer.title, style: AppTypography.h3),
            const SizedBox(height: AppSpacing.sm),
            if (offer.timeRemaining != null) ...[
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: AppColors.feedbackExpiring),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '残り ${_formatDuration(offer.timeRemaining!)}',
                    style: AppTypography.labelSmall
                        .copyWith(color: AppColors.feedbackExpiring),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            Text('このゲームを無料で入手しますか？', style: AppTypography.body),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('キャンセル'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${offer.title} を取得しました！')),
                      );
                    },
                    child: const Text('無料で入手'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inDays > 0) return '${d.inDays}日';
    if (d.inHours > 0) return '${d.inHours}時間${d.inMinutes % 60}分';
    return '${d.inMinutes}分';
  }
}

class _OfferTile extends StatelessWidget {
  final data.GameOffer offer;
  final VoidCallback? onClaim;

  const _OfferTile({required this.offer, this.onClaim});

  @override
  Widget build(BuildContext context) {
    final gameOffer = GameOffer(
      id: offer.id,
      title: offer.title,
      description: offer.description,
      thumbnailUrl: offer.thumbnailUrl,
      status: _mapStatus(offer.status),
      platform: _mapPlatform(offer.platform),
      genres: offer.genres,
      expiresAt: offer.offerEnd,
      originalPrice: offer.originalPrice,
      isNew: offer.isFree && offer.timeRemaining != null &&
          offer.timeRemaining!.inHours < 24,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      child: GameCard(
        offer: gameOffer,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GameDetailScreen(offer: offer),
          ),
        ),
        onClaim: onClaim,
      ),
    );
  }

  GameStatus _mapStatus(String s) {
    switch (s) {
      case 'free':
        return GameStatus.free;
      case 'upcoming':
        return GameStatus.expired;
      default:
        return GameStatus.expired;
    }
  }

  Platform _mapPlatform(String p) {
    switch (p) {
      case 'steam':
        return Platform.steam;
      case 'gog':
        return Platform.gog;
      default:
        return Platform.epic;
    }
  }
}

class _SearchView extends StatelessWidget {
  const _SearchView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'ゲームを検索...',
              prefixIcon: Icon(Icons.search),
            ),
            autofocus: false,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('ジャンルで絞り込む', style: AppTypography.h4),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: ['Action', 'RPG', 'Indie', 'Shooter', 'Strategy', 'Adventure', 'Horror']
                .map((g) => CategoryChip(label: g, onTap: () {}))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SettingsView extends StatefulWidget {
  const _SettingsView();

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  bool _pushNotif = true;
  bool _expiringNotif = true;
  bool _recoNotif = false;
  double _discountThreshold = 50;
  final Map<String, bool> _platforms = {
    'Epic Games': true,
    'Steam': true,
    'GOG': false,
    'EA App': false,
    'itch.io': false,
  };
  final Map<String, bool> _genres = {
    'Action': true,
    'RPG': true,
    'Indie': false,
    'Shooter': false,
    'Strategy': false,
    'Adventure': true,
    'Horror': false,
  };

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Notification section
        _SectionHeader(title: '通知設定', icon: Icons.notifications_outlined),
        const SizedBox(height: AppSpacing.sm),
        _SettingsTile(
          title: 'プッシュ通知',
          subtitle: '新しい無料ゲームが追加されたときに通知',
          trailing: Switch(
            value: _pushNotif,
            onChanged: (v) => setState(() => _pushNotif = v),
          ),
        ),
        _SettingsTile(
          title: '終了間近の通知',
          subtitle: '無料期間が24時間以内に終了するゲームを通知',
          trailing: Switch(
            value: _expiringNotif,
            onChanged: (v) => setState(() => _expiringNotif = v),
          ),
        ),
        _SettingsTile(
          title: 'AI おすすめ通知',
          subtitle: 'あなたの好みに合ったゲームをClaude AIが推薦',
          trailing: Switch(
            value: _recoNotif,
            onChanged: (v) => setState(() => _recoNotif = v),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),
        _SectionHeader(title: '割引通知', icon: Icons.local_offer_outlined),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.borderMuted),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('割引率しきい値', style: AppTypography.body),
                  const Spacer(),
                  Text(
                    '${_discountThreshold.round()}% 以上',
                    style: AppTypography.label
                        .copyWith(color: AppColors.interactivePrimary),
                  ),
                ],
              ),
              Slider(
                value: _discountThreshold,
                min: 10,
                max: 90,
                divisions: 8,
                activeColor: AppColors.interactivePrimary,
                onChanged: (v) => setState(() => _discountThreshold = v),
              ),
              Text(
                '${_discountThreshold.round()}% 以上の割引時に通知します',
                style: AppTypography.caption,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xl),
        _SectionHeader(title: 'プラットフォーム', icon: Icons.store_outlined),
        const SizedBox(height: AppSpacing.sm),
        ..._platforms.entries.map(
          (e) => _SettingsTile(
            title: e.key,
            trailing: Switch(
              value: e.value,
              onChanged: (v) => setState(() => _platforms[e.key] = v),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),
        _SectionHeader(title: '好みのジャンル', icon: Icons.gamepad_outlined),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.borderMuted),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '選択したジャンルのゲームを優先的に通知します',
                style: AppTypography.caption,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: _genres.entries
                    .map((e) => GestureDetector(
                          onTap: () =>
                              setState(() => _genres[e.key] = !e.value),
                          child: CategoryChip(
                            label: e.key,
                            selected: e.value,
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xl4),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.interactivePrimary),
        const SizedBox(width: AppSpacing.xs),
        Text(title, style: AppTypography.h4),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const _SettingsTile({required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: ListTile(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: trailing,
      ),
    );
  }
}
