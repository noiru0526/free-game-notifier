# Changelog

## [Unreleased]

## [0.4.0] - 2026-05-17

### Changed (UIリデザイン Round 2 — Netflix/Spotify スタイル)
- `lib/core/widgets/game_card.dart`
  - `ShelfGameCard` 追加 — Netflix風ホリゾンタルカルーセル用サムネイルカード（158×100px・16:9ライク）
    - 画像全面 + 下部グラデーション + プラットフォーム/FREEバッジ + カウントダウン
- `lib/main.dart`
  - `BottomNavigationBar` → Material 3 `NavigationBar` に置き換え（ピルインジケーター表示）
  - 「無料で入手できるゲーム」セクション: SliverGrid 2列 → ホリゾンタルカルーセル（ShelfGameCard使用）
  - 「近日無料予定」セクション: SliverGrid 2列 → ホリゾンタルカルーセル（ShelfGameCard使用）
  - 各セクションヘッダーに「すべて見る →」「カレンダーに追加 →」リンク追加
  - `_StatsBanner` 追加 — 「今すぐ N 本が無料！」を炎アイコン付きで表示（カテゴリフィルター連動）
- `lib/core/theme/app_theme.dart`
  - `navigationBarTheme` 追加 — ピルインジケーター・選択色・アイコンサイズをブランドカラーに統一

### UI改善の根拠（調査結果）
- Netflix: ホリゾンタルカルーセル棚がコンテンツ発見性を高める
- Spotify: 各セクションに「すべて見る」リンクでフル一覧への導線確保
- 2026 Material3トレンド: NavigationBar（ピルインジケーター）がBottomNavigationBarより視認性が高い

## [0.3.0] - 2026-05-17

### Changed (UIフルリデザイン Round 1)
- `lib/core/widgets/game_card.dart` — 縦型大判カードに全面リデザイン
  - 横並びレイアウト → 縦型（上部に画像140px・下部にコンテンツ）
  - `HeroGameCard` 追加 — まもなく終了ゲームをフルワイド大判カード表示
  - `_CountdownTimer` (StatefulWidget) — リアルタイムカウントダウン（毎秒更新）
  - `_AiRecommendationBadge` — AI推薦文をグラデーション枠で目立つ位置に表示
  - `_FreeBadge` — グロー効果付きFREE/割引バッジ
  - 画像エリアにグラデーションオーバーレイ追加
  - expiringSoon時のオレンジグロー効果を強化
- `lib/main.dart` — ゲームリストをグリッドレイアウトに変更
  - `expiringSoon[0]` → HeroGameCard（大判ヒーロー表示）
  - 残りのゲームすべて → 2列SliverGrid
  - `_OfferTile.toHeroGameOffer()` 追加・aiRecommendation転送
- `lib/core/widgets/category_chip.dart` — `small` オプション追加

## [0.2.7] - 2026-05-16

### Added
- `lib/main.dart` — クレーム済みゲーム永続化機能 (@noiru0526)
  - `_claimedIds: Set<String>` でアプリ内クレーム状態を管理
  - `_loadClaimedIds()` — SharedPreferences(`claimed_game_ids`)から起動時に復元
  - `_claimGame(id)` — クレーム時にIDを保存 → GameCardに`GameStatus.claimed`を反映
  - `_unclaimGame(id)` — 取得済みセクションの「クリア」ボタンで削除
  - 「取得済み」セクションをゲームリスト下部に自動表示（クレームしたゲームのみ）
  - SnackBarに「ストアを開く」アクションボタンを追加
  - `_mapStatus` を拡張 — 48時間以内のゲームに`GameStatus.expiringSoon`を自動適用
  - `_OfferTile` に `claimed` フラグ追加、`discountPercentage`/`discountedPrice`も転送

## [0.2.6] - 2026-05-16

### Added
- `lib/data/game_offer.dart` — 割引フィールド追加 (@noiru0526)
  - `discountPercentage`, `discountedPrice` フィールド
  - `isDiscounted` ゲッター
- `lib/core/widgets/game_card.dart` — 割引バッジ表示 (@noiru0526)
  - `discountPercentage`, `discountedPrice` フィールド追加
  - 割引率バッジ（オレンジ色、-XX%表示）をカード右上に表示

## [0.2.5] - 2026-05-16

