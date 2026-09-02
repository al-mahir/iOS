# AGENTS.md — Al-Mahir iOS Project

> Ground-truth guide for agents and contributors working in this repository.
> Read this file before changing the app or any local package. This inventory was
> reconciled against the source tree, package manifests, Xcode project, resources,
> and tests on 2026-09-01.

## 1. Project at a glance

Al-Mahir is a modular Islamic education app centered on Quran reading, listening,
recitation feedback, study, community circles, and private sessions with sheikhs.

| Property | Current value |
|---|---|
| App UI | SwiftUI |
| App deployment target | iOS 17.2 |
| Local package platform | Usually iOS 17; selected infrastructure packages also declare macOS 13 |
| Swift language / tools | Swift 5.9 |
| Dependency manager | Swift Package Manager |
| Main workspace | `AlMahir.xcworkspace` |
| App scheme | `AlMahir` |
| App architecture | Modular Clean Architecture-style layers with MVVM presentation |
| Reactive models | Combine plus Swift concurrency (`Task`, `async/await`, `AsyncStream`) |
| Local packages | 23 directories under `Modules/`; `Reading` is currently an empty, unintegrated scaffold |

The app is not an iOS 16 project. Do not lower package or app deployment targets
without validating every API and dependency.

## 2. Repository layout

```text
iOS/
├── AlMahir/
│   ├── AlMahir.xcodeproj/
│   ├── AlMahir/
│   │   ├── Application/
│   │   │   ├── AlMahirApp.swift
│   │   │   ├── AppDIContainer.swift
│   │   │   └── SearchIndexAyahTextProvider.swift
│   │   ├── Configuration/
│   │   │   ├── Secrets.example.xcconfig
│   │   │   └── Secrets.xcconfig          # local and gitignored
│   │   ├── Resources/
│   │   ├── MainTabView.swift
│   │   ├── SplashScreenView.swift
│   │   ├── ContentView.swift             # unused template placeholder
│   │   └── Info.plist
│   ├── AlMahirTests/
│   └── AlMahirUITests/
├── Modules/                              # local SPM libraries
├── AlMahir.xcworkspace
├── build_search_index.py
└── AGENTS.md
```

Most feature packages use some variation of:

```text
Sources/<Module>/
├── Domain/          # entities, repository protocols, use cases
├── Data/            # DTOs, mappers, data sources, repositories, endpoints
├── Presentation/    # SwiftUI views, view models, routing
├── DI/              # Swinject assemblies or a feature container, when needed
└── Resources/       # string catalogs, assets, databases, or fonts
```

Folder spelling is not fully standardized (`Presentation`, `Presentaion`,
`Presention`, `DataSource`, `DataSourse`, `ViewModel`, and `View Model` all exist).
Follow the local module layout for small edits; use the canonical spelling for new
folders and migrate old paths only as a deliberate refactor.

## 3. User-facing feature inventory

