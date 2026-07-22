# AGENTS.md â Al-Mahir iOS Project

> Reference guide for AI agents and contributors working on this codebase.
> Always read this document before making changes to any module.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Directory Structure](#2-directory-structure)
3. [Module Architecture](#3-module-architecture)
4. [Dependency Graph](#4-dependency-graph)
5. [Styling Paradigm â Design System](#5-styling-paradigm--design-system)
6. [Architectural Patterns](#6-architectural-patterns)
7. [Networking Layer](#7-networking-layer)
8. [Authentication Flow](#8-authentication-flow)
9. [Dependency Injection](#9-dependency-injection)
10. [Test Commands & Parameters](#10-test-commands--parameters)
11. [Deprecation Warnings](#11-deprecation-warnings)
12. [Best Practices & Conventions](#12-best-practices--conventions)

---

## 1. Project Overview

**Al-Mahir** is an Islamic educational iOS application built entirely in **SwiftUI**, targeting **iOS 16+**.
The project uses a modular **Swift Package Manager (SPM)** architecture where each feature domain lives in its
own local package under `Modules/`.

| Property | Value |
|---|---|
| Platform | iOS 16+ |
| UI Framework | SwiftUI |
| Minimum Swift Tools Version | 5.9 (6.0 for `Authentication`) |
| Dependency Manager | Swift Package Manager |
| Main Workspace | `AlMahir.xcworkspace` |

---

## 2. Directory Structure

```
iOS/
├── AlMahir/                          # Main Xcode app target
│   ├── AlMahir/
│   │   ├── Application/
│   │   │   └── AlMahirApp.swift      # App entry point (@main)
│   │   ├── Data/
│   │   │   └── Services/
│   │   │       └── Local/            # SwiftData local persistence
│   │   ├── ContentView.swift
│   │   ├── MainTabView.swift         # Root tab container
│   │   ├── Resources/                # App-level assets
│   │   ├── Info.plist
│   │   └── GoogleService-Info.plist  # Firebase/Google — do NOT commit
│   ├── AlMahirTests/
│   └── AlMahirUITests/
├── Modules/                          # Feature modules (local SPM packages)
│   ├── Common/                       # Shared design system, components, utils
│   ├── NetworkKit/                   # HTTP networking abstraction (Alamofire)
│   ├── Authentication/               # Auth feature module
│   ├── Mushaf/                       # Quran reader feature module
│   └── Search/                       # Search feature module
├── AlMahir.xcworkspace
└── AGENTS.md
```

### Module Internal Structure

Every feature module follows this internal layout:

```
Sources/<ModuleName>/
├── Domain/
│   ├── Models/         # Pure Swift models / entities
│   └── Protocols/      # Use-case and repository protocol definitions
├── Data/
│   ├── <Repo>Impl.swift          # Concrete repository implementations
│   ├── <Feature>Endpoints.swift  # APIEndpoint enum conformances
│   └── KeychainTokenStore.swift  # (Auth only)
├── Presentation/
│   ├── View/           # SwiftUI Views
│   └── ViewModel/      # @MainActor ObservableObject ViewModels
└── DI/ (Mushaf only)
    ├── DIContainer.swift
    └── Assemblies/     # Swinject Assembly types
```

---

## 3. Module Architecture

### `Common` — `Modules/Common/`

Shared library with **zero feature dependencies**. All other modules may import it.

| Sub-folder | Contents |
|---|---|
| `DesignSystem/` | `DSColor`, `DSTypography`, `DSSpacing`, `DSRadius`, `DSElevation`, `DSGradients`, `DSInteractionOpacity` |
| `Components/` | `DSTextField`, `AppButton`, `DSGoogleButton`, `CustomNavBar` |
| `Utils/` | `ImageHelper` |
| `Resources/` | Bundled fonts and assets processed via `.process("Resources")` |

### `NetworkKit` — `Modules/NetworkKit/`

Generic HTTP layer. Feature modules depend on this; it has **no knowledge of any feature**.

| File | Role |
|---|---|
| `APIEndpoint.swift` | Protocol: `baseURL`, `path`, `method`, `parameters`, `encoding`, `headers` |
| `BaseURLType.swift` | Enum with `.main` and `.ai` base URL cases |
| `NetworkService.swift` | Alamofire-backed `NetworkServiceProtocol`; returns `AnyPublisher<T, NetworkError>` |
| `AppRequestInterceptors.swift` | Alamofire `RequestInterceptor`; Bearer token injection, 401 retry |

### `Authentication` — `Modules/Authentication/`

Full auth feature: login, register, logout, Google Sign-In, forgot/reset password.

### `Mushaf` — `Modules/Mushaf/`

Quran reader; uses Swinject for DI internally and a local database for Quran data.

### `Search` — `Modules/Search/`

Search feature; depends on `Mushaf` for Quran data access.

---

## 4. Dependency Graph

```
AlMahir (app target)
├── Authentication  →  NetworkKit, Alamofire, GoogleSignIn, FirebaseAuth, FirebaseCore
├── Mushaf          →  Swinject
├── Search          →  Mushaf
└── Common          →  (no external dependencies)
```

**Rules:**
- `Common` must remain dependency-free.
- `NetworkKit` must remain feature-agnostic.
- Feature modules (`Authentication`, `Mushaf`, `Search`) must NOT import each other directly.

---

## 5. Styling Paradigm — Design System

All UI must use tokens from `Common/DesignSystem`. **Never hardcode hex strings, sizes, or system fonts.**

### Applying the Theme

```swift
NavigationStack { ... }
    .dsTheme()  // inject DSColors into environment

// Access colors anywhere:
@Environment(\.dsColors) private var dsColors
```

### Color Tokens (`DSColor` / `DSColors`)

All tokens are scheme-aware (light/dark). Use `dsColors.<token>` — never raw Color values.

| Token | Light | Dark | Use |
|---|---|---|---|
| `primary` | `#014F39` | `#B0E8D8` | Brand actions, active states |
| `onPrimary` | `#FFFFFF` | `#174F3F` | Text/icons on primary |
| `primaryContainer` | `#DAF1EA` | `#1A7F63` | Subtle primary backgrounds |
| `secondary` | `#488473` | `#C1D7D1` | Secondary actions |
| `background` | `#FAFAFA` | `#0F100F` | Screen backgrounds |
| `surface` | `#FAFAFA` | `#0F100F` | Card/sheet surfaces |
| `surfaceContainerLow` | `#F5F5F5` | `#191A1A` | Input field backgrounds |
| `textPrimary` | `#191A1A` | `#E5E6E6` | Body text |
| `textSecondary` | `#455450` | `#C8D0CE` | Labels, captions |
| `textHint` | `#949E9B` | `#788783` | Placeholder text |
| `textDisabled` | `#AFB6B4` | `#616B68` | Disabled elements |
| `error` | `#A92C23` | `#E3B8B5` | Validation errors |
| `outline` | `#6E9187` | `#8DA59E` | Input borders |
| `outlineVariant` | `#C8D0CE` | `#455450` | Subtle borders |
| `success` | `#359769` | `#BBDDCD` | Success feedback |
| `warning` | `#B17A1B` | `#E6D3B2` | Warning feedback |
| `info` | `#2C64A0` | `#B8CBE0` | Informational feedback |

### Typography (`DSTypography`)

```swift
Text("Hello").dsFont(DSTypography.bodyLarge).foregroundColor(dsColors.textPrimary)
Text(ayah).dsArabicFont(DSTypography.bodyLarge)  // AmiriQuran-Regular
```

| Category | Tokens | Sizes |
|---|---|---|
| Display | `displayLarge/Medium/Small` | 36–57pt, Regular |
| Headline | `headlineLarge/Medium/Small` | 24–32pt, SemiBold |
| Title | `titleLarge/Medium/Small` | 14–22pt, Medium |
| Body | `bodyLarge/Medium/Small` | 12–16pt, Regular |
| Label | `labelLarge/Medium/Small` | 11–14pt, Medium |
| Components | `buttonText`, `inputLabel`, `inputHint`, `inputError`, `navigationLabel`, `badgeText`… | 10–14pt |

**Fonts:** Inter (Latin) — Regular, Medium, SemiBold, Bold; AmiriQuran-Regular (Arabic/Quran).

### Spacing (`DSSpacing`)

| Token | Value | | Token | Value |
|---|---|---|---|---|
| `none` | 0 | | `md` | 16 |
| `xxs` | 2 | | `mdLg` | 20 |
| `xs` | 4 | | `lg` | 24 |
| `sm` | 8 | | `xl` | 32 |
| `smMd` | 12 | | `xl2` | 40 |

### Radius (`DSRadius`)

| Token | Value | | Token | Value |
|---|---|---|---|---|
| `none` | 0 | | `lg` | 16 |
| `xs` | 4 | | `xl` | 24 |
| `sm` | 8 | | `xl2` | 32 |
| `md` | 12 | | `full` | 9999 |

### Elevation (`DSElevation`)

```swift
SomeView().dsElevation(DSElevation.level2)  // opacity 0.10, blur 6, offsetY 2
```

Levels 0–5: opacity 0–0.16, blur 0–24pt, offsetY 0–8pt.

### Gradients (`DSGradients`)

```swift
DSGradients.primary      // #014F39 → #16B689
DSGradients.secondary    // #396055 → #7BB7A6
DSGradients.success      // #2D6C4F → #68CA9C
DSGradients.hero         // #014F39 → #174F3F → #0F100F
DSGradients.darkSurface  // #0F100F → #313534
```

### Button Styles

```swift
Button("Submit") { action() }
    .buttonStyle(DSPrimaryButtonStyle())
// press: scale 0.98 easeOut 0.15s | disabled: opacity 0.12 | shape: DSRadius.md full-width
```

### Interaction Opacities (`DSInteractionOpacity`)

| State | Opacity | | State | Opacity |
|---|---|---|---|---|
| `hover` | 0.08 | | `selected` | 0.16 |
| `pressed` | 0.12 | | `disabledContent` | 0.38 |
| `focused` | 0.12 | | `disabledBackground` | 0.12 |
| `dragged` | 0.16 | | `ripple` | 0.10 |

### Reusable Components

| Component | Module | Key Parameters |
|---|---|---|
| `DSTextField` | Common | `label`, `placeholder`, `text`, `isSecure`, `leadingIcon`, `errorMessage`, `keyboardType` |
| `AppButton` | Common | `title`, action closure |
| `DSGoogleButton` | Common | `title`, action closure |
| `CustomNavBar` | Common | `selectedTab: Binding<TabItem>` |

---

## 6. Architectural Patterns

### MVVM + Clean Architecture

```
Presentation (SwiftUI View + @MainActor ViewModel)
     ↓
Domain (Protocol + Pure Models)
     ↓
Data (Repository Impl + Endpoints + Storage)
```

**Layer rules:**
- **Views** own `@StateObject` VMs. Views contain **zero business logic**.
- **ViewModels** are `@MainActor final class: ObservableObject` — delegate to managers, expose `@Published`.
- **Repositories** implement domain protocols, map network/DB to domain models.
- **Domain models** are pure Swift structs/enums — no framework imports (Foundation OK).

### Example ViewModel

```swift
@MainActor
public final class LoginViewModel: ObservableObject {
    @Published public var email = ""
    @Published public var password = ""
    @Published public var isLoading = false
    @Published public var errorMessage: String?

    private let authManager: AuthManager
    private var cancellables = Set<AnyCancellable>()

    public init(authManager: AuthManager = .shared) {
        self.authManager = authManager
        authManager.$isLoading.assign(to: &$isLoading)
        authManager.$errorMessage.assign(to: &$errorMessage)
    }

    public func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter your email and password."
            return
        }
        authManager.login(email: email, password: password)
    }

    public func clearError() { errorMessage = nil }
}
```

### App State Machine (`AuthState`)

| State | Screen |
|---|---|
| `.bootstrapping` | Splash (book icon + ProgressView) |
| `.guest` | `LoginView()` |
| `.authenticated(AuthUser)` | `MainTabView()` |
| `.sessionExpired` | `LoginView()` + session-expired banner |

---

## 7. Networking Layer

### Defining a New Endpoint

```swift
enum ItemsEndpoints: APIEndpoint {
    case list(page: Int)
    case detail(id: String)

    var baseURL: BaseURLType { .main }
    var path: String {
        switch self {
        case .list:            return "items"
        case .detail(let id): return "items/\(id)"
        }
    }
    var method: HTTPMethod { .get }
    var parameters: Parameters? {
        switch self {
        case .list(let page): return ["page": page]
        case .detail:         return nil
        }
    }
    var encoding: ParameterEncoding { URLEncoding.default }
    var headers: HTTPHeaders? { ["Accept": "application/json"] }
}

// Usage in repository:
networkService.request(ItemsEndpoints.list(page: 1))
    .sink(receiveCompletion: handleError, receiveValue: { [weak self] items in ... })
    .store(in: &cancellables)
```

### Response Envelope

All success responses: `{ "data": { ... } }` decoded via `APISuccessResponse<T>`.
Request timeout: **30 seconds**.

### NetworkError Cases

`invalidURL` | `unauthorized(message:)` | `notFound(message:)` | `serverError(statusCode:message:)` |
`validationFailed(message:fieldErrors:)` | `noInternetConnection` | `timeout` | `decodingFailed` |
`cancelled` | `unknown(message:)`

### Token Lifecycle

| Step | Mechanism |
|---|---|
| Storage | `KeychainTokenStore` — never UserDefaults |
| Injection | `AppRequestInterceptors.adapt(...)` adds `Authorization: Bearer <token>` |
| 401 retry | Interceptor fires `onRefreshNeeded` once; `AuthManager` refreshes and retries |
| Concurrent 401s | All queued; single refresh resolves all pending callbacks |
| Refresh failure | `authState = .sessionExpired`; Keychain cleared |
| Fresh install | Keychain cleared on first launch via UserDefaults flag |

### Base URLs

| Case | URL |
|---|---|
| `.main` | `https://virtserver.swaggerhub.com/iti-ff4/AuthN-AuthZ-API/1.4.0/` |
| `.ai` | *(empty string — not configured)* |

---

## 8. Authentication Flow

```
AlMahirApp.init()
  ├─ AuthManager.configureInterceptor()   ← wires token injection & refresh
  └─ SwiftDataService.shared.setup()      ← initializes local DB

AppRootView.onAppear → authManager.silentLoginOnLaunch()
  ├─ clearKeychainIfFreshInstall()
  ├─ No token       → .guest
  └─ Has token      → GET /auth/me
       ├─ 200 OK       → .authenticated(user) → MainTabView
       └─ Failure      → POST /auth/refresh
            ├─ Success  → GET /auth/me → .authenticated
            └─ Failure  → .guest
```

| Method | Entry Point | Notes |
|---|---|---|
| Email login | `AuthManager.login(email:password:)` | Stores tokens in Keychain |
| Register | `AuthManager.register(...)` | Returns `AuthUser`; no auto-login |
| Google Sign-In | `AuthManager.googleSignIn(idToken:)` | idToken from GoogleSignIn-iOS → /auth/google |
| Forgot password | `AuthManager.forgotPassword(email:onSuccess:)` | Sends reset email |
| Reset password | `AuthManager.resetPassword(token:newPassword:confirmPassword:onSuccess:)` | Token from email |
| Logout | `AuthManager.logout()` | POST /auth/logout + clears session |

---

## 9. Dependency Injection

### Authentication — Manual DI

```swift
// Production
AuthManager.shared

// Tests — inject mocks via private init
AuthManager(repository: MockAuthRepository(), tokenStore: MockTokenStore())
```

### Mushaf — Swinject

```swift
// Resolution
DIContainer.shared.resolve(MushafViewModel.self)

// Assembly order:
// DatabaseAssembly → DataSourceAssembly → RepositoryAssembly → UseCaseAssembly → ViewModelAssembly
```

Unregistered types trigger `fatalError` at runtime — always register before resolving.

### App-Level — SwiftData

```swift
// AlMahirApp.init()
let schema = Schema([ /* PersistentModel types here */ ])
try SwiftDataService.shared.setup(schema: schema)
```

---

## 10. Test Commands & Parameters

### Xcode CLI

```bash
# Full suite
xcodebuild test \
  -workspace AlMahir.xcworkspace \
  -scheme AlMahir \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  -resultBundlePath TestResults.xcresult

# Unit tests only
xcodebuild test \
  -workspace AlMahir.xcworkspace \
  -scheme AlMahir \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  -only-testing:AlMahirTests

# UI tests only
xcodebuild test \
  -workspace AlMahir.xcworkspace \
  -scheme AlMahir \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  -only-testing:AlMahirUITests
```

### SPM Package Tests

```bash
cd Modules/Authentication && swift test
cd Modules/NetworkKit     && swift test
cd Modules/Common         && swift test
cd Modules/Mushaf         && swift test
cd Modules/Search         && swift test
```

### Test Target Locations

| Target | Path |
|---|---|
| `AlMahirTests` | `AlMahir/AlMahirTests/AlMahirTests.swift` |
| `AuthenticationTests` | `Modules/Authentication/Tests/AuthenticationTests/` |
| `NetworkKitTests` | `Modules/NetworkKit/Tests/` |
| `CommonTests` | `Modules/Common/Tests/` |
| `MushafTests` | `Modules/Mushaf/Tests/` |
| `SearchTests` | `Modules/Search/Tests/` |

### Testing Patterns

- **`AuthManager`:** inject `AuthRepositoryProtocol` & `TokenStoring` mocks via `private init`.
- **`NetworkService`:** inject custom Alamofire `Session` backed by a mock `URLProtocol`.
- **`@MainActor` VMs:** wrap assertions in `await MainActor.run { }` or `XCTestExpectation`.
- **Combine:** use `XCTestExpectation` + `waitForExpectations(timeout:)` or `async let`.

---

## 11. Deprecation Warnings

### WARNING: `BaseURLType.ai` Returns Empty String

**File:** `Modules/NetworkKit/Sources/NetworkKit/Core/BaseURLType.swift`
```swift
case .ai: return ""  // produces NetworkError.invalidURL at runtime
```
**Action:** Configure the AI service URL before shipping any AI feature.

---

### WARNING: Home, Bookmarks, Profile Tabs Are Stubs

**File:** `AlMahir/AlMahir/MainTabView.swift`

Three tabs render `Text("...")` placeholders. Replace with real views before release.

---

### WARNING: Commented-Out Debug Root Views

**File:** `AlMahir/AlMahir/Application/AlMahirApp.swift`
```swift
// MushafRootView()
// SearchView()
// MainTabView()
```
**Action:** Remove before merging to main or any release branch.

---

### WARNING: Google Sign-In Button Has Empty Action

**File:** `Modules/Authentication/Sources/Authentication/Presentation/View/LoginView.swift`
```swift
DSGoogleButton(title: "Log in with Google") { }  // empty closure
```
**Action:** Wire `googleViewModel.signIn(presenting:)` to the button.

---

### WARNING: `@unchecked Sendable` on Networking Classes

**Files:** `NetworkService.swift`, `AppRequestInterceptors.swift`

Opted out of Sendable checking. Audit and replace with `actor` or proper `Sendable` before
enabling Swift 6 strict concurrency.

---

### WARNING: SwiftData Schema Is Empty

**File:** `AlMahir/AlMahir/Application/AlMahirApp.swift`
```swift
let schema = Schema([])  // no PersistentModel types
```
**Action:** Register all local persistence models as they are added.

---

## 12. Best Practices & Conventions

### Naming

| Element | Rule | Example |
|---|---|---|
| SwiftUI Views | `PascalCase` + `View` | `LoginView`, `MushafRootView` |
| ViewModels | `PascalCase` + `ViewModel` | `LoginViewModel` |
| Protocols | Noun or `-ing/-Protocol` | `AuthRepositoryProtocol`, `TokenStoring` |
| Endpoint enums | `PascalCase` + `Endpoints` | `AuthEndpoints` |
| DS types | `DS` prefix | `DSColor`, `DSSpacing` |
| Swinject assemblies | `PascalCase` + `Assembly` | `RepositoryAssembly` |

### File Organization

One primary type per file. Use `// MARK: -` in this order:
```
Init → Published State → Dependencies → Lifecycle → Actions → Private Helpers
```

### SwiftUI View Rules

- Views are **pure presenters** — no network calls, no persistence reads.
- `@StateObject` for owned VMs; `@ObservedObject` for injected VMs.
- `.dsTheme()` at the root `NavigationStack` only.
- All padding/spacing uses `DSSpacing` — never literal integers.
- Animations: `.easeInOut`/`.easeOut`, 0.15s–0.25s duration.
- Appearing elements: `.transition(.opacity.combined(with: .move(edge: .top)))`.

### Combine & Concurrency

- All pipelines end with `.store(in: &cancellables)`.
- Always `[weak self]` in `sink` closures.
- `@MainActor` on the **class**, not individual methods.
- Combine for existing flows; `async/await` allowed for new isolated operations (bridge to `@MainActor`).

### Security

- Never commit `GoogleService-Info.plist` or API keys.
- Tokens in **Keychain only** — never `UserDefaults`.
- Keychain cleared on fresh install (`AuthManager.clearKeychainIfFreshInstall()`).
- Token injection via `AppRequestInterceptors` — not hardcoded in endpoint headers.

### Adding a New Feature Module

1. `mkdir Modules/MyFeature && cd Modules/MyFeature && swift package init --type library`
2. Set `platforms: [.iOS(.v16)]` and `swift-tools-version: 5.9`.
3. Add to `AlMahir.xcworkspace` and app target Frameworks.
4. Create `Domain/`, `Data/`, `Presentation/` under `Sources/MyFeature/`.
5. Import `Common` for DS; import `NetworkKit` for network.
6. Add `testTarget` in `Package.swift`.
7. Update Sections 3 and 4 of this `AGENTS.md`.

### Code Review Checklist

- [ ] No raw hex colors or hardcoded points in View code
- [ ] `.dsTheme()` at all `NavigationStack` roots
- [ ] `@MainActor` at the ViewModel class level
- [ ] `[weak self]` in all `sink` closures
- [ ] Domain models have no framework imports (Foundation OK)
- [ ] New endpoints in a dedicated `*Endpoints.swift` conforming to `APIEndpoint`
- [ ] Token storage via `KeychainTokenStore` only
- [ ] No commented-out debug root views in `AlMahirApp.swift`
- [ ] Unit tests for new repository/use-case logic
- [ ] `BaseURLType.ai` not used until configured
