import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'screens/onboarding_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase initialization is deferred until google-services.json is configured
  // await Firebase.initializeApp();
  // await NotificationService().initialize();
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
  bool _onboardingDone = true;

  static const _screens = [
    _GameListView(),
    _SearchView(),
    _SettingsView(),
  ];

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool('onboarding_done') ?? false;
    if (!done && mounted) {
      setState(() => _onboardingDone = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_onboardingDone) {
      return OnboardingScreen(onComplete: () {
        setState(() => _onboardingDone = true);
      });
    }

    const newCount = 0;

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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.videogame_asset_outlined),
            selectedIcon: Icon(Icons.videogame_asset),
            label: 'ゲーム',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: '検索',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
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
  Set<String> _claimedIds = {};

  static const _categories = [
    'すべて', 'Action', 'RPG', 'Indie', 'Strategy', 'Adventure', 'Shooter',
  ];

  @override
  void initState() {
    super.initState();
    _offersFuture = _repo.fetchFreeGames();
    _loadClaimedIds();
  }

  Future<void> _loadClaimedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('claimed_game_ids') ?? [];
    if (mounted) setState(() => _claimedIds = ids.toSet());
  }

  Future<void> _claimGame(String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('claimed_game_ids') ?? [];
    if (!ids.contains(gameId)) {
      ids.add(gameId);
      await prefs.setStringList('claimed_game_ids', ids);
    }
    if (mounted) setState(() => _claimedIds = ids.toSet());
  }

  Future<void> _unclaimGame(String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('claimed_game_ids') ?? [];
    ids.remove(gameId);
    await prefs.setStringList('claimed_game_ids', ids);
    if (mounted) setState(() => _claimedIds = ids.toSet());
  }

  void _refresh() {
    setState(() {
      _offersFuture = _repo.fetchFreeGames();
    });
    _loadClaimedIds();
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

        final freeOffers = filtered.where((o) => o.isFree).toList();
        final expiringSoon = freeOffers
            .where((o) => _isExpiringSoon(o) && !_claimedIds.contains(o.id))
            .toList();
        final freeNow = freeOffers
            .where((o) => !_isExpiringSoon(o) && !_claimedIds.contains(o.id))
            .toList();
        final upcoming = filtered.where((o) => o.isUpcoming).toList();
        final claimedGames = freeOffers
            .where((o) => _claimedIds.contains(o.id))
            .toList();

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
              if (freeNow.isNotEmpty || expiringSoon.isNotEmpty)
                SliverToBoxAdapter(
                  child: _StatsBanner(
                      freeCount: freeNow.length + expiringSoon.length),
                ),
              // ── Hero: まもなく終了（大判カード）──
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
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: HeroGameCard(
                      offer: _OfferTile(offer: expiringSoon[0]).toHeroGameOffer(),
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => GameDetailScreen(offer: expiringSoon[0]),
                      )),
                      onClaim: () => _showClaimDialog(context, expiringSoon[0]),
                    ),
                  ),
                ),
                if (expiringSoon.length > 1)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppSpacing.sm,
                        mainAxisSpacing: AppSpacing.sm,
                        childAspectRatio: 0.72,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => GameCard(
                          offer: _OfferTile(offer: expiringSoon[i + 1]).toHeroGameOffer(),
                          onTap: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => GameDetailScreen(offer: expiringSoon[i + 1]),
                          )),
                          onClaim: () => _showClaimDialog(context, expiringSoon[i + 1]),
                        ),
                        childCount: expiringSoon.length - 1,
                      ),
                    ),
                  ),
              ],
              if (freeNow.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm),
                    child: Row(
                      children: [
                        Text('無料で入手できるゲーム', style: AppTypography.h4),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'すべて見る →',
                            style: AppTypography.labelSmall
                                .copyWith(color: AppColors.interactiveAccent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: ShelfGameCard.kHeight + 28,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      itemCount: freeNow.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (_, i) => ShelfGameCard(
                        offer: _OfferTile(offer: freeNow[i]).toHeroGameOffer(),
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => GameDetailScreen(offer: freeNow[i]),
                        )),
                      ),
                    ),
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
                            style: AppTypography.h4
                                .copyWith(color: AppColors.textMuted)),
                        const Spacer(),
                        Text(
                          'カレンダーに追加 →',
                          style: AppTypography.labelSmall
                              .copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: ShelfGameCard.kHeight + 28,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      itemCount: upcoming.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (_, i) => ShelfGameCard(
                        offer: _OfferTile(offer: upcoming[i]).toHeroGameOffer(),
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => GameDetailScreen(offer: upcoming[i]),
                        )),
                      ),
                    ),
                  ),
                ),
              ],
              if (claimedGames.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 14, color: AppColors.textMuted),
                        const SizedBox(width: AppSpacing.xs),
                        Text('取得済み',
                            style: AppTypography.h4
                                .copyWith(color: AppColors.textMuted)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () async {
                            for (final g in claimedGames) {
                              await _unclaimGame(g.id);
                            }
                          },
                          child: Text('クリア',
                              style: AppTypography.labelSmall
                                  .copyWith(color: AppColors.textMuted)),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.sm,
                      mainAxisSpacing: AppSpacing.sm,
                      childAspectRatio: 0.72,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => GameCard(
                        offer: _OfferTile(offer: claimedGames[i], claimed: true).toHeroGameOffer(),
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => GameDetailScreen(offer: claimedGames[i]),
                        )),
                      ),
                      childCount: claimedGames.length,
                    ),
                  ),
                ),
              ],
              if (freeOffers.isEmpty && upcoming.isEmpty)
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
                      _claimGame(offer.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${offer.title} を取得しました！'),
                          action: SnackBarAction(
                            label: 'ストアを開く',
                            onPressed: () {},
                          ),
                        ),
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
  final bool claimed;

  const _OfferTile({required this.offer, this.onClaim, this.claimed = false});

  GameOffer _toGameOffer() => GameOffer(
    id: offer.id,
    title: offer.title,
    description: offer.description,
    thumbnailUrl: offer.thumbnailUrl,
    status: claimed
        ? GameStatus.claimed
        : (offer.isFree &&
                offer.timeRemaining != null &&
                offer.timeRemaining!.inHours < 48
            ? GameStatus.expiringSoon
            : _mapStatus(offer.status)),
    platform: _mapPlatform(offer.platform),
    genres: offer.genres,
    expiresAt: offer.offerEnd,
    originalPrice: offer.originalPrice,
    discountPercentage: offer.discountPercentage,
    discountedPrice: offer.discountedPrice,
    isNew: !claimed && offer.isFree && offer.timeRemaining != null &&
        offer.timeRemaining!.inHours < 24,
    aiRecommendation: offer.aiRecommendation,
  );

  @override
  Widget build(BuildContext context) {
    final gameOffer = _toGameOffer();
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

  GameOffer toHeroGameOffer() => _toGameOffer();

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

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _controller = TextEditingController();
  final _repo = MockGameOfferRepository();
  List<data.GameOffer> _allOffers = [];
  List<data.GameOffer> _results = [];
  final Set<String> _selectedGenres = {};
  bool _loaded = false;

  static const _genres = [
    'Action', 'RPG', 'Indie', 'Shooter', 'Strategy', 'Adventure', 'Horror',
  ];

  @override
  void initState() {
    super.initState();
    _repo.fetchFreeGames().then((offers) {
      if (mounted) setState(() { _allOffers = offers; _loaded = true; _filter(); });
    });
    _controller.addListener(_filter);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _filter() {
    final q = _controller.text.toLowerCase();
    setState(() {
      _results = _allOffers.where((o) {
        final matchQ = q.isEmpty ||
            o.title.toLowerCase().contains(q) ||
            o.description.toLowerCase().contains(q);
        final matchG = _selectedGenres.isEmpty ||
            o.genres.any((g) => _selectedGenres
                .any((sg) => g.toLowerCase().contains(sg.toLowerCase())));
        return matchQ && matchG;
      }).toList();
    });
  }

  void _toggleGenre(String genre) {
    setState(() {
      if (_selectedGenres.contains(genre)) _selectedGenres.remove(genre);
      else _selectedGenres.add(genre);
    });
    _filter();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'ゲームを検索...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        _filter();
                      },
                    )
                  : null,
            ),
            autofocus: false,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: _genres.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
            itemBuilder: (_, i) => CategoryChip(
              label: _genres[i],
              selected: _selectedGenres.contains(_genres[i]),
              onTap: () => _toggleGenre(_genres[i]),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (!_loaded)
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.interactivePrimary),
            ),
          )
        else if (_results.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '「${_controller.text}」の検索結果はありません',
                    style:
                        AppTypography.body.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
              itemCount: _results.length,
              itemBuilder: (ctx, i) =>
                  _OfferTile(offer: _results[i]),
            ),
          ),
      ],
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
            onChanged: (v) {
              setState(() => _pushNotif = v);
              NotificationService().updateTopicSubscription('free_games', v);
            },
          ),
        ),
        _SettingsTile(
          title: '終了間近の通知',
          subtitle: '無料期間が24時間以内に終了するゲームを通知',
          trailing: Switch(
            value: _expiringNotif,
            onChanged: (v) {
              setState(() => _expiringNotif = v);
              NotificationService().updateTopicSubscription('expiry_warnings', v);
            },
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

class _StatsBanner extends StatelessWidget {
  final int freeCount;
  const _StatsBanner({required this.freeCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.xs, AppSpacing.lg, 0),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.interactivePrimary.withOpacity(0.18),
            AppColors.interactiveAccent.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: AppColors.interactivePrimary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department,
              color: AppColors.interactivePrimary, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '今すぐ $freeCount 本が無料！',
            style: AppTypography.body.copyWith(
              color: AppColors.interactivePrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios,
              color: AppColors.textMuted, size: 12),
        ],
      ),
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