| Area | Implemented capability | Main code |
|---|---|---|
| App shell | Splash, silent authentication bootstrap, session-expired state, three-tab navigation (Home, Bookmarks, Profile), global audio mini-player | `AlMahirApp.swift`, `MainTabView.swift` |
| Authentication | Email login/register/logout, Google Sign-In, email verification, OTP verification, password change/reset flow, Keychain token storage, refresh and silent login | `Authentication` |
| Home dashboard | User greeting, last-read resume, Quran test entry, sheikh previews, public/private circle entry, ayah of the day, search and notification entry | `Home` |
| Mushaf reader | 604-page Quran layout, plain and tajweed font sets, page/juz/surah navigation, target-ayah navigation, reading progress, bookmarks, mode selector | `Mushaf` |
| Mushaf modes | Reading, synchronized listening, AI recitation correction, teacher/repeat-after-reciter flow, and tajweed-rule legend | `Mushaf`, `Listening`, `Taahud`, `Mualem`, `Tafsir` |
| Quran search | Local full-text word/ayah search, surah and juz filters, search history, voice input, Tafsir search/detail, navigation to the matching Mushaf page | `Search` |
| Listening | Quran.com reciters/audio/timestamps, AVPlayer playback, word-level highlighting, reciter/surah selection, per-user downloads, global mini-player, background audio | `Listening` |
| Bookmarks | SwiftData-backed page, ayah, surah, and sheikh bookmarks; search and navigation back to Mushaf/Sheikh detail | `Bookmarks`, `LocalDataKit` |
| Tafsir | Available Tafsir list, remote download, local storage, deletion, per-ayah lookup, management UI, offline reading | `Tafsir` |
| AI recitation correction | Microphone PCM capture, authenticated native WebSocket session, word feedback/highlighting, seek/start/stop, mistake detail UI | `Taahud` |
| Mu'allim | Reciter playback followed by user recording, configurable strictness/rules, live AI feedback, mistake summary; falls back to mock AI when the service is unavailable | `Mualem` |
| Quran test | Test by juz, surah range, or ayah range; speech recognition, generated questions, word feedback, score/result screen, in-memory test history | `Test`, presented by `Home` |
| Circles | Browse public circles, create/edit/cancel/start/end circles, private invite codes, join/leave, host approval queue, member management, realtime membership events | `Circles` |
| Live calls | Agora audio/video rooms, participant state, mute/video controls, leave/end, token renewal, STOMP participant/session events | `AgoraKit`, `LiveSessionKit` |
| Sheikhs | Sheikh discovery, search/filter, profiles, audio samples, favorites, packages/reviews, availability, instant meeting requests, approval wait state, meeting history and live call launch | `Sheikh` |
| Payments/subscriptions | Wallet/card selection and validation, backend payment intentions, Paymob checkout WebView, result states, local subscription store | `Payment` |
| Profile | Account page, activity/streak/achievement/stat views, subscriptions, privacy policy, terms, social links, routing to Settings and payment flows | `Profile` |
| Settings | Theme, language, tajweed preference, audio-download management, Tafsir management, subscription plans, session history entry, logout | `Settings` |
| Notifications | Notification list, unread count, create/read/read-all/delete APIs and UI | `Notification` |
| Localization | System/English/Arabic selection with LTR/RTL switching and package string catalogs | `Common` plus each package's `Localizable.xcstrings` |

### Current implementation status that affects product behavior

- `Home`, `Bookmarks`, and `Profile` are real tab implementations; they are not stubs.
- `NotificationRepository` defaults to an in-memory mock source, whose sample list is
  currently empty. Network endpoints exist but are not the default wiring.
- Profile statistics are provided by `MockProfileStatsRepository`.
- Home greeting and the older active-circle adapter use mock methods; displayed
  sheikhs and the current circle lists use their feature repositories.
- Payment DI defaults to remote data sources, but remote card/wallet failures can
  currently synthesize successful fallback responses. Never treat that behavior as
  production-safe payment confirmation.
- `Mualem` tries the configured AI service and falls back to mock session/config data.
  The simulator also uses `MockVoiceEvaluationService` for the legacy evaluator.
- Test history is memory-only and is lost when the process exits.
- `Modules/Reading` and `ContentView.swift` are unused template scaffolds.

## 4. Local package catalog and dependency graph

Dependencies below are direct manifest dependencies, not every transitive import.