### Changed
- `lib/data/game_offer_repository.dart` — MockRepositoryのサンプルデータを充実 (@noiru0526)
  - 5タイトルに増加（Death Stranding / Control / Cyberpunk / Alien: Isolation / TF2）
  - 実際のCDN URLからサムネイルを読み込み
  - metacritic・rating・aiRecommendationフィールドを追加
  - GOG・Steamのゲームを追加してマルチプラットフォームUIをテスト可能に

## [0.2.4] - 2026-05-16

### Changed
- `lib/screens/game_detail_screen.dart` — url_launcher でストアを実際に開く (@noiru0526)
  - `_openStore()` を `launchUrl()` に変更（外部ブラウザで開く）
  - 起動失敗時はSnackBarでエラー表示

## [0.2.3] - 2026-05-16

### Changed
- `lib/data/game_offer.dart` — マルチプラットフォーム対応 (@noiru0526)
  - `storeUrl` にSteam / GOG / EA App / itch.ioのURLパターンを追加
  - `platformDisplayName` ゲッターを追加
- `lib/screens/game_detail_screen.dart` — `_PlatformBadge` に EA App / itch.io バッジを追加
  - デフォルトは `platform.toUpperCase()` で表示

## [0.2.2] - 2026-05-16

### Added
- `functions/gog_games.js` — GOG.com / Steam 無料ゲーム取得 (@noiru0526)
  - `fetchGOGFreeGames()`: GOG公開APIから価格0のゲームを取得
  - `fetchSteamFreeGames()`: SteamSpy APIからF2Pゲーム一覧を取得
- `functions/index.js` — `fetchOtherStoreFreeGames` スケジュール関数追加
  - 毎日10:00 UTC に GOG/Steam の無料ゲームをFetch→Firestore保存→FCM通知

## [0.2.1] - 2026-05-16

### Added
- `lib/screens/onboarding_screen.dart` — オンボーディング画面 (@noiru0526)
  - 3ページ構成：ウェルカム / ストア選択 / ジャンル選択
  - アニメーション付きページインジケーター（選択中は横伸び）
  - ストア選択: Epic/Steam/GOG/EA App/itch.io（アイコン・色分け）
  - ジャンル選択: 10ジャンルをWrapレイアウトで表示
  - SharedPreferencesへの保存（onboarding_done / selected_stores / selected_genres）

### Changed
- `lib/main.dart` — HomeScreenにオンボーディングチェックを追加
  - initStateでonboarding_doneフラグを確認
  - 未完了の場合はOnboardingScreenを表示

## [0.2.0] - 2026-05-16

### Added
- `lib/services/notification_service.dart` — Flutter FCM受信サービス (@noiru0526)
  - `firebase_messaging` + `flutter_local_notifications` によるプッシュ受信
  - フォアグラウンド受信時にローカル通知を表示
  - `free_games` / `expiry_warnings` トピックへの自動購読
  - `updateTopicSubscription()` — 設定画面からトピック購読ON/OFF
  - Android通知チャンネル: `free_games`（重要度高）/ `expiry_warning`（重要度最大）
  - iOS APNs権限リクエスト

### Changed
- `pubspec.yaml` — Firebase依存パッケージ追加
  - `firebase_core: ^3.6.0`
  - `firebase_messaging: ^15.1.4`
  - `flutter_local_notifications: ^17.2.3`
- `lib/main.dart` — NotificationService初期化コード追加（Firebase設定後に有効化）
- `lib/main.dart` — 設定画面の通知スイッチをFCMトピック購読に接続

## [0.1.9] - 2026-05-16

### Added
- `functions/index.js` — FCM通知完全統合 (@noiru0526)
  - 新規無料ゲーム検出時に `sendFreeGameNotification()` を自動呼び出し
  - `fcmNotifiedAt` フィールドで重複通知を防止（既通知はスキップ）
  - `sendExpiryWarnings` — 毎日09:00 UTCに24時間以内に期限切れのゲームを検出してFCM送信
  - `expiryWarningSentAt` フィールドで重複警告を防止
  - `recommendations` Mapでバッチ内のAI推薦文を追跡→FCM本文に活用

## [0.1.8] - 2026-05-16

