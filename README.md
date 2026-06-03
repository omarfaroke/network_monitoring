
<p >
  <a href="https://pub.dev/packages/network_monitoring"><img src="https://img.shields.io/pub/v/network_monitoring"></a>
</p>


# network_monitoring

Simple Package for Real-time HTTP network monitoring for Flutter apps. Capture Dio traffic, inspect requests and responses, pause traffic with breakpoints, and debug APIs from a floating overlay — all behind a hidden dev mode.

Built for **Dio** and designed to stay out of production UX until you unlock it.

## Demo

<p>
<img width="300" height="600" src="https://raw.githubusercontent.com/omarfaroke/network_monitoring/main/screenshots/example.gif">
</p>

## Features

- **Dio interceptor** — Records every request, response, and error while monitoring is enabled
- **Floating overlay** — Draggable button with a live request count and paused-request badge
- **Request inspector** — Search, filter by method, and open tabbed detail views (overview, request, response, JWT)
- **Breakpoints** — Pause matching requests or responses, edit headers/body, then continue or cancel
- **Global pause** — Hold all in-flight traffic until you resume
- **JWT decoding** — Automatically decodes `Authorization` / `x-auth-token` headers in the detail view
- **Copy & share** — Copy URL, headers, body, token, or share the full request dump
- **Hidden dev mode** — Unlock with `VersionTapDetector`, or enable it yourself from a debug menu / `kDebugMode` gate

---

## Requirements


