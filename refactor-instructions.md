# Graphite リファクタリング指示書 (refactor-instructions.md)

作成日: 2026-06-12(同日、プロダクトオーナーの回答を反映し全判断を確定済み)
対象リポジトリ: `~/project/products/graphite` (branch: main)
作成方法: コードベース全ファイルの読解・未コミット差分の精査・`swift build` の実行確認に基づく。

---

## Objective

macOS用プロンプト下書きエディタ「Graphite」の中核挙動を壊さずに、

1. テスト不在という最大の負債を解消し(安全網の構築)、
2. 死コード・到達不能コード・重複を削除して保守対象を最小化し、
3. プロダクト方針に沿わない機能(行番号ルーラー)を撤去し、
4. コピー成功フィードバックの復活と設定の永続化という、確定済みの小さな改善を実装する。

### プロダクト方針(全判断の基準)

> **シンプルで機能は最低限。キーボードショートカットで操作でき、指に吸い付くような操作感。AIへのプロンプトを書くためのアプリであり、シンプルさが売り。**

迷ったら機能を足すのではなく削る。抽象化を足すのではなく減らす。見た目の綺麗さではなく「変更しやすさ」と「コピー出力の互換性」を守る。

---
s
## Project Understanding

### プロダクト概要

Graphiteは、ChatGPT/Codex等のAIツールへ送る前にプロンプトを安全に下書き・整形・コピーするためのmacOSネイティブアプリ。日本語IMEユーザーがEnterで変換確定した瞬間に誤送信される問題を避けるため、**Enterは常に改行、コピーは明示的にCmd+Enter** という設計思想を持つ(README.md参照)。ローカル完結であり、外部サービスへの送信・自動ペースト・自動送信は行わない。

### 構成

SwiftPMの実行可能パッケージ(`Package.swift`、swift-tools-version 5.9、macOS 13+、外部依存ゼロ、テストターゲットなし)。ソースは13ファイル・計約700行と小規模。

| パス | 責務 |
|---|---|
| `Graphite/GraphiteApp.swift` | `@main`。3つのObservableObjectを生成しEnvironmentObjectで注入 |
| `Graphite/AppDelegate.swift` | NSWindowを`WindowState`にアタッチ(起動時 + didBecomeMain監視) |
| `Graphite/Features/Editor/PromptEditorView.swift` | メイン画面。header/editor/footerのUI + コピー実行ロジック |
| `Graphite/Features/Editor/PromptTextView.swift` | NSTextViewラッパー(IME安全設定、undo、行番号ルーラー ※撤去対象) |
| `Graphite/Features/Editor/EditorState.swift` | テキスト本体、文字数/行数、コピー完了メッセージ |
| `Graphite/Features/Clipboard/CopyMode.swift` | raw / trimmed / codex / githubIssue の列挙 |
| `Graphite/Features/Clipboard/CopyFormatter.swift` | モード別のコピー文字列整形(日本語テンプレート含む) |
| `Graphite/Features/Clipboard/ClipboardService.swift` | NSPasteboardへの書き込み |
| `Graphite/Features/Window/WindowState.swift` | Always on Top(window.level)、ウィンドウ非表示 |
| `Graphite/Features/Settings/AppSettings.swift` / `SettingsStore.swift` | コピーモードとAlways on Topの設定(現状: 永続化なし → 本書で永続化を実装する) |
| `Graphite/Shared/Components/ToolbarView.swift` | 旧UI部品(未参照 → **削除確定**) |
| `Graphite/Shared/Components/StatusBarView.swift` | 旧UI部品(未参照 → **削除確定**) |
| `Graphite/Shared/Utilities/KeyboardShortcutHint.swift` | 旧UI用文言定数(未参照 → **削除確定**) |

### データフロー

キー入力 → `PromptTextView.Coordinator.textDidChange` → `EditorState.text` → 文字数/行数表示。
Cmd+Enter → `PromptEditorView.copy(andHide:)` → `CopyFormatter.format` → `ClipboardService.copy` → (`andHide`時) `WindowState.hideWindow()`。

