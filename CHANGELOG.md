# Changelog

All notable changes to this package are documented in this file.

## [2.4.0] - 2026-08-26

### Added

- Host override: rewrite the host, scheme, and port of matching outgoing requests (all traffic or a specific URL pattern), in-app and in the remote UI
- Request breakpoint URL editing (in-app and remote continue payload)
- Overview shows the full request: complete URL, original URL when rewritten, query, request headers, and request body
- Line numbers on request/response JSON and text blocks, kept visible while the body scrolls horizontally
- JSON object/array folding (per-block collapse/expand all, plus per-object arrows)
- Remote JSON table view with expandable nested key/value rows (no depth limit)
- Sticky Request/Response body header in the remote detail pane

## [2.3.0] - 2026-08-19

### Added

- Remote monitor: local Dart HTTP server (default port `7382`, falls back to the next free port) that serves a browser UI
- Split-pane remote UI: request list on the left, details on the right (stacked on narrow screens)
- Remote breakpoints: add/toggle rules, pause/edit/continue/cancel with header and body edits applied to the real Dio request/response, global pause, and an applied-breakpoints panel
- Live updates from the device over WebSocket (`/ws`), with Server-Sent Events fallback
- Keyboard navigation in the remote UI: arrow keys and Enter for the request list, left/right to switch detail tabs, last selected tab kept when changing requests
- Copy on remote over plain HTTP LAN URLs (Clipboard API fallback)
- Remote monitor toggle in Dev Mode Options with a clickable URL and copy action
- Optional `openUrl` and `remoteMonitorPort` on `NetworkMonitoringConfig`
- `HttpRecordModel.toJson()` for the remote API
- `NetworkMonitorChange.remoteMonitor` for reactive UI updates

### Changed

- Stronger highlight color for the current find-in-page match (in-app and remote)
- Share actions are hidden in the remote UI (copy remains available)

## [2.2.0] - 2026-08-04

### Added

- Configurable list search scopes (URL, status, headers, query, request body, response body) via the tune control on the monitor search bar
- Find-in-page search on the request/response detail view, including:
  - Match highlighting with prev/next navigation that scrolls to the active match
  - Automatic tab switching when the next/previous match is on another tab
  - Carrying the list search query into the detail view when opening a record
  - Configurable tab search scopes (defaults to the current tab; can search all tabs or any selected tabs)

### Changed

- Overview auth token shows the full value with wrapping instead of truncating with ellipsis

## [2.1.0] - 2026-06-05

### Added

- `enabled` flag on `NetworkMonitoringConfig` (default `true`) to disable monitoring, dev mode, overlay, and the Dio interceptor in one place — useful for gating the package behind `kDebugMode` or a feature flag

## [2.0.0] - 2026-06-05

### Changed

- **Breaking:** Share actions now use a required `shareContent` callback on `NetworkMonitoringConfig` instead of a built-in `share_plus` dependency — host apps wire their own share plugin (we avoid depending on third-party packages like [share_plus] or [platform_channels] to keep the package lightweight, and avoid `resolving dependencies` errors in the future.)
- **Breaking:** `NetworkMonitoring.initialize()` requires an explicit `NetworkMonitoringConfig` (no default config)
- Declared platform support for Android, iOS, Linux, macOS, and Windows only (web is not supported)
- Migrated `RadioListTile` usage to `RadioGroup` for Flutter 3.35+ compatibility

### Removed

- **Breaking:** `share_plus` dependency removed from the package

## [1.0.1] - 2026-06-03

### Changed

- Improved pub.dev package description
- Added pub.dev topics for better discoverability: `dio`, `network`, `monitoring`, `debug`, `dev-mode`

## [1.0.0] - 2026-06-03

Initial release.

### Added

- Dio interceptor that records requests, responses, and errors while monitoring is enabled
- Floating draggable overlay with live request count and paused-request badge
- Request inspector with search, method filters, and tabbed detail views (overview, request, response, JWT)
- Breakpoints to pause matching traffic, edit headers/body, then continue or cancel
- Global pause/resume for all in-flight HTTP traffic
- JWT decoding for `Authorization` and `x-auth-token` headers in the detail view
- Copy and share actions for URL, headers, body, tokens, and full request dumps
- Hidden dev mode unlock via `VersionTapDetector` or custom `requestEnableDevMode` flows
- `NetworkMonitoringBuilder` for reactive UI driven by `NetworkMonitorChanges`
- `DevModeOptionsView` for dev settings
- English and Arabic localizations
- Example notes app (`example/`) demonstrating Dio integration, JWT auth, and dev-mode unlock

[2.4.0]: https://github.com/omarfaroke/network_monitoring/releases/tag/v2.4.0
[2.3.0]: https://github.com/omarfaroke/network_monitoring/releases/tag/v2.3.0
[2.2.0]: https://github.com/omarfaroke/network_monitoring/releases/tag/v2.2.0
[2.1.0]: https://github.com/omarfaroke/network_monitoring/releases/tag/v2.1.0
[2.0.0]: https://github.com/omarfaroke/network_monitoring/releases/tag/v2.0.0
[1.0.1]: https://github.com/omarfaroke/network_monitoring/releases/tag/v1.0.1
[1.0.0]: https://github.com/omarfaroke/network_monitoring/releases/tag/v1.0.0