|             |                                              |
| ----------- | -------------------------------------------- |
| Dart SDK    | `^3.10.0`                                    |
| HTTP client | [Dio](https://pub.dev/packages/dio) `^5.9.0` |


---

## Example app

A full **notes** demo lives in `[example/](https://github.com/omarfaroke/network_monitoring/tree/main/example)` (**Android & iOS only**). It runs a local JWT API server (`dart:io`), uses Dio + this package’s interceptor, and includes login, CRUD, search/filter, profile, and dev-mode unlock (6 taps on version, password `123456`).

```bash
cd example
flutter pub get
flutter run -d android   # or -d ios
```

See [example/README.md](https://github.com/omarfaroke/network_monitoring/tree/main/example/README.md) for more.

---

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  network_monitoring: ^1.0.0
```

Then run:

```bash
flutter pub get
```

---

## Quick start

### 1. Initialize at startup

Call `NetworkMonitoring.initialize()` before `runApp`:

```dart
import 'package:network_monitoring/network_monitoring.dart';

void main() {
  NetworkMonitoring.initialize(
    config: NetworkMonitoringConfig(
      requiredTaps: 6,
      validatePasswordInput: (password) => password == 'dev123',
      brandColor: Colors.blue,
    ),
  );

  runApp(const MyApp());
}
```

### 2. Add the Dio interceptor

Add it **last** in the interceptor list so it records the final request (after auth, logging, etc.) and sees responses in the correct order relative to other interceptors.

```dart
final dio = Dio();
dio.interceptors.add(LogInterceptor()); // other interceptors first
dio.interceptors.add(NetworkMonitoring.createInterceptor()); // add last
```

### 3. Wrap your app with the overlay

Place `NetworkMonitorOverlayWrapper` inside `MaterialApp.builder` so the floating button can appear above every route:

```dart
MaterialApp(
  builder: (context, child) {
    return NetworkMonitorOverlayWrapper(child: child!);
  },
  home: const HomePage(),
)
```

### 4. Enable dev mode

You can turn on dev mode in two ways. Use whichever fits your app.

#### Option A — Programmatic (no `VersionTapDetector`)

Call `requestEnableDevMode(context)` from any debug entry point. It shows the password dialog when `validatePasswordInput` is configured, then enables dev mode:

```dart
Future<void> unlockDevMode(BuildContext context) async {
  await NetworkMonitoring.instance.controller.requestEnableDevMode(context);
}
```

Use `enableDevMode()` only when you want to skip the dialog (for example behind `kDebugMode`):

```dart
if (kDebugMode) {
  NetworkMonitoring.instance.controller.enableDevMode();
}
```

To turn dev mode off and reset monitoring / overlay state:

```dart
NetworkMonitoring.instance.controller.disableDevMode();
```

After dev mode is on, start capturing traffic explicitly (same as toggling **HTTP monitoring** in settings):

```dart
NetworkMonitoring.instance.controller.toggleMonitoring(true);
```

Or open **Dev Mode Options** and let the user enable monitoring there.

#### Option B — Secret tap gesture (`VersionTapDetector`)

Wrap your app version label (or any hidden widget) with `VersionTapDetector`. After the configured number of taps, dev mode is enabled. When `validatePasswordInput` is set, the built-in password dialog is shown automatically:

```dart
VersionTapDetector(
  child: Text('v1.0.0'),
)
```

`VersionTapDetector` is optional. If you already enable dev mode programmatically, you do not need this widget.

### 5. Open dev mode settings (optional)

Navigate to the built-in settings screen when dev mode is active:

```dart
NetworkMonitoringBuilder(
  listenTo: NetworkMonitorChanges.devMode,
  builder: (context, controller) {
    if (!controller.isDevModeEnabled) return const SizedBox.shrink();

    return ListTile(
      title: const Text('Dev Mode'),
      onTap: () => DevModeOptionsView.push(context),
    );
  },
)
```

From **Dev Mode Options**, toggle HTTP monitoring on. The floating overlay appears and traffic is captured automatically.

---

## Enabling dev mode (summary)


| Approach                                   | When to use                                                                        |
| ------------------------------------------ | ---------------------------------------------------------------------------------- |
| `controller.requestEnableDevMode(context)` | Debug menu or custom unlock; handles password dialog when configured               |
| `controller.enableDevMode()`               | Skip password dialog (`kDebugMode`, tests, or after your own auth)                 |
| `VersionTapDetector`                       | Hidden gesture on a version label; password dialog handled by the package          |
| `controller.toggleMonitoring(true)`        | Start/stop capture after dev mode is already on (works with either approach above) |


---

## Localization

The package ships with **English** and **Arabic**. Register the delegate in your `MaterialApp`:

```dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:network_monitoring/network_monitoring.dart';

MaterialApp(
  localizationsDelegates: const [
    NetworkMonitoringLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: NetworkMonitoringLocalizations.supportedLocales,
  // ...
)
```

If the delegate is not registered, the package falls back to English strings automatically.

---

## Configuration

`NetworkMonitoringConfig` controls dev-mode access and UI branding:


| Property                | Default     | Description                                                                                            |
| ----------------------- | ----------- | ------------------------------------------------------------------------------------------------------ |
| `requiredTaps`          | `6`         | Taps on `VersionTapDetector` needed to unlock dev mode (ignored if you use `enableDevMode()` directly) |
| `tapResetDuration`      | `3 seconds` | Idle time before the tap counter resets                                                                |
| `validatePasswordInput` | `null`      | Password validator; when set, a dialog is shown before dev mode unlocks                                |
| `brandColor`            | `null`      | Accent color for monitoring UI; falls back to `ThemeData.colorScheme.primary`                          |


```dart
NetworkMonitoringConfig(
  requiredTaps: 8,
  tapResetDuration: const Duration(seconds: 5),
  validatePasswordInput: (password) async {
    return password == await fetchDevPassword();
  },
  brandColor: AppColor.brandColor,
)
```

---

## Reactive UI

Use `NetworkMonitoringBuilder` to rebuild only when specific controller state changes:

```dart
NetworkMonitoringBuilder(
  listenTo: NetworkMonitorChanges.monitorView,
  builder: (context, controller) {
    return Text('${controller.records.length} requests captured');
  },
)
```

Predefined change groups in `NetworkMonitorChanges`:


| Group            | Rebuilds when…                                  |
| ---------------- | ----------------------------------------------- |
| `devMode`        | Dev mode is enabled or disabled                 |
| `overlay`        | Floating overlay visibility changes             |
| `breakpoints`    | Breakpoint rules are added, removed, or toggled |
| `floatingButton` | Record list or active breakpoint count changes  |
| `monitorView`    | Monitor list screen data changes                |
| `devModeOptions` | Dev mode settings toggles change                |


For custom `StatefulWidget`s, use the `NetworkMonitorControllerListener` mixin (same pattern as the built-in widgets).

---

## How it works

```
┌──────────────────────┐     ┌──────────────────────────┐     ┌─────────────────────┐
│ VersionTapDetector   │     │ NetworkMonitorController │◀────│ Dio Interceptor     │
│ or enableDevMode()   │──▶  │ (records, breakpoints)   │     │ (capture traffic)   │
└──────────────────────┘     └────────────┬─────────────┘     └─────────────────────┘
                                          │
                               ┌──────────▼──────────┐
                               │ Floating overlay    │
                               │ → NetworkMonitorView│
                               │ → Detail / Breakpoint│
                               └─────────────────────┘
```

1. **Dev mode off** — The interceptor is a no-op; no records are stored and no UI is shown.
2. **Dev mode on + monitoring enabled** — Every Dio call is recorded. Breakpoints can pause traffic before the request is sent or after the response arrives.
3. **Breakpoint hit** — You can edit headers/body, continue unchanged, or cancel the request.

---

## Breakpoints

Breakpoints can target:

- **All endpoints** or a **specific URL pattern** (substring match)
- **Request**, **response**, or **both**

Create them from the monitor screen toolbar, from a request's options menu, or from **Dev Mode Options**. When a breakpoint fires, `BreakpointEditView` opens so you can modify the payload before continuing.

Use **Pause all requests** on the monitor screen to hold every in-flight call until you tap **Resume all**.

---

## Public API


| Export                                           | Purpose                                                                               |
| ------------------------------------------------ | ------------------------------------------------------------------------------------- |
| `NetworkMonitoring`                              | Initialize the package and create the Dio interceptor                                 |
| `NetworkMonitoringConfig`                        | Dev-mode and branding configuration                                                   |
| `NetworkMonitorOverlayWrapper`                   | Shows/hides the floating overlay via `MaterialApp.builder`                            |
| `VersionTapDetector`                             | Optional secret tap gesture to unlock dev mode                                        |
| `NetworkMonitoring.instance.controller`          | `requestEnableDevMode()`, `enableDevMode()`, `disableDevMode()`, `toggleMonitoring()` |
| `NetworkMonitoringBuilder`                       | Rebuild on selected controller state changes                                          |
| `DevModeOptionsView`                             | Built-in dev settings screen                                                          |
| `NetworkMonitorChange` / `NetworkMonitorChanges` | Fine-grained rebuild subscriptions                                                    |
| `NetworkMonitoringLocalizations`                 | English / Arabic strings                                                              |

---

## Production safety

Note: This package is not intended to be used in production, But if you use it in production, make sure to take this notes into your consideration.

- Keep `validatePasswordInput` set in release builds, or gate initialization behind `kDebugMode`.
- If you want to use it in production, try to use dynamic password, so you can change the password from the server (or firebase remote config, ...).
- The overlay and monitor screens are intended for development and QA — do not expose dev mode unlock UI to end users.
- Use `requestEnableDevMode(context)` for custom unlock UI so the password dialog stays consistent with `VersionTapDetector`.
- Use `enableDevMode()` only behind `kDebugMode` or when you intentionally skip the dialog.

```dart
void main() {
  if (kDebugMode) {
    NetworkMonitoring.initialize(config: myDevConfig);
  }
  runApp(const MyApp());
}
```

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.