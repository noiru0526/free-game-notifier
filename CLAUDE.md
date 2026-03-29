# free-game-notifier — 開発共有ドキュメント

> **このファイルは Claude Code が自動で読み込みます。**
> 作業開始前に必ずこのファイルを確認し、作業後は変更点・決定事項を追記してください。

---

## 起動時セットアップ

**必ず確認すること：** `/app/free-game-notifier` が存在しない場合は以下を実行する。

```bash
git clone https://noiru0526:TOKEN@github.com/noiru0526/free-game-notifier.git /app/free-game-notifier
```

※ TOKEN は GitHub Personal Access Token（`ghp_...`）に置き換えること。

---

## プロジェクト概要

期間限定で無料・割引になったゲームを通知するFlutterアプリ。
ユーザーのジャンル嗜好をもとにClaude APIがおすすめ理由を生成するレコメンド機能付き。

### 対応プラットフォーム
- iOS / Android

### 技術スタック
- フレームワーク：Flutter (Dart)
- 状態管理：Riverpod
- 通知：FCM（Firebase Cloud Messaging）
- バックエンド：Firebase Cloud Functions + Firestore
- AI：Claude API（おすすめ理由の生成）
- ゲーム情報：Epic Games API + RAWG API

### リポジトリ
- GitHub：https://github.com/noiru0526/free-game-notifier
- 作業ディレクトリ：/app/free-game-notifier
- ブランチ：master

---

## 開発フェーズ

### フェーズ1：バックエンド構築
- [ ] Firebaseプロジェクト作成
- [ ] Cloud Functions で Epic Games API を定期チェック（毎週木曜）
- [ ] Epic Games の割引ゲーム情報も取得
- [ ] RAWG APIでゲーム詳細・レビュー情報を取得
- [ ] Claude APIでおすすめ理由を生成
- [ ] FCM で無料・割引通知を送信
- [ ] Firestore に無料・割引ゲーム情報・おすすめ理由を保存

### フェーズ2：Flutterアプリ基盤
- [ ] オンボーディング画面（ストア選択・ジャンル選択）
- [ ] FCM（Firebase Messaging）の組み込み
- [ ] Firestoreからゲーム情報を取得・表示
- [ ] 期間限定無料ゲーム一覧画面
- [ ] 割引ゲーム一覧画面
- [ ] ゲーム詳細画面（元の価格・無料期間または割引率・ストアリンク・おすすめ理由）
- [ ] 割引通知のON/OFF設定・割引率スライダー
- [ ] レコメンド通知のON/OFF設定

### フェーズ3：UI改善
- [ ] 「あと○日」カウントダウン表示
- [ ] 日本語 / 英語 切り替え
- [ ] ストアへのリンク（各ストアページを開く）

### フェーズ4：ストア拡張
- [ ] GOG.com 対応（無料・割引）
- [ ] Steam 対応（無料・割引）
- [ ] ストア別フィルター設定

### フェーズ5：リリース準備
- [ ] アプリアイコン・名前の設定
- [ ] Google Play 申請
- [ ] App Store 申請

---

## 変更ログ

### 2026-03-29
- プロジェクト設計確定
- SSH認証 → HTTPS+トークン方式に変更、自動push対応
- CLAUDE.md作成
