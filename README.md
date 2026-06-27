# Graphite

Graphite は、ChatGPT や Codex などの AI ツールへ送るプロンプトを、安全に下書き・整形・コピーするための macOS ネイティブエディタです。

## 概要

Graphite は「送信する前に、落ち着いて書ける場所」を提供する小さなアプリです。

AI ツールの入力欄へ直接書くのではなく、Graphite 上でプロンプトを下書きし、必要な形式に整えてからクリップボードへコピーできます。Graphite はプロンプトを外部サービスへ送信せず、自動ペーストや自動送信も行いません。

## なぜ作ったか

日本語 IME では、変換を確定するために Enter キーを使います。一方で、多くの AI ツールでは Enter キーがメッセージ送信に割り当てられています。

そのため、日本語でプロンプトを書いていると、変換確定のつもりで Enter を押した瞬間に、未完成のプロンプトを送信してしまうことがあります。

Graphite ではこの問題を避けるため、Enter は常に改行として扱います。コピーは Cmd + Enter で明示的に行います。

## 特徴

- macOS ネイティブのプロンプト下書きエディタ
- 日本語 IME でも安心して書ける編集体験
- Enter は常に改行
- Cmd + Enter でコピー
- Cmd + Shift + Enter でコピーしてウィンドウを隠す
- Raw / Trimmed / Codex / GitHub Issue のコピー形式
- Always on Top の切り替え
- コピー形式と Always on Top 設定の永続化
- 外部依存なし
- ローカル完結
- 外部送信、自動ペースト、自動送信なし

## 使い方

1. Graphite を開きます。
2. エディタにプロンプトを書きます。
3. 必要に応じてコピー形式を選びます。
4. Cmd + Enter でクリップボードへコピーします。
5. ChatGPT、Codex、GitHub Issue など、使いたい場所へ自分で貼り付けます。

プロンプトを消す場合は Clear を使います。ウィンドウを前面に置きたい場合は Always on Top を有効にします。

## キーボードショートカット

| 操作 | 内容 |
| --- | --- |
| Enter | 改行 |
| Cmd + Enter | 現在のコピー形式でコピー |
| Cmd + Shift + Enter | コピーしてウィンドウを隠す |

## コピー形式

| モード | 内容 |
| --- | --- |
| Raw | 入力内容をそのままコピーします。 |
| Trimmed | 前後の空白と改行を取り除いてコピーします。 |
| Codex | Codex へ依頼しやすい見出し付きテンプレートに整形します。 |
| GitHub Issue | GitHub Issue 用の見出し付きテンプレートに整形します。 |

## プライバシーと安全性

Graphite はローカルで動作するエディタです。

- 入力したプロンプトを外部サービスへ送信しません。
- 他のアプリへ自動でペーストしません。
- AI ツールへ自動で送信しません。
- ネットワーク機能を持ちません。
- クリップボードへのコピーは、ユーザーの操作によってのみ行われます。

## 必要環境

- macOS 13 以降
- Swift Package Manager
- Xcode または Swift toolchain

Graphite は Apple 標準フレームワークのみで構成されており、外部ライブラリには依存していません。

## 開発

リポジトリを取得します。

```sh
git clone <repository-url>
cd graphite
```

ビルドします。

```sh
swift build
```

テストを実行します。

```sh
swift test
```

Xcode で開発する場合は、Swift Package としてこのディレクトリを開き、Graphite ターゲットを実行してください。

## テスト

Graphite では、アプリの中心となる挙動をテストで固定しています。

- CopyFormatter の出力互換性
- CopyMode の rawValue と表示名
- EditorState の文字数・行数カウント
- コピー完了フィードバックの表示タイミング
- SettingsStore の保存・復元・フォールバック

特にコピー形式の出力は、ユーザーのクリップボードに載る実質的な公開インターフェースとして扱っています。

## 設計方針

Graphite は、多機能なプロンプト管理ツールではありません。

設計方針はシンプルです。

- 書く
- 整える
- コピーする
- 自分で貼り付ける

履歴管理、外部サービス連携、自動送信、複雑なテンプレート編集などは、意図的に中心機能から外しています。Graphite は、AI へ送る前の一呼吸を作るための小さな道具です。

## コントリビューション

Issue や Pull Request は歓迎します。

