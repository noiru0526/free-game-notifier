# Changelog

## [Unreleased]

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
