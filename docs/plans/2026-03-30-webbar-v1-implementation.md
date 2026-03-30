# WebBar V1 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a shippable macOS menu bar app (WebBar V1) that opens configured URLs in one click, with up to 5 status bar icons, in-app link management, favicon/emoji icon strategy, failure feedback, local persistence, and optional launch at login.

**Architecture:** Use a Swift Package (`swift-tools-version: 6.0`) with AppKit runtime and SwiftUI management window. Keep pure logic in `Core` (models, validation, storage, icon policy) and platform integration in `App` (status items, NSWorkspace open, notifications, launch-at-login). Resource files (Info.plist, icon assets) are bundled with the executable; release packaging script generates a signed-ready `.app` bundle layout.

**Tech Stack:** Swift 6, AppKit, SwiftUI, ServiceManagement, UserNotifications, URLSession, XCTest.

## Task 1: Project Bootstrap and Build Targets

**Owner:** Subagent A  
**Files:**
- Create: `Package.swift`
- Create: `Sources/WebBar/App/WebBarMain.swift`
- Create: `Sources/WebBar/App/AppDelegate.swift`
- Create: `Sources/WebBar/App/BuildInfo.swift`
- Create: `Resources/Info.plist`
- Create: `scripts/build_app.sh`
- Create: `scripts/install_app.sh`

**Step 1: Write the failing smoke test command**

Run: `swift build`  
Expected: FAIL (package does not exist yet)

**Step 2: Write minimal package and app entry implementation**

Create a macOS executable target `WebBar` with resource processing and minimum deployment target `macOS 14`.

**Step 3: Run build to verify green**

Run: `swift build`  
Expected: PASS

**Step 4: Verify release artifact**

Run: `swift build -c release`  
Expected: PASS and binary at `.build/release/WebBar`

## Task 2: Core Domain + Local Persistence (TDD)

**Owner:** Subagent B  
**Files:**
- Create: `Sources/WebBar/Core/Models.swift`
- Create: `Sources/WebBar/Core/Validation.swift`
- Create: `Sources/WebBar/Core/LinkStore.swift`
- Create: `Tests/WebBarTests/ValidationTests.swift`
- Create: `Tests/WebBarTests/LinkStoreTests.swift`

**Step 1: Write failing tests for URL validation and max-count rule**

Test expectations:
- accept `https://`, `http://`, `mailto:`, `obsidian:`
- reject empty/malformed URLs
- reject saving 6th link (max 5)

**Step 2: Run targeted tests and verify red**

Run: `swift test --filter ValidationTests`  
Expected: FAIL

**Step 3: Implement minimal validation + model logic**

Add:
- `LinkItem`
- `IconPreference` (`favicon` or `emoji`)
- validation service with clear error reasons

**Step 4: Re-run tests and verify green**

Run: `swift test --filter ValidationTests`  
Expected: PASS

**Step 5: Write failing persistence tests**

Test expectations:
- save/load round trip
- preserves insertion order
- delete/edit reflects correctly

**Step 6: Run tests verify red, implement JSON store, then green**

Run: `swift test --filter LinkStoreTests`  
Expected: FAIL then PASS after implementation

## Task 3: Status Bar Engine + Open URL Behavior

**Owner:** Subagent C  
**Files:**
- Create: `Sources/WebBar/App/StatusBarController.swift`
- Create: `Sources/WebBar/App/StatusItemViewModel.swift`
- Create: `Sources/WebBar/App/URLOpener.swift`
- Create: `Tests/WebBarTests/StatusItemViewModelTests.swift`

**Step 1: Write failing view-model tests**

Test expectations:
- maps `LinkItem` list to max 5 visual slots
- emits left-click open action
- emits right-click manage action

**Step 2: Run test and verify red**

Run: `swift test --filter StatusItemViewModelTests`  
Expected: FAIL

**Step 3: Implement minimal controller/view-model**

Use `NSStatusBar.system` with one `NSStatusItem` per link.  
Left click: open URL via `NSWorkspace.shared.open`.  
Right click: context menu includes `管理网址` and `退出`.

**Step 4: Verify green**

Run: `swift test --filter StatusItemViewModelTests`  
Expected: PASS

## Task 4: Management Window (SwiftUI) + Live Sync