### 外部依存

なし。Apple標準フレームワーク(SwiftUI / AppKit / Foundation)のみ。ネットワーク・DB・認証・課金・通知は一切存在しない。今後も追加しない。

### ⚠️ 重要: 作業開始時点のリポジトリ状態

このリポジトリには **コミットされていないUI再設計差分** が存在する(7ファイル、+257/-37。header/footer型の新UI、行番号ルーラー追加、`#if canImport(AppKit)`ガード追加、`CopyMode.githubIssue`のtitle変更)。

**この再設計は採用が確定している。** Phase 0で、この未コミット差分を自分の変更と混ぜないために、**まずワーキングツリーの現状をそのままベースラインコミットとして確定**してから作業を始めること(例: `git add -A && git commit -m "Adopt redesigned editor UI"`)。revertしてはならない。

---

## Behaviors To Preserve(絶対に壊してはいけない挙動)

1. **Enterは改行であり、いかなる場合も「送信」動作にしない。** これはこのプロダクトの存在理由(README "Why")。
2. **IME安全性**: `NSTextView`の自動補正系設定(`isAutomaticQuoteSubstitutionEnabled` 等4項目すべてfalse)、`isRichText = false`、`allowsUndo = true`(`PromptTextView.swift:21-26`)。
3. **Cmd+Enter = コピー、Cmd+Shift+Enter = コピーしてウィンドウ非表示**。
4. **`CopyFormatter.format` の出力文字列をバイト単位で完全互換に保つ。** 特に codex / githubIssue モードの日本語テンプレート(見出し、空行、ハイフンの位置まで)。ユーザーのクリップボードに載る最終成果物であり、これが事実上の公開API。
5. codexモードで空文字(trim後空)のとき空文字を返す挙動(`CopyFormatter.swift:12`)。rawは無加工、trimmedは前後の空白・改行のみ除去。
6. Always on Topトグル → `window.level = .floating / .normal`。
7. Clearボタンは空でないときのみ有効で、確認アラートを経てから消去する。
8. 文字数・行数カウント仕様: 空文字のとき1行(`EditorState.swift:9-12`)。
9. ローカル完結: ネットワーク送信・自動ペースト・他アプリへの自動送信を導入しない。
10. 外部依存ゼロのまま保つ(リファクタリング目的でのライブラリ追加禁止)。

### 本書で意図的に変更する挙動(上記の例外として確定済み)

- **行番号ルーラーの撤去**(プロダクト方針: プロンプトはコードではない。フッターの行数表示で十分)。
- **コピー時の「Copied」フィードバックを新UIのfooterに復活**(現状は状態が設定されるだけで表示先がない。Copy & Hideでウィンドウが消える操作では成功確認が特に重要)。
- **設定(copyMode / alwaysOnTop)のUserDefaults永続化**(毎回リセットは摩擦であり、操作感を損なう)。
- 非macOS向け`#else`フォールバック分岐の削除。
- 旧UI部品3ファイルの削除。

---

## Non-Negotiables(作業上の絶対制約)

- **最初に `git status` を確認**し、未コミット差分をベースラインコミットとして確定してから自分の作業を始める(自分の変更と混ぜない)。
- 編集前に **baseline検証結果(`swift build` の成否)を記録**する。
- 変更は小さく、1フェーズ=1コミット相当の戻しやすい単位にする。
- 無関係な整形・「ついでの」リファクタリング・import順の並べ替え等をしない。
- 本書で明示的に確定された変更以外の挙動変更をしない。
- 正しさが不明な場合は実装を止めて質問する。
- 各フェーズ完了ごとに検証コマンドを実行する。
- 証拠なく大きな削除・全面書き換えをしない。ファイル削除は本書で明示されたもの(D1の3ファイル)のみ。
- 新しい抽象レイヤー・プロトコル・DIの導入は禁止(このサイズのアプリには過剰。シンプルさが売り)。
- 最後に、実行したコマンドと結果を報告する。

---

## Stop And Ask Conditions(以下に該当したら実装を止めて質問する)

