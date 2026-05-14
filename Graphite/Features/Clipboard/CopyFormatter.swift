import Foundation

enum CopyFormatter {
    static func format(_ text: String, mode: CopyMode) -> String {
        switch mode {
        case .raw:
            return text
        case .trimmed:
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
        case .codex:
            let body = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !body.isEmpty else { return "" }
            return """
            # 目的

            \(body)

            # 制約

            - 既存の挙動を壊さないでください
            - 変更範囲を必要最小限にしてください

            # 確認方法

            - 実装後に確認方法を提示してください
            """
        case .githubIssue:
            return """
            ## 概要

            \(text)

            ## 対応内容

            -

            ## 受け入れ条件

            -

            ## 確認方法

            -
            """
        }
    }
}
