# Changelog

## [Unreleased]

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
