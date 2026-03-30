# WebBar WebView Mode Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a per-site open mode so WebBar can either open a URL in the default browser or toggle a resizable in-app browser panel with persistent login state.

**Architecture:** Extend the link model with per-site open mode and saved panel geometry. Keep favicon-first status bar icons. Add a `WKWebView`-backed `NSPanel` controller per link, using a dedicated `WKWebsiteDataStore` per site to isolate and persist login sessions. Status bar clicks route to either `NSWorkspace.open` or panel toggle. The management UI exposes the open mode per site.

**Tech Stack:** Swift 6, AppKit, SwiftUI, WebKit, XCTest.

### Task 1: Model and ViewModel support for per-site open mode

**Files:**
- Modify: `Sources/WebBar/Core/Models.swift`
- Modify: `Sources/WebBar/UI/ViewModels/LinkManagementViewModel.swift`
- Modify: `Tests/WebBarTests/LinkManagementViewModelTests.swift`
- Modify: `Tests/WebBarTests/LinkStoreTests.swift`

**Step 1: Write the failing tests**

Add tests covering:
- `LinkItem` persists `openMode`
- `LinkDraft` -> saved `LinkItem` keeps selected mode
- updating a link can switch from default browser to in-app panel mode

**Step 2: Run tests to verify red**

Run: `swift test --filter LinkManagementViewModelTests`
Expected: FAIL because `openMode` does not exist

**Step 3: Write minimal implementation**

Add:
- `OpenMode` enum: `defaultBrowser`, `embeddedPanel`
- `openMode` to `LinkItem`
- `openMode` to `LinkDraft`
- add/update flow in `LinkManagementViewModel`

**Step 4: Run tests to verify green**

Run: `swift test --filter LinkManagementViewModelTests`
Expected: PASS

### Task 2: Embedded browser panel controller with persisted geometry and isolated login state

**Files:**
- Create: `Sources/WebBar/App/WebPanelController.swift`
- Create: `Sources/WebBar/App/WebViewContainerView.swift`
- Create: `Sources/WebBar/App/WebSessionStore.swift`
- Create: `Tests/WebBarTests/WebSessionStoreTests.swift`

**Step 1: Write the failing tests**

Add tests covering:
- per-link frame save/load
- per-link storage identifier/path creation is deterministic

**Step 2: Run tests to verify red**

Run: `swift test --filter WebSessionStoreTests`
Expected: FAIL because panel/session store code does not exist

**Step 3: Write minimal implementation**

Build:
- `WebSessionStore` for per-link frame persistence
- `NSPanel` wrapper with `WKWebView`
- resizable panel, closable, remembers frame
- toolbar controls: back, forward, refresh, reset session
- open unsupported/new-window navigation in system browser
- separate persistent `WKWebsiteDataStore` per link

**Step 4: Run tests to verify green**

Run: `swift test --filter WebSessionStoreTests`
Expected: PASS

### Task 3: Status bar integration and routing logic

**Files:**
- Modify: `Sources/WebBar/App/URLOpener.swift`
- Modify: `Sources/WebBar/App/StatusBarController.swift`
- Modify: `Sources/WebBar/App/AppDelegate.swift`
- Modify: `Tests/WebBarTests/StatusItemViewModelTests.swift`

**Step 1: Write the failing tests**

Add tests covering:
- favicon remains preferred for status items
- clicking a link marked `embeddedPanel` routes to panel toggle instead of `NSWorkspace.open`

**Step 2: Run tests to verify red**

Run: `swift test --filter StatusItemViewModelTests`
Expected: FAIL because routing lacks open mode support

**Step 3: Write minimal implementation**

Add:
- a routing abstraction for `defaultBrowser` vs `embeddedPanel`
- one lazily created panel controller per link id
- repeated click toggles show/hide for the same link

**Step 4: Run tests to verify green**

Run: `swift test --filter StatusItemViewModelTests`
Expected: PASS

### Task 4: Management UI for per-site mode selection

**Files:**
- Modify: `Sources/WebBar/UI/LinkEditorView.swift`
- Modify: `Sources/WebBar/UI/LinkManagementView.swift`
- Modify: `Tests/WebBarTests/LinkManagementViewModelTests.swift`

**Step 1: Write the failing tests**

Add assertions that draft values for edit mode preserve `openMode` and updates apply it.

**Step 2: Run tests to verify red**

Run: `swift test --filter LinkManagementViewModelTests`
Expected: FAIL if UI/draft mapping is incomplete

**Step 3: Write minimal implementation**

Add a simple picker:
- `默认浏览器`
- `内嵌弹窗`

When a row is displayed, show a compact label for its mode.

**Step 4: Run tests to verify green**

Run: `swift test --filter LinkManagementViewModelTests`
Expected: PASS

### Task 5: Full verification and packaging

**Files:**
- Modify: `docs/plans/2026-03-30-webbar-v1-test-report.md`

**Step 1: Run full test suite**

Run: `swift test`
Expected: PASS

**Step 2: Run release build**

Run: `swift build -c release`
Expected: PASS

**Step 3: Rebuild and reinstall app**

Run: `bash scripts/build_app.sh`
Run: `bash scripts/install_app.sh`
Expected: PASS

**Step 4: Manual verification**

1. Add a link using `内嵌弹窗`
2. Click status icon -> panel opens near menu bar
3. Resize panel -> close -> reopen -> size/position restored
4. Login to a test site -> close -> reopen -> session persists
5. Toggle same icon -> panel hides/shows
6. Link in `默认浏览器` mode still opens via system browser