**Owner:** Subagent D  
**Files:**
- Create: `Sources/WebBar/App/ManagementWindowController.swift`
- Create: `Sources/WebBar/UI/LinkManagementView.swift`
- Create: `Sources/WebBar/UI/LinkEditorView.swift`
- Create: `Sources/WebBar/UI/SettingsView.swift`
- Create: `Sources/WebBar/UI/ViewModels/LinkManagementViewModel.swift`
- Create: `Tests/WebBarTests/LinkManagementViewModelTests.swift`

**Step 1: Write failing VM tests**

Test expectations:
- add/edit/delete link operations update in-memory list
- invalid URL gives validation message
- 6th entry blocked with max-limit message

**Step 2: Run tests verify red**

Run: `swift test --filter LinkManagementViewModelTests`  
Expected: FAIL

**Step 3: Implement VM then UI**

Provide:
- table/list of links
- add/edit form with name + URL + icon mode
- emoji field enabled only for emoji mode
- launch-at-login toggle in settings area

**Step 4: Run tests verify green**

Run: `swift test --filter LinkManagementViewModelTests`  
Expected: PASS

## Task 5: Icon Pipeline (favicon + emoji fallback) and Assets

**Owner:** Subagent E  
**Files:**
- Create: `Sources/WebBar/App/IconResolver.swift`
- Create: `Sources/WebBar/App/FaviconFetcher.swift`
- Create: `Sources/WebBar/App/EmojiIconRenderer.swift`
- Create: `Sources/WebBar/App/TemplateImage.swift`
- Create: `Tests/WebBarTests/IconResolverTests.swift`
- Create: `Assets/app_icon.svg`
- Create: `Assets/status_ok_template.svg`
- Create: `scripts/generate_icons.sh`

**Step 1: Write failing icon policy tests**

Test expectations:
- favicon success -> use favicon image
- favicon fail + emoji exists -> use emoji-rendered image
- both unavailable -> use default monochrome OK icon

**Step 2: Run tests verify red**

Run: `swift test --filter IconResolverTests`  
Expected: FAIL

**Step 3: Implement minimal resolver + renderer**

Rules:
- status bar icon output must be monochrome/template style
- app icon content is “OK hand” concept
- support SVG source assets and conversion script hooks

**Step 4: Verify green**

Run: `swift test --filter IconResolverTests`  
Expected: PASS

## Task 6: Failure Feedback + Notifications + Launch at Login

**Owner:** Main agent (integration task)
**Files:**
- Modify: `Sources/WebBar/App/StatusBarController.swift`
- Modify: `Sources/WebBar/App/AppDelegate.swift`
- Create: `Sources/WebBar/App/ErrorFeedback.swift`
- Create: `Sources/WebBar/App/LaunchAtLoginService.swift`
- Create: `Tests/WebBarTests/LaunchAtLoginServiceTests.swift`

**Step 1: Write failing service test**

Run: `swift test --filter LaunchAtLoginServiceTests`  
Expected: FAIL

**Step 2: Implement launch-at-login and error feedback**

Behavior:
- open failure triggers 1-second red flash for clicked icon
- push local notification with URL and failure reason
- launch-at-login default off; toggle persists and applies

**Step 3: Run test + full suite**

Run: `swift test`  
Expected: PASS

## Task 7: End-to-End Build, Package, Install, Verify

**Owner:** Main agent
**Files:**
- Modify: `scripts/build_app.sh`
- Modify: `scripts/install_app.sh`
- Create: `docs/plans/2026-03-30-webbar-v1-test-report.md`

**Step 1: Build release**

Run: `bash scripts/build_app.sh`  
Expected: PASS and `dist/WebBar.app`

**Step 2: Install locally**

Run: `bash scripts/install_app.sh`  
Expected: `~/Applications/WebBar.app` exists (or `/Applications` if permitted)

**Step 3: Manual verification checklist**

1. Add 1 link -> icon appears -> left click opens URL.
2. Add up to 5 links -> all visible.
3. Add 6th link -> blocked with message.
4. Right-click any icon -> opens management page.
5. Favicon fail path -> emoji fallback works.
6. Invalid open -> red flash + notification.
7. Toggle launch-at-login -> persists after restart.

## Parallelization Boundaries

1. Task 1,2,5 can start in parallel after directory skeleton exists.
2. Task 3 depends on Task 2 models.
3. Task 4 depends on Task 2 models and Task 1 app lifecycle.
4. Task 6 depends on Task 3 + Task 4 + Task 5 integration points.
5. Task 7 runs last.

## Done Criteria

1. `swift test` full pass.
2. `swift build -c release` pass.
3. `dist/WebBar.app` generated and installed locally.
4. Manual verification report written with pass/fail evidence.