### Added
- `lib/screens/game_detail_screen.dart` — AIおすすめ・スコア表示 (@noiru0526)
  - `aiRecommendation` フィールドをグラジェントカードで表示（✨ Claude AIのおすすめ）
  - Metacriticスコア + ユーザー評価バッジ（_ScoreBadge）
  - Metacriticスコアに応じた色分け（75以上=緑/50以上=黄/未満=赤）

### Changed
- `lib/data/game_offer.dart` — フィールド追加 (@noiru0526)
  - `backgroundImage`, `aiRecommendation`, `metacritic`, `rating` を追加
  - `fromJson()` で全フィールドをマッピング

## [0.1.7] - 2026-05-16

### Added
- `functions/claude_recommend.js` — Claude API おすすめ理由生成 (@noiru0526)
  - `generateRecommendation()`: claude-haiku-4-5を使ってゲームの1〜2文推薦文を日本語で生成
  - ユーザーの好みジャンルに合致した場合その旨を含める
  - Metacriticスコアも考慮
  - `process.env.ANTHROPIC_API_KEY` でFirebase Secretから取得

### Changed
- `functions/index.js` — Claude APIをスケジュール関数に統合
  - 無料ゲームに対してRAWG + Claude両方を実行
  - `aiRecommendation` フィールドとしてFirestoreに保存
  - ANTHROPIC_API_KEY不在でgraceful degradation

## [0.1.6] - 2026-05-16

### Added
- `functions/rawg.js` — RAWG Video Games Database API ユーティリティ (@noiru0526)
  - `enrichGameWithRAWG()`: ゲームタイトルでRAWG検索→metacritic/rating/genres/tagsを取得
  - `getGameScreenshots()`: RAWG IDでスクリーンショット最大4枚を取得
  - `process.env.RAWG_API_KEY` でFirebase Secretから取得する設計

### Changed
- `functions/index.js` — スケジュール関数にRAWG連携を追加
  - 無料ゲームのみを対象にRAWGデータをFirestoreに追記（merge）
  - RAWG_API_KEYがない場合はスキップ（graceful degradation）

## [0.1.5] - 2026-05-16

### Changed
- `lib/main.dart` — `_SearchView` を StatefulWidget にリファクタリング (@noiru0526)
  - テキスト検索（タイトル・説明文をリアルタイムフィルタリング）
  - ジャンルチップによる複数選択フィルタリング
  - 検索結果に _OfferTile（GameCard）を表示
  - 結果0件時の空状態UI（search_offアイコン）
  - TextEditingControllerで入力クリアボタン付き

## [0.1.4] - 2026-05-16

### Changed
- `lib/main.dart` — `_SettingsView` を StatefulWidget にリファクタリング (@noiru0526)
  - 通知スイッチ（プッシュ/終了間近/AIおすすめ）が実際に動作するよう修正
  - 割引率しきい値スライダー（10〜90%）追加
  - プラットフォーム選択（Epic/Steam/GOG/EA/itch.io）が独立して制御可能に
  - 好みのジャンル選択（CategoryChipタップでトグル）
  - `_SectionHeader` コンポーネント追加（アイコン付きセクション見出し）

## [0.1.3] - 2026-05-16

### Added
- `lib/screens/game_detail_screen.dart` — ゲーム詳細画面 (@noiru0526)
  - SliverAppBar + サムネイル/プレースホルダー表示
  - `_CountdownCard` — リアルタイムカウントダウン（日/時間/分/秒をTimer.periodicで更新）
  - プラットフォームバッジ（Epic/Steam/GOG）
  - ジャンルチップ一覧
  - 「ストアで無料入手」/ 「準備中」CTAボタン
  - `_OfferTile.onTap` → GameDetailScreenへのNavigator.push 接続

## [0.1.2] - 2026-05-16

### Added
- `lib/data/game_offer.dart` — GameOfferデータモデル（Firestoreスキーマ準拠） (@noiru0526)
  - `fromJson()`, `isFree`, `isUpcoming`, `timeRemaining`, `storeUrl` ゲッター
- `lib/data/game_offer_repository.dart` — データ取得リポジトリ (@noiru0526)
  - `GameOfferRepository`: Cloud Functions HTTP `getFreeGames` / `fetchEpicNow` を呼び出す
  - `MockGameOfferRepository`: ローカル開発用のモックデータ（Death Stranding等3本）
