# FogNot

近畿大学 情報学部の学生向け課題管理iOSアプリです。

## 概要

課題を忘れない。チームで共有できる。カレンダーで一目でわかる。  
FogNot はそんなシンプルな課題管理を目指して作られました。

## 主な機能

- **共同管理** — 友達とリアルタイムで課題を共有・編集
- **個人管理** — 自分だけの課題を個別に管理
- **カレンダー表示** — 期限をカレンダーで視覚的に確認
- **リマインダー通知** — 期限前にプッシュ通知でお知らせ
- **ホームウィジェット** — ホーム画面からすぐに課題を確認
- **優先度設定** — 赤・黄色で重要な課題を目立たせる
- **科目タグ** — 知能 / サイバー / 実世界 / 共通 のコース別に分類

## 使用技術

- Swift / SwiftUI
- Firebase (Firestore, Authentication)
- Google Sign-In
- WidgetKit
- UserNotifications

## セットアップ

1. リポジトリをクローン
```bash
git clone https://github.com/manasuta/FogNot.git
```

2. Xcodeでプロジェクトを開く
```bash
open FogNot.xcodeproj
```

3. `GoogleService-Info.plist` を自分のFirebaseプロジェクトのものに差し替える  
   （セキュリティのためリポジトリには含まれていません）

4. ビルド & 実行

## 動作環境

- iOS 17.0+
- Xcode 15.0+

## 開発者

上野愛翔 ([@manasuta](https://github.com/manasuta))