| Package | Responsibility | Direct dependencies |
|---|---|---|
| `AgoraKit` | Agora RTC wrapper, permissions, session and video view | Agora RTC |
| `Authentication` | Authentication state, endpoints, Keychain, auth UI | `Common`, `NetworkKit`, Alamofire, GoogleSignIn |
| `Bookmarks` | SwiftData bookmark models, DAOs, use cases and UI | `Common`, `Authentication`, `LocalDataKit`, Swinject |
| `Circles` | Circle REST/realtime flows and UI | `Common`, `NetworkKit`, `RealtimeKit`, `LiveSessionKit` |
| `Common` | Design system, shared UI, localization/theme/session state, Quran SQLite helpers, shared speech/phonetic utilities | No package dependency |
| `Home` | Dashboard composition and feature entry points | `Common`, `Authentication`, `NetworkKit`, `Mushaf`, `Sheikh`, `Search`, `Circles`, `Notification`, `Test` |
| `Listening` | Reciters, audio playback, timings, downloads | `Common`, `NetworkKit`, Swinject |
| `LiveSessionKit` | Agora plus REST/STOMP live-session orchestration | `AgoraKit`, `RealtimeKit`, `NetworkKit`, `Common` |
| `LocalDataKit` | Shared SwiftData container/service | No package dependency |
| `Mualem` | Teacher/repeat recitation experience and AI gateway | `Common`, `Mushaf`, Swinject |
| `Mushaf` | Quran reader and mode integration | `Common`, `Bookmarks`, `Listening`, `Tafsir`, `Taahud`, Swinject, SwiftUI-Tooltip |
| `NetworkKit` | Generic HTTP endpoints, multipart requests, errors and auth interceptor | Alamofire |
| `Notification` | Notification domain/data/UI | `Authentication` |
| `Payment` | Wallet/card payment flow and Paymob UI | `Common`, `NetworkKit`, Swinject |
| `Profile` | Account, stats, subscriptions and profile routing | `Settings`, `Common`, `Payment`, Swinject |
| `Reading` | Empty Swift package scaffold; not integrated into the workspace/app | None |
| `RealtimeKit` | STOMP client abstraction and subscription registry | SwiftStomp |
| `Search` | Local Quran search and remote Tafsir detail | `Mushaf`, `NetworkKit` |
| `Settings` | Preferences and management screens | `Common`, `Listening`, `Tafsir`, `Payment`, `Sheikh` |
| `Sheikh` | Sheikh discovery, favorites, packages and instant meetings | `NetworkKit`, `Common`, `Bookmarks`, `RealtimeKit`, `LiveSessionKit`, `Payment`, Swinject |
| `Taahud` | Native WebSocket recitation engine integration | No package dependency; uses Apple frameworks directly |
| `Tafsir` | Tafsir download/cache/query and UI | `NetworkKit`, `Common` |
| `Test` | Speech-driven Quran assessment flow | `Common`, GoogleSignIn |

High-level runtime graph:

```text
AlMahir app
├── Authentication ── NetworkKit ── Alamofire
├── Home
│   ├── Search ── Mushaf
│   ├── Circles ── RealtimeKit ── SwiftStomp
│   │              └─ LiveSessionKit ── AgoraKit ── Agora RTC
│   ├── Sheikh ────────────────┘
│   ├── Notification
│   └── Test
├── Bookmarks ── LocalDataKit ── SwiftData
├── Profile ── Settings ── Listening / Tafsir / Payment / Sheikh
└── Mualem (composed with Listening and the app's Quran text provider)
```

Dependency rules:

- `NetworkKit` must remain feature-agnostic.
- `Common` currently has no package dependencies. Keep it cycle-free and do not
  move feature-specific business flows into it, even though it already contains
  shared Quran database and speech helpers.
- Feature-to-feature dependencies are an established part of this codebase. Do not
  apply the old rule that prohibited them. Add a new edge only when composition or
  a shared domain contract genuinely requires it, and check for cycles first.
- Declare every imported package directly in `Package.swift`. Some existing targets
  rely on transitive visibility (for example `Notification` imports `NetworkKit`,
  and `Search` imports `Common`); do not repeat that dependency-hygiene issue.
- Prefer infrastructure packages (`NetworkKit`, `LocalDataKit`, `RealtimeKit`,
  `AgoraKit`) over duplicating adapters inside features.

## 5. Technology stack

### Apple frameworks

