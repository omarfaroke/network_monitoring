# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[1.0.0]: https://github.com/omarfaroke/network_monitoring/releases/tag/v1.0.0