1. `CopyFormatter`のテンプレート文字列に少しでも差異を入れたくなった場合。
2. テストを書いた結果、現行実装の挙動が直感に反すると判明した場合(例: lineCountの境界値)→ 実装をテストに合わせるのではなく、現行挙動をテストに固定して報告する。
3. 本書に列挙されていない機能・ファイルの削除を行いたくなった場合。
4. 設定永続化の実装中に、`CopyMode.rawValue`の変更が必要に見えた場合(保存データ互換性に直結するため変更禁止。必要ならマッピング層で吸収せず質問する)。
5. Behaviors To Preserveと本書の指示が矛盾していると気づいた場合。
6. `swift test`のセットアップ(`@testable import Graphite`)が実行可能ターゲットの制約で失敗し、D10の最小分離でも解決しない場合。

---

## Baseline Commands

```sh
git status                 # 未コミット差分の確認(最初に必ず)→ ベースラインコミットを作成
swift build                # 現状: Build complete を確認済み(2026-06-12)
swift test                 # 現状: テストターゲットが存在しないため未整備。Phase 1で追加する
```

CI・lint・format設定は存在しない。検証はビルドとテスト、およびXcodeでの手動起動確認(`README.md` "Development")のみ。

---

## Debt Map(全項目、判断確定済み)

### D1. 死コード: 旧UI部品3ファイル 【実装する: 削除】

- **根拠**: `Graphite/Shared/Components/ToolbarView.swift`、`StatusBarView.swift`、`Shared/Utilities/KeyboardShortcutHint.swift`。新UI採用確定により、ワーキングツリーではどこからも参照されていない(grep確認済み)。
- **対応**: 3ファイルを削除。`Shared/Components` / `Shared/Utilities` ディレクトリが空になったらディレクトリも削除。
- **検証**: `swift build` 成功 + 全機能の手動確認。

### D2. 「Copied」フィードバックの行き場喪失 【実装する: 復活+堅牢化】

- **根拠**: `PromptEditorView.swift:168-174` で `editorState.copiedMessage` を設定・1.5秒後にクリアしているが、新UIに表示するビューがない(旧`StatusBarView`が表示していた)。さらにクリア処理は「1.5秒後にメッセージがまだ"Copied"なら消す」という文字列比較で、連続コピー時に2回目の表示が早く消える。
- **対応**:
  1. footerに最小限の「Copied」表示を追加する(例: 文字数表示の近く、または⌘↩ボタン付近に短く出るテキスト。既存のトーンに合わせ控えめに。レイアウトが跳ねないようにすること — 操作感を最優先)。
  2. クリア処理を文字列比較ではなく世代カウンタまたはキャンセル可能な`Task`に置き換え、連続コピーでも「最後のコピーから1.5秒」表示されるようにする。
  3. このロジックは`EditorState`側に持たせ、単体テスト可能にする(D6と同時に行ってよい)。
- **検証**: Cmd+Enter連打で表示が途切れず、最後の操作から1.5秒で消えることを手動確認。タイマーロジックの単体テスト。

### D3. テスト不在(最大の負債)【実装する: 最優先】

- **根拠**: `Package.swift` にテストターゲットなし。テストファイルゼロ。守るべき中核仕様(CopyFormatterのテンプレート出力、lineCountの境界値)がコードを読む以外に検証できない。
- **対応**: `Package.swift`に`.testTarget(name: "GraphiteTests", dependencies: ["Graphite"], path: "GraphiteTests")`を追加し、以下のゴールデンテストを書く:
  - `CopyFormatter.format`: 4モードすべての出力を**期待文字列リテラルとの完全一致**で検証。空文字・空白のみ・前後空白付き・複数行入力の各ケース。codexの空入力→空文字も。期待値は**現行実装の出力をそのまま**リテラル化する(理想の出力を書かない)。
  - `EditorState`: `lineCount`(空→1、"a"→1、"a\nb"→2、末尾改行"a\n"→2)、`characterCount`(絵文字を含む場合の`String.count`挙動を現行どおり固定)。
  - `CopyMode`: `rawValue`と`title`の固定(D7の永続化導入後は`rawValue`が保存データ互換性のアンカーになるため必須)。