| Technology | Use |
|---|---|
| SwiftUI | All app and package UI |
| Combine | Network publishers, observable state and cross-feature event streams |
| Swift concurrency | Async repositories, WebSocket streams, task cancellation and actor isolation |
| SwiftData | Page, ayah, surah and sheikh bookmarks |
| SQLite3 | Bundled Quran page/layout/search databases |
| AVFoundation / AVFAudio | Playback, background audio, recording, PCM conversion, microphone permissions |
| Speech | Voice search, Quran tests and legacy/local recitation evaluation |
| Security | Access/refresh token Keychain storage |
| WebKit | Paymob checkout via `WKWebView` |
| UIKit | View-controller lookup, app settings navigation and representable bridges |
| Foundation URLSession | Downloads and native WebSocket clients |
| MediaPlayer | Audio/remote playback integration |

### Direct third-party packages

Versions are the currently resolved workspace versions.

| Dependency | Version | Use |
|---|---:|---|
| Alamofire | 5.10.2 | HTTP transport and request interception |
| GoogleSignIn-iOS | 8.0.0 | Google authentication |
| Swinject | 2.9.1 | Feature and app dependency injection |
| AgoraRtcEngine_iOS | 4.6.2 | Live audio/video calls |
| SwiftStomp | 1.2.1 | STOMP-over-WebSocket transport |
| SwiftUI-Tooltip | 1.4.0 | Mushaf onboarding/tooltips |

Do not add a dependency when an existing framework or package already provides the
needed capability.

## 6. Architecture and state ownership

The repository's primary structure is Clean Architecture-style layering, with MVVM
for SwiftUI presentation and reactive/asynchronous adapters at the data boundary:

```text
SwiftUI View
    ↓ user intent / rendered state
ObservableObject ViewModel
    ↓
Use case or domain protocol
    ↓
Repository protocol
    ↓
Repository implementation → REST / STOMP / WebSocket / SQLite / SwiftData / AVFoundation
```

Expected boundaries for new code:

- Views render state and forward intent. Keep networking, persistence and domain
  decisions out of `body`.
- View models own presentation state and effects. New UI-mutating view models should
  be `@MainActor`; several older view models are not yet consistently isolated.
- Domain entities must not depend on SwiftUI, UIKit, Alamofire, SwiftData or transport
  DTOs. Foundation types are acceptable when they are truly domain values.
- Repository protocols belong at the domain boundary. Data implementations map DTOs
  or persistence entities into domain models.
- Cancel or replace stale `Task`s and subscriptions for searches, pagination, audio
  sessions and realtime flows.
- Existing code mixes Combine with async/await. Preserve the local public API unless
  the task explicitly includes a migration; bridge at repository/use-case boundaries.

Navigation is mostly SwiftUI state-driven:

- `AppRootView` switches on `AuthState`.
- `MainTabView` owns Home/Bookmarks/Profile selection and full-screen cross-feature
  destinations.
- `HomeView` owns a `NavigationStack` into Search, Mushaf, Test, Sheikh, Circles and
  Notifications.
- Profile uses `ProfileRouter`, `ProfileRoute` and `ProfileCoordinatorView`.
- `TabBarVisibility` coordinates nested full-screen flows.

## 7. Dependency injection and composition

There is no single DI style:

- `AppDIContainer` is a Swinject composition root for `ProfileAssembly`,
  `MuallimAssembly` and `ListeningAssembly`. It also adapts Listening playback and
  the app-bundled search database to Mualem protocols.
- Mushaf, Search, Home, Sheikh, Payment, Listening, Bookmarks and Test have feature
  containers/assemblies.
- Authentication uses the `AuthManager.shared` composition path with constructor
  injection internally.
- Notification uses a small manual singleton container.
- Taahud builds dependencies through `TaahudDependencyContainer` factories.
- Circles constructs several live dependencies through default initializers.

