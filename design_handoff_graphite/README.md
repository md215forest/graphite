# Handoff: Graphite — Prompt Drafting Window

## Overview
Graphite is a small, always-available desktop utility for **drafting prompts before sending them to an LLM**. The user types/edits a prompt in a calm, distraction-free window, then copies it to the clipboard (optionally hiding the window in the same action). The visual identity is "graphite / pencil-lead": a dark, matte, metallic palette with a hexagonal graphite-crystal mark.

This redesign fixes two problems in the original app: (1) **duplicated window controls** in the top-left, and (2) a heavy, cluttered ("もっさり") feel. The new design has a single set of controls and a lighter, more focused layout.

## About the Design Files
The file in this bundle (`Graphite.dc.html`) is a **design reference created in HTML** — a prototype showing the intended look and behavior. It is **not** production code to copy directly. Note it uses a small in-house template runtime (`<x-dc>`, `{{ }}` holes, `sc-if`); treat it as a visual + behavioral spec, **not** as a React file to drop in.

Your task: **recreate this design in the target codebase's environment** using its established patterns. This is a desktop utility (window chrome, "Always on Top", global show/hide), so the natural target is **Electron** or **Tauri** with a React (or your existing) frontend. If no codebase exists yet, choose one of those and implement there.

## Fidelity
**High-fidelity (hifi).** Colors, typography, spacing, and interactions below are final. Recreate the UI pixel-perfectly using your codebase's libraries/patterns.

## Window / Screen

### Single screen: Draft window
- **Purpose**: Draft, edit, and copy a prompt.
- **Window size**: 880 × 600 px (frameless / custom title bar). Resizable is fine; the layout is a vertical flex column.
- **Window shell**: `border-radius: 14px`, `overflow: hidden`, 1px border `rgba(255,255,255,0.07)`, drop shadow `0 36px 90px -24px rgba(0,0,0,0.72)` + inset top highlight `inset 0 1px 0 rgba(255,255,255,0.05)`. Background is a top radial gradient `radial-gradient(125% 85% at 50% -12%, #232427 0%, #191a1d 58%)`.

Layout = 4 stacked regions: **title bar → editor → divider → footer toolbar**.

#### 1. Title bar (height 46px, padding 0 16px)
3-column grid: `1fr auto 1fr`.
- **Left — traffic lights**: 3 × 12px circles, gap 8px. Red `#ec6a5e`, yellow `#f3bd4f`, green `#61c454`, each with `inset 0 0 0 0.5px rgba(0,0,0,0.25)`. (macOS close/minimize/zoom. **Only one set** — this was the duplicate bug.)
- **Center — brand**: hexagonal mark + wordmark, gap 9px.
  - Hex mark: 17×19px, `clip-path: polygon(50% 0,100% 25%,100% 75%,50% 100%,0 75%,0 25%)`, fill `linear-gradient(150deg, var(--accent) 0%, #36383e 88%)`, `inset 0 1px 0 rgba(255,255,255,0.3)`.
  - Wordmark: "Graphite", Hanken Grotesk 600, 15px, letter-spacing 0.04em, color `#e9eaed`.
- **Right — overflow menu**: 28×28px ghost button, glyph "⋯" 17px, color `#797c85`; hover bg `rgba(255,255,255,0.06)`, color `#b3b6bd`.

#### Dividers (×2: under title bar, above footer)
1px high, `linear-gradient(90deg, transparent 4%, rgba(255,255,255,0.09) 50%, transparent 96%)` (footer one uses 0.07 alpha). This is the "graphite sheen" edge.

#### 2. Editor (flex: 1)
- Full-bleed `<textarea>` over the window background (transparent), resize off, no border/outline.
- Padding `30px 34px`. Font **JetBrains Mono 400, 15px**, line-height 1.78, letter-spacing 0.01em, color `#e6e7ea`, caret `var(--accent)`.
- Placeholder: "Draft your prompt safely before sending", color `#5a5d65`. `spellcheck=false`.
- Selection color `rgba(185,190,200,0.22)`.
- Custom scrollbar: 9px wide, thumb `rgba(255,255,255,0.08)` (hover 0.14), rounded, 2px transparent inset border.
- **Optional texture overlay** (toggle, default on): absolutely-positioned, `pointer-events:none`, opacity 0.6, `repeating-linear-gradient(132deg, rgba(255,255,255,0.02) 0 1px, transparent 1px 8px)` — a faint diagonal "pencil grain".