- **注意**: `@testable import Graphite`(実行可能ターゲット)がリンクエラーになる場合のみ、テスト対象の純粋ロジックファイルを最小限ライブラリターゲットに分離してよい(D10)。まずはそのまま試す。
- **検証**: `swift test` 全件パス。

### D4. コピーモード選択メニューの重複 【実装する】

- **根拠**: `PromptEditorView.swift:66-78`(contextMenu)と `115-126`(footerのMenu)に、`ForEach(CopyMode.allCases)` + チェックマーク付きボタンという同一構造が二重に存在。
- **対応**: `private var copyModeMenuItems: some View` 等に抽出し、両方から使う。
- **検証**: `swift build` + 手動でcontextMenu・footerメニュー両方の選択とチェック表示確認。

### D5. 行番号ルーラー 【実装する: 機能ごと撤去】

- **根拠**: `PromptTextView.swift:78-122` の `LineNumberRulerView` と、その接続(`:38-40`)、`Coordinator.textDidChange`内の再描画指示(`:61-63`)。UTF-16インデックスとCharacterインデックスの混在(`:104-107`)により絵文字・サロゲートペア混在テキストで行番号ずれ・クラッシュの可能性があり、描画毎にO(n)の改行カウントも走る。さらに折り返し行で番号が増える採番の曖昧さもある。
- **判断の理由**: プロダクト方針により**バグ修正ではなく機能撤去**を選択。プロンプトはコードではなく、行番号ガターは視覚ノイズ。行数はfooterで既に表示している。撤去すればバグ・パフォーマンス問題・採番仕様の曖昧さがすべて消える。
- **対応**: `LineNumberRulerView`クラス、`hasVerticalRuler`/`rulersVisible`/`verticalRulerView`の設定3行、`textDidChange`内のruler再描画ブロックを削除。**それ以外のNSTextView設定(IME安全設定・フォント・色・inset等)には触れない。**
- **検証**: `swift build` + 手動でエディタ表示(ガターが消え、テキストの編集・スクロール・undo・IME入力が正常)。

### D6. `copy(andHide:)`の責務混在 【実装する(小さく)】

- **根拠**: `PromptEditorView.swift:165-179`。整形・クリップボード・フィードバック状態・タイマー・ウィンドウ操作がビューのメソッドに同居。`ClipboardService`もビューが直接保持(`:8`)。コピー動作(このアプリの中核)が単体テスト不能。
- **対応**: 「textとmodeを受けて整形しクリップボードに置き、フィードバック状態を更新する」処理を`EditorState`へ移し(D2のタイマー堅牢化と同時に実施)、ビューは呼び出しと`andHide`時の`windowState.hideWindow()`だけにする。**プロトコル化・モック注入はしない**(`ClipboardService`は具象のまま渡すか内部生成でよい)。
- **検証**: `swift build` + `swift test` + 手動でCmd+Enter / Cmd+Shift+Enterの確認。

### D7. 設定の永続化なし 【実装する】

- **根拠**: `SettingsStore.swift`は`@Published var settings = AppSettings()`のみ。copyModeとalwaysOnTopは起動毎にリセットされる。毎回設定し直す摩擦は「指に吸い付く操作感」に反する。
- **対応**: `SettingsStore`にUserDefaults永続化を実装する。最小実装でよい:
  - キーは `"copyMode"`(`CopyMode.rawValue`の文字列)と `"alwaysOnTop"`(Bool)程度の素直なもの。
  - 読み込み時、未知のrawValueや未保存の場合は現行デフォルト(`.raw` / `false`)にフォールバック。
  - `settings`の`didSet`または`@Published`のsink等で書き込み。Codable+JSONなどの大掛かりな仕組みは不要。
  - 起動時に`alwaysOnTop`が復元された場合、既存の`GraphiteApp.onAppear`の`applyAlwaysOnTop`呼び出しで窓レベルに反映されることを確認する。