ただし、Graphite はシンプルさを重視しています。変更を提案する場合は、次の方針に沿っているかを確認してください。

- Enter を送信動作にしない
- ローカル完結を保つ
- 外部送信や自動送信を追加しない
- 既存のコピー形式の互換性を壊さない
- 機能追加よりも、操作感と保守性を優先する

## ライセンス

現時点ではライセンスファイルは未設定です。OSS として公開する場合は、公開前に LICENSE ファイルを追加してください。

---

# Graphite English

Graphite is a native macOS prompt drafting editor for safely writing, formatting, and copying prompts before sending them to AI tools such as ChatGPT and Codex.

## Overview

Graphite provides a calm place to draft prompts before sending them anywhere.

Instead of typing directly into an AI tool's input field, you can write your prompt in Graphite, choose a copy format, and copy the result to the clipboard. Graphite does not send prompts to external services, and it does not auto-paste or auto-send content to other apps.

## Why Graphite Exists

Japanese IME users often press Enter to confirm text conversion. Many AI tools, however, use Enter to send a message.

This can cause unfinished prompts to be sent accidentally when the user only intended to confirm Japanese text conversion.

Graphite avoids that problem by treating Enter as a normal newline. Copying is always explicit with Cmd + Enter.

## Features

- Native macOS prompt drafting editor
- IME-safe editing experience
- Enter always inserts a newline
- Cmd + Enter copies the prompt
- Cmd + Shift + Enter copies the prompt and hides the window
- Copy modes for Raw, Trimmed, Codex, and GitHub Issue
- Always on Top toggle
- Persistent copy mode and Always on Top settings
- No external dependencies
- Local-only behavior
- No external sending, auto-paste, or auto-send

## Usage

1. Open Graphite.
2. Write your prompt in the editor.
3. Choose a copy format if needed.
4. Press Cmd + Enter to copy the prompt to the clipboard.
5. Paste it manually into ChatGPT, Codex, GitHub Issues, or wherever you want to use it.

Use Clear to remove the current prompt. Enable Always on Top if you want the window to stay above other windows.

## Keyboard Shortcuts

| Shortcut | Action |
| --- | --- |
| Enter | Insert newline |
| Cmd + Enter | Copy using the selected copy mode |
| Cmd + Shift + Enter | Copy and hide the window |

## Copy Modes

| Mode | Description |
| --- | --- |
| Raw | Copies the input exactly as written. |
| Trimmed | Removes leading and trailing whitespace and newlines before copying. |
| Codex | Wraps the prompt in a structured template for Codex-style implementation requests. |
| GitHub Issue | Wraps the prompt in a structured GitHub Issue template. |

## Privacy and Safety

Graphite is a local editor.

- It does not send your prompts to external services.
- It does not auto-paste into other apps.
- It does not auto-send messages to AI tools.
- It has no network features.
- Clipboard writes only happen through explicit user actions.

## Requirements

- macOS 13 or later
- Swift Package Manager
- Xcode or a Swift toolchain

Graphite uses only Apple standard frameworks and has no external library dependencies.

## Development

Clone the repository.

```sh
git clone <repository-url>
cd graphite
```

Build the app.

```sh
swift build
```

Run tests.

```sh
swift test
```

To work in Xcode, open this directory as a Swift Package and run the Graphite target.

## Tests

Graphite includes tests for the core behavior of the app.

- CopyFormatter output compatibility
- CopyMode raw values and titles
- EditorState character and line counts
- Copied feedback timing
- SettingsStore persistence, restoration, and fallback behavior

Copy format output is treated as a practical public interface because it is the final text placed on the user's clipboard.

## Design Principles

Graphite is not a full-featured prompt management system.

Its design is intentionally small.

- Write
- Format
- Copy
- Paste manually

History management, external service integrations, auto-send behavior, and complex template editing are intentionally outside the core scope. Graphite is a small tool for creating a safer pause before sending prompts to AI tools.

## Contributing

Issues and Pull Requests are welcome.

Before proposing a change, please make sure it fits the direction of the project.

- Do not make Enter send content.
- Keep the app local-first.
- Do not add external sending or auto-send behavior.
- Do not break compatibility of existing copy formats.
- Prefer editing comfort and maintainability over feature growth.

## License

No license file is currently configured. If this project is published as open source, add a LICENSE file before release.
