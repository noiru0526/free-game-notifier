import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_spacing.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';
import 'core/widgets/category_chip.dart';
import 'core/widgets/game_card.dart';
import 'core/widgets/notification_badge.dart';

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

// ===== Sample data =====
final _sampleOffers = [
  GameOffer(
    id: '1',
    title: 'Cyberpunk 2077',
    description: '大人気オープンワールドRPG。ナイトシティを舞台に繰り広げる壮大な物語。',
    status: GameStatus.expiringSoon,
    platform: Platform.epic,
    genres: ['RPG', 'Action', 'Indie'],
    expiresAt: DateTime.now().add(const Duration(hours: 23, minutes: 42)),
    originalPrice: 7480,
    isNew: true,
  ),
  GameOffer(
    id: '2',
    title: 'Hollow Knight',
    description: 'チャレンジングなアクション・アドベンチャーゲーム。地下帝国を探索しよう。',
    status: GameStatus.free,
    platform: Platform.gog,
    genres: ['Indie', 'Adventure', 'Action'],
    expiresAt: DateTime.now().add(const Duration(days: 5)),
    originalPrice: 1480,
  ),
  GameOffer(
    id: '3',
    title: 'Stardew Valley',
    description: '農場経営シミュレーション。癒しの農村生活を楽しもう。',
    status: GameStatus.claimed,
    platform: Platform.steam,
    genres: ['Indie', 'RPG', 'Strategy'],
    originalPrice: 980,
  ),
  GameOffer(
    id: '4',
    title: 'Death Stranding',
    description: '小島秀夫監督の最新作。荒廃したアメリカを繋ぎ直すアクションゲーム。',
    status: GameStatus.expired,
    platform: Platform.epic,
    genres: ['Action', 'Adventure'],
    originalPrice: 5980,
  ),
];

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

class _GameListView extends StatelessWidget {
  const _GameListView();

  @override
  Widget build(BuildContext context) {
    const categories = ['すべて', 'Action', 'RPG', 'Indie', 'Strategy', 'Adventure'];

    return CustomScrollView(
      slivers: [
        // Category filter chips
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: CategoryChipRow(
              categories: categories,
              selected: const ['すべて'],
            ),
          ),
        ),
        // Section header — Expiring soon
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
            child: Row(
              children: [
                PulsingDot(color: AppColors.feedbackExpiring),
                const SizedBox(width: AppSpacing.sm),
                Text('まもなく終了', style: AppTypography.h4.copyWith(color: AppColors.feedbackExpiring)),
              ],
            ),
          ),
        ),
        // Expiring offers
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) {
              final offer = _sampleOffers
                  .where((o) => o.status == GameStatus.expiringSoon)
                  .toList()[i];
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                child: GameCard(
                  offer: offer,
                  onTap: () {},
                  onClaim: () => _showClaimDialog(context, offer),
                ),
              );
            },
            childCount: _sampleOffers
                .where((o) => o.status == GameStatus.expiringSoon)
                .length,
          ),
        ),
        // Section header — Free now
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm),
            child: Text('無料で入手できるゲーム', style: AppTypography.h4),
          ),
        ),
        // All offers
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) {
              final offer = _sampleOffers
                  .where((o) => o.status != GameStatus.expiringSoon)
                  .toList()[i];
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                child: GameCard(
                  offer: offer,
                  onTap: () {},
                  onClaim: offer.status == GameStatus.free
                      ? () => _showClaimDialog(context, offer)
                      : null,
                ),
              );
            },
            childCount: _sampleOffers
                .where((o) => o.status != GameStatus.expiringSoon)
                .length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl4)),
      ],
    );
  }

  void _showClaimDialog(BuildContext context, GameOffer offer) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.modalRadius)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSpacing.paddingComfortable),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(offer.title, style: AppTypography.h3),
            const SizedBox(height: AppSpacing.sm),
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

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('通知設定', style: AppTypography.h4),
        const SizedBox(height: AppSpacing.md),
        _SettingsTile(
          title: 'プッシュ通知',
          subtitle: '新しい無料ゲームが追加されたときに通知',
          trailing: Switch(value: true, onChanged: (_) {}),
        ),
        _SettingsTile(
          title: '終了間近の通知',
          subtitle: '無料期間が24時間以内に終了するゲームを通知',
          trailing: Switch(value: true, onChanged: (_) {}),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('プラットフォーム', style: AppTypography.h4),
        const SizedBox(height: AppSpacing.md),
        ...['Epic Games', 'Steam', 'GOG', 'EA App', 'itch.io'].map(
          (p) => _SettingsTile(
            title: p,
            trailing: Switch(value: true, onChanged: (_) {}),
          ),
        ),
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
