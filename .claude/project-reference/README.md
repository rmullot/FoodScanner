# Project reference index

Fast orientation into this repo's Claude tooling: every custom agent available here, and every other config file that shapes how work happens. Maintained by `xcode-project-manager` (account-level agent); update it yourself in the same change if you add/remove/rename an agent or a config file and don't want to wait — see `~/.claude/project-standards.md` for the standing rule.

## Agents

Project-level (`.claude/agents/`):

- **mvvmc-architecture-orchestrator** — entry point for any non-trivial feature/refactor; plans and delegates, converges code toward MVVM-C + DI.
- **swiftui-uikit-engineer** — implements/consumes the design system inside app screens; self-audits with the reviewers below.
- **design-system-engineer** — builds/extends the `FoodScannerUI` package itself (tokens/atoms/molecules); owns brand identity and App Store screenshots.
- **design-system-reviewer** — read-only audit of consumer code vs. the package + Apple HIG.
- **rgaa-accessibility-reviewer** — accessibility referent, pinned to RGAA 4.1.2 transposed to iOS.
- **rgpd-privacy-reviewer** — GDPR/data-protection referent (collection, storage, network, retention).
- **app-store-submission-reviewer** — read-only submission-readiness audit (capabilities, Info.plist, ATS, privacy manifest, icon, secrets).
- **test-suite-engineer** — writes unit/UI/performance tests after implementation is green; never touches production code.
- **localization-engineer** — maintains the app's and package's two independent localization layers.
- **technical-debt-migration-orchestrator** — all technical-debt work, 5 strictly sequential phases with human validation between them.
- **apple-docs-referent** — read-only referent for Apple's HIG and developer documentation, read as Markdown via the `tutorials/data/<path>.md` URL rewrite; consulted by the orchestrator, the engineers and the design-system reviewer.

Apple-authored skills (`.claude/skills/`, exported via `xcrun agent skills export`): `swiftui-specialist`, `swiftui-whats-new-27`, `uikit-app-modernization`, `device-interaction`.

Account-level (`~/.claude/agents/`, relevant to this project):

- **xcode-project-manager** — Xcode project hygiene: adds `Docs/`-style files as file references only (never a build-phase member), enforces English/OS-portable filenames, maintains this index folder. Reusable across any repo with an `.xcodeproj`.

## Other config files

- **`CLAUDE.md`** (repo root) — the primary guidance file for Claude Code in this repository; read before any task.
- **`.claude/memory/`** — running backlog files per area, read before starting a task in that area and updated when points resolve or new ones surface: `memory_cybersecurity.md`, `memory_design.md`, `memory_feature.md`, `memory_testing.md`.
- **`.swiftlint.yml`** (repo root) — the lint referent; the Xcode build phase runs `swiftlint lint --strict`, so any warning fails the build.
- **`swiftgen.yml`** (repo root) — app-side codegen config (`Generated/Strings.swift`, `Asset.*`, `SFSymbol.*`).
- **`FoodScanner/SFSymbols.yml`** — app-side SF Symbols declarations feeding the app's SwiftGen run.
- **`FoodScannerUI/swiftgen.yml`** — package-side codegen config (`FSL10n.*`, `FSAsset.*`, `FSSymbol.*`); regeneration documented in `FoodScannerUI/README.md`.
- **`FoodScanner.xcodeproj/project.pbxproj`** — the Xcode project file itself; non-build documentation (`Docs/`) is wired in here as file references only, see `xcode-project-manager` above.