Many `resolve` helpers use `fatalError` or force unwraps. Register a type before
resolving it, preserve assembly ordering, and test any changed composition root.
Prefer constructor injection for new domain and view-model code even when a container
creates the final object.

## 8. Networking, authentication and realtime

### HTTP layer

`APIEndpoint` defines:

- `baseURL`, `path`, `method`, `parameters`, `encoding`, `headers`
- optional `multipartBody`
- `requiresAuthentication` (defaults to `true`)

`NetworkService` uses Alamofire with a 30-second request timeout. It supports JSON,
direct/external decoding, multipart uploads and requests with no response body.
Normal requests first decode `APISuccessResponse<T>` (`{ "data": ... }`) and then
fall back to decoding `T` directly.

`NetworkError` cases are `invalidURL`, `noInternetConnection`, `decodingFailed`,
`timeout`, `cancelled`, `unauthorized`, `notFound`, `validationFailed`, `serverError`
and `unknown`.

Base URL cases:

| Case | Source/use |
|---|---|
| `.main`, `.almahir` | Production Al-Mahir Railway API under `/api/` |
| `.quranCom` | Quran.com API v4 |
| `.socketUrl` | Production Al-Mahir STOMP WebSocket endpoint |
| `.ai` | `AI_BASE_URL` from Info.plist/xcconfig; empty when missing |

Never add authorization headers manually to normal protected endpoints. Set
`requiresAuthentication = false` only for genuinely public routes.

### Authentication lifecycle

```text
AlMahirApp.init
├── configure Alamofire token interceptor
├── configure SwiftData bookmark schema
└── register Quran fonts

AppRootView.onAppear
└── silentLoginOnLaunch
    ├── first install: clear stale Keychain tokens
    ├── no token: guest
    ├── cached user: show authenticated UI while validating GET auth/me
    └── unauthorized: refresh token → fetch current user → authenticated
```

- Access and refresh tokens live in Keychain.
- Cached non-secret user/session metadata and first-launch state use UserDefaults.
- The interceptor adds Bearer tokens and retries one 401/403 after a single queued
  refresh operation.
- Refresh failure clears the session and can show the session-expired login banner.
- Google Sign-In sends the Google ID token directly to `auth/user/google`; Firebase
  is not used.
- Password recovery is verify-email → verify-OTP → change-password, keyed by email.

### Realtime and media

- `RealtimeKit` wraps SwiftStomp and owns connection state, decoding, subscriptions
  and reconnect behavior for circle/meeting topics.
- `AgoraKit` wraps Agora RTC, camera/microphone permission checks, channel lifecycle,
  remote users and a SwiftUI video view.
- `LiveSessionKit` coordinates REST state, STOMP presence/events and Agora token
  renewal. Subscribe before joining a channel so events are not missed.
- `Taahud` and `Mualem` use native `URLSessionWebSocketTask` protocols for AI audio
  streaming rather than STOMP.
- Listening uses `AVPlayer`; recording flows use `AVAudioEngine` and convert audio to
  the AI service's expected mono PCM format.

## 9. Persistence, resources, theme and localization

### Persistence

| Store | Data |
|---|---|
| Keychain | Access and refresh tokens |
| SwiftData | Four bookmark model types registered in `AlMahirApp` |
| SQLite | Quran layout, imlaei text and search index |
| File system | Downloaded recitation audio and downloaded Tafsir data |
| UserDefaults | Theme/language, cached user metadata, reading progress, download metadata and feature preferences |
| In memory | Current test history, mock notification storage, `SubscriptionStore` |

User-scoped persisted data must use a stable user ID and respond to
`.userSessionDidChange`; do not leak one user's downloads, progress or bookmarks into
another session.

### Bundled Quran resources

The app target contains:

- `qpc-v4.db`, `qpc-v4-tajweed-15-lines.db`, `imlaei-simple.db`, `search-index.db`
- 604 page fonts in `V4Fonts.bundle` and 604 in `V4FontsPlain.bundle`
- Inter Regular/Medium/SemiBold/Bold and AmiriQuran-Regular