- `pubspec.yaml` — 依存パッケージ追加: http / intl / shared_preferences / url_launcher
- `lib/main.dart` — `_GameListView` を StatefulWidget に刷新 (@noiru0526)
  - `FutureBuilder` + `MockGameOfferRepository` でデータを非同期取得・表示
  - `RefreshIndicator` でプルトゥリフレッシュ対応
  - カテゴリフィルター（すべて/Action/RPG等）が動作するよう修正
  - 「まもなく終了」「近日無料予定」セクションの動的分類
  - クレームダイアログに残り時間表示を追加

### Changed
- `lib/core/widgets/category_chip.dart` — `CategoryChipRow` に `onTap` シングルセレクト対応追加

## [0.1.1] - 2026-05-16

### Added
- `functions/index.js` — Epic Games API連携Cloud Functions実装 (@noiru0526)
  - `fetchEpicFreeGames` — 毎週木曜日9:00 UTC（18:00 JST）に自動実行されるスケジュール関数
  - `fetchEpicNow` — HTTP POSTで手動フェッチ（テスト用）
  - `fetchJSON` helper — Node.js標準httpsモジュールでEpic APIを取得
  - `extractEpicOffers` — Epicレスポンスから無料/upcoming/期限切れのオファーを抽出
  - `getFreeGames` — FirestoreからCORS対応で無料ゲームを返すHTTPエンドポイント
  - Firestore: `gameOffers` コレクションに `epic_{id}` ドキュメントで保存

## [0.1.0] - 2026-05-16

### Added
- Gaming/Steam-inspired デザインシステム全体構築 (@noiru0526)
  - `lib/core/theme/app_colors.dart` — Navy/Blue/Cyan カラーパレット (Steamダークテーマ)
  - `lib/core/theme/app_typography.dart` — タイポグラフィスケール (display/h1-h4/body/label/timer/price)
  - `lib/core/theme/app_spacing.dart` — 4pxベーススペーシングシステム
  - `lib/core/theme/app_theme.dart` — 完全な MaterialApp ThemeData (dark mode)
  - `lib/core/widgets/game_card.dart` — GameCard + GameOffer モデル
  - `lib/core/widgets/category_chip.dart` — CategoryChip + CategoryChipRow (フィルター可)
  - `lib/core/widgets/notification_badge.dart` — NotificationBadge + PulsingDot
- `lib/main.dart` 更新: サンプルデータ + ホーム/検索/設定画面でデザインシステムを適用

## [0.0.4] - 2026-03-30

### Added
- Firebase CLIをWSLにインストール (@noiru0526)
- Firebaseプロジェクト作成・Blazeプランへアップグレード (@noiru0526)
- Firestoreデータベース作成（asia-northeast1） (@noiru0526)
- Cloud Functions初期化（JavaScript） (@noiru0526)

## [0.0.3] - 2026-03-30

### Added
- `firebase.json` / `.firebaserc` — Firebaseプロジェクト設定ファイルを追加 (@noiru0526)
- `functions/index.js` — Cloud Functions初期ファイルを追加 (@noiru0526)
- `functions/package.json` — Cloud Functions依存関係を追加 (@noiru0526)

## [0.0.2] - 2026-03-30

### Added
- `README.md` — アプリ概要・主な機能・対応ストア・技術スタック・開発フェーズを記載 (@noiru0526)
- `CLAUDE.md` — Claude Code用セットアップ手順・プロジェクト概要・開発フェーズを記載 (@noiru0526)

### Changed
- `TODO.md` — フェーズ1〜5の構成に全面更新 (@noiru0526)
  - フェーズ1：バックエンド構築（Firebase・Epic Games API・RAWG API・Claude API・FCM・Firestore）
  - フェーズ2：Flutterアプリ基盤（オンボーディング・通知・ゲーム一覧・詳細画面）
  - フェーズ3：UI改善（カウントダウン・多言語対応・ストアリンク）
  - フェーズ4：ストア拡張（GOG.com・Steam）
  - フェーズ5：リリース準備（アイコン・Google Play・App Store申請）

## [0.0.1] - 2026-03-29

### Added
- Flutterプロジェクト初期作成 (@noiru0526)
- `TODO.md` — 開発タスク一覧の初版作成 (@noiru0526)
- GitHubリポジトリ作成・初回push (@noiru0526)