- **制約**: `CopyMode`の`rawValue`を変更しない(保存データ互換のアンカー。D3でテスト固定済みであること)。
- **検証**: 単体テスト(専用のUserDefaults suiteを使い、保存→復元→未知値フォールバックを検証)+ 手動でアプリ再起動後にモードとAlways on Topが保持されることを確認。

### D8. ライトモード前提のハードコード色 【提案のみ・実装しない】

- **根拠**: `PromptEditorView.swift:82`の`Color.white`、`:151`の`Color.white.opacity(0.92)`、`PromptTextView.swift:28`の`NSColor(calibratedWhite: 0.15)`等。ダークモードで白背景のまま。
- **判断の理由**: 見た目の変更でありデザイン判断を伴う。あえてライト固定の紙のような見た目が意図の可能性もある。最終報告で対応案(セマンティックカラー化 or `.preferredColorScheme(.light)`での明示的ライト固定)を提示するに留める。

### D9. macOS専用パッケージ内の非AppKitフォールバック 【実装する: 削除】

- **根拠**: `Package.swift`は`platforms: [.macOS(.v13)]`のみなのに、`PromptTextView.swift:67-76`、`WindowState.swift:21-27`、`ClipboardService.swift:12-14`、`AppDelegate.swift`、`GraphiteApp.swift`に`#if canImport(AppKit)` / `#else`分岐が存在。macOSビルドでは`#else`側は到達不能であり、保守ノイズ。iOS展開の予定はない(プロダクトオーナー確認済み: macOS専用・シンプル路線)。
- **対応**: `#else`分岐と、不要になった`#if canImport(AppKit)`ガードを削除し、`import AppKit`を無条件にする。`import Foundation`が不要になった箇所も整理してよい(この削除作業で触るファイルに限る)。
- **検証**: `swift build` 成功 + 全機能の手動確認。

### D10. テスト可能性の構造的限界 【条件付き・最小限のみ】

- **根拠**: 全ロジックが実行可能ターゲット1つに同居。環境によって`@testable import`が実行可能ターゲットで問題を起こす。
- **対応**: D3で`@testable import Graphite`が**実際に失敗した場合に限り**、テスト対象の純粋ロジック(`CopyMode`、`CopyFormatter`、`EditorState`、`AppSettings`、`SettingsStore`)を`GraphiteCore`ライブラリターゲットへ最小限分離する。失敗しないなら分離しない(ターゲットを増やすこと自体が複雑さ)。

### D11. `AppDelegate`のウィンドウ捕捉の脆さ 【提案のみ・実装しない】

- **根拠**: `AppDelegate.swift:9`の`NSApplication.shared.windows.first`依存、`didBecomeMain`監視のobserver解除なし、`bind`との実行順序依存。
- **判断の理由**: 単一ウィンドウの現状で実害がなく、修正の検証が手動のみで割に合わない。最終報告に改善案として記載するに留める。

### D12. マジックナンバー 【触る範囲でのみ実装可】

- **根拠**: `PromptEditorView.swift:45`の`20 / 2`、`:61`の`30 / 2`、`PromptTextView.swift:27`の`26 / 2`という不可解な除算によるフォントサイズ指定。
- **対応**: 他の理由でその行を触る場合に限り、計算結果の値(10、15、13)に整理してよい。専用コミットでの一斉置換はしない。

---

## Implementation Phases

> 各フェーズは独立したコミットにする。フェーズ内で問題が出たらそのフェーズだけ巻き戻す。

### Phase 0: ベースライン確定(必須・最初)
1. `git status` で未コミット差分を確認・記録。
2. ワーキングツリーの現状(UI再設計)をそのままベースラインコミットとして確定(例: "Adopt redesigned editor UI")。自分の変更は一切含めない。
3. `swift build` の成否と `swift --version` を記録。

