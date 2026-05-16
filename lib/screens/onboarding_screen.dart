import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});

  static const stores = ['Epic Games', 'Steam', 'GOG', 'EA App', 'itch.io'];
  static const genres = [
    'Action', 'RPG', 'Adventure', 'Indie', 'Strategy',
    'Shooter', 'Horror', 'Puzzle', 'Sports', 'Simulation',
  ];

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _selectedStores = <String>{};
  final _selectedGenres = <String>{};

  void _next() {
    if (_page < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    await prefs.setStringList('selected_stores', _selectedStores.toList());
    await prefs.setStringList('selected_genres', _selectedGenres.toList());
    widget.onComplete();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (p) => setState(() => _page = p),
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _WelcomePage(),
                  _StoreSelectPage(
                    selected: _selectedStores,
                    onToggle: (s) => setState(() {
                      if (_selectedStores.contains(s)) {
                        _selectedStores.remove(s);
                      } else {
                        _selectedStores.add(s);
                      }
                    }),
                  ),
                  _GenreSelectPage(
                    selected: _selectedGenres,
                    onToggle: (g) => setState(() {
                      if (_selectedGenres.contains(g)) {
                        _selectedGenres.remove(g);
                      } else {
                        _selectedGenres.add(g);
                      }
                    }),
                  ),
                ],
              ),
            ),
            _BottomNav(
              page: _page,
              totalPages: 3,
              canContinue: _page == 0 ||
                  (_page == 1 && _selectedStores.isNotEmpty) ||
                  (_page == 2 && _selectedGenres.isNotEmpty),
              onNext: _next,
              onSkip: _page > 0 ? _next : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.interactivePrimary, AppColors.interactiveAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(Icons.videogame_asset, size: 64, color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.xl2),
          Text(
            '無料ゲームを\n見逃さない',
            style: AppTypography.display.copyWith(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Epic Games、Steam など主要ストアの期間限定無料ゲームをリアルタイムで通知。Claude AI があなたの好みに合ったゲームを推薦します。',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StoreSelectPage extends StatelessWidget {
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  const _StoreSelectPage({required this.selected, required this.onToggle});

  static const _storeIcons = <String, IconData>{
    'Epic Games': Icons.videogame_asset,
    'Steam': Icons.computer,
    'GOG': Icons.album,
    'EA App': Icons.sports_esports,
    'itch.io': Icons.code,
  };

  static const _storeColors = <String, Color>{
    'Epic Games': Color(0xFF4E7CFF),
    'Steam': Color(0xFF1B2838),
    'GOG': Color(0xFF8B4513),
    'EA App': Color(0xFFFF6B00),
    'itch.io': Color(0xFFFA5C5C),
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Text('利用するストアを選択', style: AppTypography.h1.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.sm),
          Text('複数選択できます', style: AppTypography.body.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: ListView(
              children: OnboardingScreen.stores.map((store) {
                final isSelected = selected.contains(store);
                final color = _storeColors[store] ?? AppColors.interactivePrimary;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: GestureDetector(
                    onTap: () => onToggle(store),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withOpacity(0.15)
                            : AppColors.bgSurface,
                        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                        border: Border.all(
                          color: isSelected ? color : AppColors.borderMuted,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _storeIcons[store] ?? Icons.store,
                            color: isSelected ? color : AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            store,
                            style: AppTypography.body.copyWith(
                              color: isSelected ? color : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.w600 : null,
                            ),
                          ),
                          const Spacer(),
                          if (isSelected)
                            Icon(Icons.check_circle, color: color, size: 20),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenreSelectPage extends StatelessWidget {
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  const _GenreSelectPage({required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Text('好きなジャンルを選択', style: AppTypography.h1.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.sm),
          Text('Claude AIのおすすめに使用します', style: AppTypography.body.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: OnboardingScreen.genres.map((genre) {
              final isSelected = selected.contains(genre);
              return GestureDetector(
                onTap: () => onToggle(genre),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.interactivePrimary.withOpacity(0.2)
                        : AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.interactivePrimary
                          : AppColors.borderMuted,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    genre,
                    style: AppTypography.label.copyWith(
                      color: isSelected
                          ? AppColors.interactivePrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int page;
  final int totalPages;
  final bool canContinue;
  final VoidCallback onNext;
  final VoidCallback? onSkip;

  const _BottomNav({
    required this.page,
    required this.totalPages,
    required this.canContinue,
    required this.onNext,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalPages, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == page ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == page
                      ? AppColors.interactivePrimary
                      : AppColors.borderDefault,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              if (onSkip != null)
                TextButton(
                  onPressed: onSkip,
                  child: Text(
                    'スキップ',
                    style: AppTypography.body.copyWith(color: AppColors.textMuted),
                  ),
                ),
              const Spacer(),
              SizedBox(
                width: 160,
                height: 48,
                child: ElevatedButton(
                  onPressed: canContinue ? onNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.interactivePrimary,
                    disabledBackgroundColor: AppColors.borderDefault,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                    ),
                  ),
                  child: Text(
                    page == totalPages - 1 ? 'はじめる' : '次へ',
                    style: AppTypography.label,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
