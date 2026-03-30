# WebBar V1 Test Report

- Date: 2026-03-30
- Project: WebBar
- Environment: macOS (Xcode 26.3, Swift 6.2.4)

## 1. Build and Test Commands

1. `swift build`  
   Result: PASS
2. `swift test`  
   Result: PASS (16/16)
3. `swift build -c release`  
   Result: PASS
4. `bash scripts/build_app.sh`  
   Result: PASS, app bundle generated at `dist/WebBar.app`
5. `bash scripts/install_app.sh`  
   Result: PASS, installed to `~/Applications/WebBar.app`
6. `open ~/Applications/WebBar.app` and `pgrep -fl WebBar`  
   Result: PASS, process detected

## 2. Automated Coverage Summary

1. URL validation (multi-scheme support + malformed input rejection)
2. Max 5 links rule enforcement
3. JSON storage CRUD and ordering
4. Status item view model max-count behavior
5. Icon resolver strategy (favicon / emoji / fallback)
6. Link management view model add/edit/delete and launch-at-login toggle persistence flag path

## 3. Manual Verification Checklist

1. Status bar icon appears after app launch
2. Right-click icon shows menu with `管理网址` and `退出 WebBar`
3. Management window can add, edit, delete links
4. Up to 5 links displayed in status bar; adding 6th is blocked
5. Left-click link icon opens URL via system default handler
6. Favicon failure path with emoji fallback icon
7. Open failure path shows red flash and notification
8. Launch-at-login toggle behavior in Settings

Notes:
- Items above require interactive desktop confirmation and were prepared for user-side click-through.