### Phase 1: 安全網の構築(D3)
1. `Package.swift` に `GraphiteTests` テストターゲットを追加。
2. `CopyFormatter` 4モード×境界ケースのゴールデンテスト、`EditorState` のカウントテスト、`CopyMode` の `rawValue`/`title` 固定テスト。
3. `swift test` 全件パス。`@testable import` が失敗した場合のみD10の最小分離を行い、報告に明記。

### Phase 2: 死コード・到達不能コードの削除(D1, D9)
1. 旧UI部品3ファイルを削除(D1)。空になったディレクトリも削除。
2. `#else`分岐と不要な`#if canImport(AppKit)`ガードを削除(D9)。
3. `swift build` + `swift test` + 全機能の手動確認。

### Phase 3: 行番号ルーラーの撤去(D5)
1. `LineNumberRulerView`と接続コードを削除。NSTextViewのIME安全設定・見た目設定には触れない。
2. `swift build` + 手動確認(編集・スクロール・undo・IME入力)。

### Phase 4: 重複排除(D4)
1. コピーモードメニューを1つのサブビュー/computed propertyに統合。
2. `swift build` + 手動でcontextMenu・footerメニュー両方を確認。

### Phase 5: コピー処理の責務分離と「Copied」復活(D2, D6)
1. コピー処理(整形→クリップボード→フィードバック状態更新)を`EditorState`へ移動。タイマーを世代カウンタ/キャンセル可能`Task`に堅牢化。
2. footerに最小限の「Copied」表示を追加(レイアウトが跳ねないこと)。
3. 単体テスト追加 + `swift build` + `swift test` + 手動でコピー2種・連打時の表示確認。

### Phase 6: 設定の永続化(D7)
1. `SettingsStore`にUserDefaults読み書きを実装(未知値はデフォルトへフォールバック)。
2. 専用suiteでの単体テスト + 手動でアプリ再起動後の復元確認。
3. `CopyMode.rawValue`に変更がないことをPhase 1のテストで担保。

### Phase 7: 最終報告と残課題の提案
- D8(ダークモード)、D11(AppDelegate)について、要否・案・リスクを提案としてまとめる。**実装しない。**

---

## Verification Requirements

- 各フェーズ終了時に必ず: `swift build` と(Phase 1以降)`swift test`。
- UI・挙動に触れるフェーズでは手動確認を行い、確認した操作を列挙する:
  - 日本語IMEでの入力と変換確定(Enterが改行のままであること)
  - Cmd+Enterでコピー → ペーストして内容確認(4つのCopyModeすべてで)
  - Cmd+Shift+Enterでコピー+ウィンドウ非表示
  - 「Copied」表示(単発・連打、約1.5秒で消えること、レイアウトが跳ねないこと)
  - Always on Topトグル
  - Clear(空のとき無効/確認アラート経由)
  - アプリ再起動後の設定復元(Phase 6以降)
  - 絵文字・長文・折り返しを含むテキストでの編集・スクロール・undo
- 手動確認が実行環境の制約でできない場合は「未確認」と明記し、人間に確認を依頼する。

## Reporting Format

最終報告には以下を含めること:

1. 実施したフェーズと、各フェーズのコミットの要約
2. 実行した全コマンドとその結果(成功/失敗、テスト件数)
3. 手動確認した項目と未確認の項目
4. スキップ・中断した項目とその理由(どのStop And Ask条件に該当したか)
5. Phase 7の提案一覧(D8, D11。各提案に: 動機、案、リスク、推奨度)
6. 新たに発見した問題(本書のDebt Mapにないもの)

## Out-of-scope Items

- 新機能の追加(履歴、複数ドラフト、テンプレート編集UI、グローバルホットキー等)
- CopyFormatterテンプレート文言の「改善」
- 外部ライブラリ・ツール(SwiftLint等)の導入
- UIデザインの変更(色・余白・フォントの見た目調整。「Copied」表示の追加は例外として確定済み)
- ダークモード対応(D8: 提案のみ)
- アプリバンドル化・配布・署名・CI構築
- iOS等の他プラットフォーム対応
- パフォーマンスチューニング(D5の撤去で自然に解消するものを除く)
