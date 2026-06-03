# Notes example (Android & iOS)

A minimal notes app that demonstrates the **network_monitoring** package against a **local Dart `HttpServer`** that simulates a remote API with JWT authentication.

## Features

- Login with pre-filled demo credentials (`demo` / `password`)
- Bottom navigation: notes list, add note, profile
- Notes CRUD, detail view, search, and category filter
- Profile with static avatar, user info, app name, and version
- **Dev mode**: tap the version label **6 times**, enter password `123456`, then open **Network Dev Mode** from the profile list or the developer icon on the notes screen
- All HTTP traffic goes through **Dio** with the package interceptor (enable monitoring from dev mode settings)

## Where we use `network_monitoring`

The example wires the package in six places. Every API call (login, notes CRUD, categories) goes through Dio and can be inspected once dev mode and HTTP monitoring are on.

| Location | Package API | Purpose |
| -------- | ----------- | ------- |
| [`lib/main.dart`](lib/main.dart) | `NetworkMonitoring.initialize` + `NetworkMonitoringConfig` | One-time setup: 6-tap unlock, dev password `123456`, teal brand color |
| [`lib/services/api_client.dart`](lib/services/api_client.dart) | `NetworkMonitoring.createInterceptor()` | Dio interceptor added **last** (after auth) so requests/responses are recorded with the JWT header |
| [`lib/app.dart`](lib/app.dart) | `NetworkMonitorOverlayWrapper` | Wraps the app in `MaterialApp.builder` so the floating monitor button can appear over all routes |
| [`lib/widgets/app_version_label.dart`](lib/widgets/app_version_label.dart) | `VersionTapDetector` | Wraps the version text on **login** and **profile** to unlock dev mode |
| [`lib/widgets/dev_mode_entry_tile.dart`](lib/widgets/dev_mode_entry_tile.dart) | `NetworkMonitoringBuilder` + `DevModeOptionsView` | Profile **ListTile** (visible only when dev mode is on) opens dev settings |
| [`lib/views/notes_list_view.dart`](lib/views/notes_list_view.dart) | `NetworkMonitoringBuilder` + `DevModeOptionsView` | App bar **developer icon** (same as profile entry) when dev mode is enabled |

### Typical flow

1. **Startup** — `main.dart` initializes the package; `ApiClient` registers the interceptor.
2. **Unlock dev mode** — Tap the version label on login or profile 6×, enter `123456`.
3. **Enable capture** — Open **Network Dev Mode** (profile tile or notes app bar icon) → turn on **HTTP monitoring**.
4. **Use the app** — Sign in, list/create/edit/delete notes; each call appears in the overlay (JWT visible on login and authenticated routes).

Dependency: [`pubspec.yaml`](pubspec.yaml) uses `network_monitoring` via `path: ../`.

### Source snippets

#### `pubspec.yaml`

```yaml
dependencies:
  dio: ^5.9.0
  network_monitoring:
    path: ../
```

#### `lib/main.dart` — initialize

```dart
NetworkMonitoring.initialize(
  config: NetworkMonitoringConfig(
    requiredTaps: AppConfig.devModeRequiredTaps,
    validatePasswordInput: (password) => password == AppConfig.devModePassword,
    brandColor: Colors.teal,
  ),
);

ApiClient.instance.configure();
```

#### `lib/services/api_client.dart` — Dio interceptor (add last)

```dart
void configure() {
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ),
  );
  dio.interceptors.add(NetworkMonitoring.createInterceptor());
}
```

#### `lib/app.dart` — floating overlay

```dart
MaterialApp(
  builder: (context, child) {
    return NetworkMonitorOverlayWrapper(child: child!);
  },
  home: isLoggedIn ? const MainShellView() : const LoginView(),
)
```

#### `lib/widgets/app_version_label.dart` — unlock dev mode

```dart
return VersionTapDetector(
  child: Text(
    'v$version',
    style: style ?? Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.outline,
    ),
  ),
);
```

Used on the **login** and **profile** screens.

#### `lib/widgets/dev_mode_entry_tile.dart` — profile entry

```dart
return NetworkMonitoringBuilder(
  listenTo: NetworkMonitorChanges.devMode,
  builder: (context, controller) {
    if (!controller.isDevModeEnabled) {
      return const SizedBox.shrink();
    }

    return Card(
      child: ListTile(
        title: const Text('Network Dev Mode'),
        onTap: () => DevModeOptionsView.push(context),
      ),
    );
  },
);
```

#### `lib/views/notes_list_view.dart` — app bar entry

```dart
NetworkMonitoringBuilder(
  listenTo: NetworkMonitorChanges.devMode,
  builder: (context, controller) {
    if (!controller.isDevModeEnabled) return const SizedBox.shrink();
    return IconButton(
      tooltip: 'Dev Mode',
      icon: const Icon(Icons.developer_mode),
      onPressed: () => DevModeOptionsView.push(context),
    );
  },
),
```

## Run

From this directory, with an Android emulator/device or iOS simulator/device:

```bash
flutter pub get
flutter run -d android
# or
flutter run -d ios
```

The API server starts automatically in `main()` on port **8765** (`127.0.0.1` on the device — same process as the app).

On **first launch**, `NoteSeedService` inserts **10 seed notes** (see `lib/data/note_seed_data.dart`) via the API; later launches restore notes from local cache.

## API (local server)


| Method | Path                           | Auth       |
| ------ | ------------------------------ | ---------- |
| POST   | `/api/auth/login`              | No         |
| GET    | `/api/user/me`                 | Bearer JWT |
| GET    | `/api/categories`              | Bearer JWT |
| GET    | `/api/notes?category=&search=` | Bearer JWT |
| GET    | `/api/notes/:id`               | Bearer JWT |
| POST   | `/api/notes`                   | Bearer JWT |
| PUT    | `/api/notes/:id`               | Bearer JWT |
| DELETE | `/api/notes/:id`               | Bearer JWT |


## Models

`NoteModel` and `UserModel` follow the same pattern as `.test/movie.dart`: `fromMap`, `toMap`, `fromJson`, `toJson`, and `{Name}ModelFields` constants.