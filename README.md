# Graphite

Graphite is a macOS prompt drafting editor for ChatGPT and Codex.

## Concept

Graphite provides a safe place to draft, format, and copy prompts before sending them to AI tools.

## Why

Japanese IME users often use Enter to confirm conversion, while many AI tools use Enter to send messages. Graphite avoids accidental sends by making Enter a normal newline and using Cmd+Enter for explicit copy actions.

## Features

- macOS native prompt editor
- IME-safe editing
- Enter inserts newline
- Cmd+Enter copies prompt
- Cmd+Shift+Enter copies prompt and hides window
- Copy modes for raw, trimmed, Codex, and GitHub Issue
- Always on Top toggle
- Minimal floating-friendly UI
- Local-only by default

## Development

Open the package in Xcode and run the Graphite target.

## Notes

- Graphite does not send prompts to external services.
- Graphite does not auto-paste or auto-send to other apps.