Database schema/column or word-key changes affect Mushaf, Search, Test, Taahud,
Mualem and Common. Treat them as cross-feature migrations.

### Design system

UI should use `Common/DesignSystem` and shared components:

- `DSColor`/`DSColors` through `@Environment(\.dsColors)` and `.dsTheme()`
- `DSTypography` and `.dsFont`/`.dsArabicFont`
- `DSSpacing`, `DSRadius`, `DSElevation`, `DSGradients`
- `DSInteractionOpacity` and shared button styles
- `DSTextField`, `DSDropdownField`, `AppButton`, `DSGoogleButton`, Quran cards,
  `CustomNavBar`, and tooltip components

Do not introduce raw hex colors, arbitrary spacing/radius constants or unregistered
fonts in new UI. Existing violations are migration debt, not precedent.

### Localization and accessibility direction

- User-selectable languages are System, English and Arabic.
- `LanguageManager` injects locale and LTR/RTL direction at the app root.
- Use package-aware `String(localized:bundle:)`, `Text(_:bundle:)` or
  `LocalizedStringResource`; do not assume `Bundle.main` inside SPM modules.
- Add new strings to the owning module's string catalog and verify both directions.

## 10. Configuration and security

Local configuration lives in gitignored
`AlMahir/AlMahir/Configuration/Secrets.xcconfig`. Start from
`Secrets.example.xcconfig` and provide:

```text
AGORA_APP_ID
AI_BASE_URL
AI_BEARER_TOKEN
```

These values are surfaced through Info.plist. Do not commit the real xcconfig or
copy credentials into Swift, tests, logs, documentation or sample resources.

Security-critical current debt:

- `TaahudDependencyContainer.swift` contains a hardcoded temporary AI service URL
  and credential. Move both to the shared secret/configuration path before release;
  never duplicate or expose the credential while editing documentation or logs.
- Payment remote data sources currently convert some backend failures/status lookup
  failures into simulated success. Production payment state must come from a trusted
  server/webhook status.
- `NetworkService` prints raw success and error bodies. Remove or redact these logs
  for production because authentication/user payloads may be sensitive.
- Multiple network/realtime classes use `@unchecked Sendable`; audit synchronization
  before enabling Swift 6 strict concurrency.
- Camera, microphone and speech permissions are declared. Keep purpose strings in
  sync with actual use and request permissions only at the point of use.

## 11. Build and test commands

The full app requires full Xcode, not only Command Line Tools. The current execution
environment may need `xcode-select` pointed to an Xcode installation before these
commands work.

```bash
# Discover available simulators first
xcrun simctl list devices available

# Full app suite (replace destination with an installed simulator)
xcodebuild test \
  -workspace AlMahir.xcworkspace \
  -scheme AlMahir \
  -destination 'platform=iOS Simulator,name=<installed device>,OS=latest' \
  -resultBundlePath TestResults.xcresult

# App unit tests only
xcodebuild test \
  -workspace AlMahir.xcworkspace \
  -scheme AlMahir \
  -destination 'platform=iOS Simulator,name=<installed device>,OS=latest' \
  -only-testing:AlMahirTests

# App UI tests only
xcodebuild test \
  -workspace AlMahir.xcworkspace \
  -scheme AlMahir \
  -destination 'platform=iOS Simulator,name=<installed device>,OS=latest' \
  -only-testing:AlMahirUITests

# One package (many iOS-only packages may still need xcodebuild/Xcode)
cd Modules/<Package>
swift test
```

Every local package declares a test target. Current substantive coverage is strongest
in `Circles`, `Sheikh`, `LiveSessionKit` and `RealtimeKit`, with focused tests in
`Authentication`, `Listening` and `Mushaf`. Most other package test files and the app
unit/UI suites are still template placeholders. Do not report the repository as
fully covered merely because all test targets exist.