#### 3. Footer toolbar (height 58px, padding `0 16px 0 18px`)
Horizontal flex, gap 12px, background `linear-gradient(180deg, #171819 0%, #141517 100%)`.
- **Left — live counter**: small 14×16px graphite hex (`#4a4d54`) + count label. Label is JetBrains Mono 11.5px, color `#6f727a`, format: `1,234 chars  ·  5 lines` (singular "char"/"line" at count 1; chars use thousands separators).
- Spacer (`flex:1`).
- **Always on Top** toggle button: ghost, 12.5px Hanken Grotesk, color `#9a9da4` (hover `#c6c8cd`). Custom checkbox: 15×15px, 1.5px border `rgba(255,255,255,0.22)`, radius 4px; when on, fill `var(--accent)` with a `#1a1b1f` "✓".
- **Clear** button: ghost, same type; hover bg `rgba(255,255,255,0.05)`.
- 1px × 20px vertical separator `rgba(255,255,255,0.08)`.
- **Enter-hint label**: 11.5px, color `#65686f`. Text reflects the Enter-key mode (see Behavior).
- **Copy** button (secondary): 1px border `rgba(255,255,255,0.1)`, bg `rgba(255,255,255,0.03)`, radius 8px, padding `7px 12px`, color `#d2d4d9`, weight 500. Leading shortcut glyph `⌘↵` in JetBrains Mono 11px, color `#9296a0`. Hover: bg `rgba(255,255,255,0.07)`, border `rgba(255,255,255,0.16)`. Label flips to "Copied" for ~1.2s after use.
- **Copy & Hide** button (primary): border `rgba(255,255,255,0.13)` with top border `var(--accent-soft)`, bg `linear-gradient(180deg, #3b3e45 0%, #2a2c31 100%)`, radius 8px, padding `7px 13px`, color `#f0f1f3`, weight 600, `inset 0 1px 0 rgba(255,255,255,0.14)` + `0 1px 2px rgba(0,0,0,0.4)`. Leading glyph `⇧⌘↵` (JetBrains Mono 11px, `#b7bac1`). Hover lightens the gradient. Label flips to "Copied".

#### Toast (transient confirmation)
Absolutely positioned, bottom 74px, horizontally centered. `padding 9px 15px`, radius 10px, bg `#26282d`, 1px border `rgba(255,255,255,0.1)`, shadow `0 14px 36px rgba(0,0,0,0.55)`, 12.5px text `#e6e7ea`. Leading 7px accent dot. Entry animation `gphFade` 0.18s ease (fade + 6px rise, translateX(-50%) preserved). Auto-dismiss after 1.6s. Copy: "Copied to clipboard" or "Copied — window hidden".

## Interactions & Behavior
- **Copy** (button or `⌘/Ctrl + Enter`): write textarea content to clipboard → "Copied" state (1.2s) → toast "Copied to clipboard".
- **Copy & Hide** (button or `⇧ + ⌘/Ctrl + Enter`): same copy, then **hide the window** (in Electron/Tauri call `window.hide()` — the HTML prototype can't, so it only toasts "Copied — window hidden"). A global shortcut should re-show it.
- **Enter-key mode** (config): `newline` (default) = Enter inserts a newline, hint reads "Enter for new line"; `send` = bare Enter triggers Copy, hint reads "Enter to copy". The ⌘/⇧⌘ combos always work regardless of mode.
- **Clear**: empties the textarea and refocuses it.
- **Always on Top**: toggles the checkbox state; in the real app, call the window's always-on-top API.
- **Autofocus**: textarea is focused on launch.
- **Counter**: updates live on every keystroke.

## State Management
- `text: string` — textarea content (the prompt). Persist across launches (localStorage / app store) so a draft survives quit — the prototype does not, but the real app should.
- `alwaysOnTop: boolean` — wired to the window API.
- `copied: boolean` — transient (~1.2s) for button label.
- `toast: string` — transient (~1.6s) message; empty = hidden.
- Config: `accent` ('silver' | 'steel' | 'amber'), `showTexture: boolean`, `enterKey` ('newline' | 'send'). Surface these in app settings.

## Design Tokens
**Accent (graphite "lead" color), set via `--accent` / `--accent-soft`:**
- silver (default): `#b9bec8` / `rgba(185,190,200,0.32)`
- steel: `#92a8c6` / `rgba(146,168,198,0.34)`
- amber: `#d8b27a` / `rgba(216,178,122,0.34)`

**Surfaces / lines:**
- Outer app bg: `#0c0d0f`; ambient gradient `radial-gradient(150% 130% at 50% -5%, #17181b, #0b0c0e 68%)`
- Window bg gradient: `#232427 → #191a1d`
- Footer gradient: `#171819 → #141517`
- Toast bg `#26282d`; graphite hex (footer) `#4a4d54`
- Hairlines: `rgba(255,255,255,0.07–0.09)`

**Text:** primary `#e6e7ea` / `#e9eaed`; secondary `#9a9da4` / `#c6c8cd` (hover); tertiary/labels `#65686f`–`#6f727a`; placeholder `#5a5d65`.

**Traffic lights:** `#ec6a5e` / `#f3bd4f` / `#61c454`.

**Type:** UI = Hanken Grotesk (400/500/600/700); editor + numerals/shortcuts = JetBrains Mono (400/500). Sizes: wordmark 15px, body/editor 15px, controls 12.5px, labels 11.5px, shortcut glyphs 11px.

**Radii:** window 14px; buttons 7–8px; checkbox 4px; toast 10px. **Shadows:** see window shell + toast above.

## Assets
No external image assets. The brand mark is a CSS `clip-path` hexagon (no SVG/PNG needed) — reproduce it the same way or as an SVG. Fonts load from Google Fonts (Hanken Grotesk, JetBrains Mono); self-host in production if preferred.

## Files
- `Graphite.dc.html` — the full design reference (markup + styling + behavior logic). Open it in a browser to see the live prototype. Read the `<style>`/inline styles for exact values and the `class Component` block for the interaction logic (copy, shortcuts, counter, toast, accent switching).
- `graphite_reference.png` — *(add if you requested a screenshot)* rendered reference image.