Testing expectations for new behavior:

- Repositories: success, mapping, transport/persistence error and cancellation.
- View models: loading/success/failure plus stale-task cancellation where relevant.
- Endpoints: path, method, authentication and request encoding.
- Realtime/media: injected protocol fakes; never require live Agora, STOMP, AI or
  payment services in unit tests.
- SwiftData: isolated in-memory containers.
- `@MainActor` types: actor-aware XCTest methods/assertions.
- Combine: deterministic expectations or controllable publishers, never sleeps.

## 12. Known gaps and release blockers

- `Reading` is an empty package and is not integrated.
- `ContentView.swift` is the unused "Hello, world!" template.
- Notifications are mock-backed by default and currently show no seeded data.
- Profile statistics are mock-backed; backend subscriptions are not yet merged.
- Several Settings actions only print intended navigation/actions.
- Test history and subscription state are not durable backend-backed records.
- AI features require valid local configuration; `.ai` resolves to an empty URL when
  `AI_BASE_URL` is missing.
- Taahud's temporary endpoint/credential must be removed from source.
- Payment fallback success behavior must be removed before real-money release.
- Raw network response logging must be disabled/redacted for production.
- Some targets rely on undeclared transitive imports.
- Concurrency isolation is mixed and `@unchecked Sendable` is widespread.
- `LiveSessionKit` and `Sheikh` declare macOS 13 while parts of the downstream media
  stack are iOS-oriented; validate manifests before claiming macOS support.
- Many test targets contain only generated placeholder tests.

## 13. Contribution conventions

### Before editing

1. Read the owning package's `Package.swift`, public root view/API, DI container and
   nearby tests.
2. Trace cross-feature consumers before changing public models, database schemas,
   notification names, word keys or navigation callbacks.
3. Check `git status` and preserve unrelated user changes.

### Code conventions

- One primary type per file when practical.
- Types use `PascalCase`; methods/properties use `camelCase`.
- Views end in `View`, observable presentation types in `ViewModel`, endpoints in
  `Endpoint`/`Endpoints`, and Swinject registrations in `Assembly`.
- Mark new UI state owners `@MainActor`; use `[weak self]` in escaping Combine
  closures where ownership is not intentionally retained.
- End Combine pipelines with `.store(in: &cancellables)`.
- Prefer explicit state enums/structs over incompatible Boolean combinations.
- Avoid new global singletons. Inject protocols and compose live instances in the
  nearest feature/app container.
- Keep DTOs and persistence entities out of views and domain APIs.
- Do not force unwrap resolved dependencies in new code when a typed factory can make
  invalid composition unrepresentable.
- Use existing shared user-session notifications rather than inventing stringly typed
  duplicates.
- Preserve exact product spelling in code. The package is `Mualem`, while existing
  public/internal types mix `Muallim` and `Muallem`; do not add a fourth spelling.

### UI checklist

- Use design tokens and shared components.
- Add localized English and Arabic copy to the owning bundle.
- Verify RTL layout, Dynamic Type, VoiceOver labels and sufficient contrast.
- Keep tab-bar visibility and nested navigation restoration correct.
- Provide loading, empty, error, offline and permission-denied states.

### Data/security checklist

- No secrets or tokens in source, fixtures, logs or documentation.
- Auth tokens use Keychain only.
- User-scoped local data is partitioned and cleared/switched on session changes.
- New protected endpoints use the shared interceptor.
- Payment success is server-authoritative.
- Realtime subscriptions are cancelled and media sessions released on exit.

### Definition of done

- The changed target builds with its declared platform.
- Relevant unit tests cover the new behavior and pass.
- Cross-feature entry points still navigate correctly.
- New resources are declared in the package/app target.
- No new warnings, placeholder implementation, raw response logging, mock production
  default or undeclared transitive dependency is introduced.
- Update this file whenever a feature, package, dependency, platform target,
  configuration key or major integration changes.
