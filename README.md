# mobile_meal_planner

<<<<<<< Updated upstream
A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
=======
Mobile programming assignment

flutter emulators --launch Medium_Phone_API_37.0

---

# Data Layer & Architecture Plan (plan phase)

This is the single planning doc for the data layer. Scope: how the app will support
the six data functions — **fetch recipes from an API, search recipes, toggle
favourites, persist favourites on the device, show recipes offline, and handle
loading/error states** — on top of the existing View → ViewModel → Repository
skeleton (see `docs/07-tech-summary.md`).

Status: plan only — no dependencies added, no code changed yet. The new packages in
§6 are **approved** (§8) and get added to `pubspec.yaml` when implementation starts.

## 1. Application layers

We keep the MVVM-ish layering already in the repo and add the missing **data source**
layer underneath the repositories:

```
Presentation (View)          lib/features/*/presentation/   screens + widgets
  │  state down via constructors/ListenableBuilder, actions up via callbacks
  ▼
ViewModel (ChangeNotifier)   HomeViewModel, SearchViewModel, FavoritesViewModel
  │  owns UI state (loading/success/error/empty), never touches HTTP or disk
  ▼
Repository (abstract)        RecipeRepository, FavoritesRepository
  │  single data-access point per feature; decides remote vs local (cache-aside)
  ▼
Data sources                 API data source · cache data source · local prefs data source
                               (HTTP, JSON file, SharedPreferences)
```

| Layer | Responsibility | Must NOT know about |
|---|---|---|
| View | Render state, forward user actions (`onTap`, `onSearch`) | where data comes from, HTTP, files |
| ViewModel | UI state + transitions, call repositories, `notifyListeners()` | HTTP details, file paths, JSON keys |
| Repository | Orchestrate sources: try remote → write cache → on failure read cache; expose `Future`s | widget classes, `BuildContext` |
| Data source | One technology each: `http`, `dart:io` + `path_provider`, `shared_preferences` | business rules, other sources |

Why: every layer is replaceable — mock ↔ API ↔ cache swap happens inside the
repository without touching a single widget, which is exactly the property the
course demo checks ("data arrives via constructor, source can change").

## 2. Main components (planned files)

```
lib/
├── main.dart                              # composition root: builds sources → repos → VMs
├── core/
│   ├── error/failures.dart                # NetworkException, CacheMissException, ParseException
│   └── network/api_client.dart            # thin wrapper over http: get(), timeout, maps status codes
└── features/
    ├── recipes/
    │   ├── models/recipe.dart             # + Recipe.fromJson / toJson (API & cache serialization)
    │   └── data/
    │       ├── recipe_repository.dart     # abstract stays; add CachedRecipeRepository (cache-aside)
    │       ├── recipe_api_data_source.dart        # TheMealDB: list + search endpoints
    │       └── recipe_cache_data_source.dart     # read/write recipes_cache.json
    ├── favorites/
    │   ├── data/
    │   │   ├── favorites_repository.dart         # abstract: getFavoriteIds(), toggleFavorite(id)
    │   │   └── favorites_local_data_source.dart  # SharedPreferences: favorite_recipe_ids
    │   └── presentation/favorites_view_model.dart
    └── search/
        └── presentation/search_view_model.dart   # debounced query, own status enum
```

Existing pieces that change (minimal diffs):

- `Recipe` gains `fromJson`/`toJson` — one serialization point used by both the API
  source and the cache, so the two can never drift apart.
- `FavoriteButton` becomes **controlled**: `isFavorite` in, `onTap` out (data down,
  callbacks up). Once `FavoritesViewModel` exists, the heart state lives in the VM
  so card + details screen stay in sync.
- `HomeViewModel` gains an `isFromCache`/`isStale` flag next to `HomeStatus` so the
  UI can show an "offline — showing saved recipes" banner instead of pretending the
  data is fresh.
- `main.dart` wires it all in the composition root (already the pattern there).

## 3. Data sources & cache locations

| Source | Technology | Physical location | Stores | Lifecycle |
|---|---|---|---|---|
| Remote API | `http` package | network — **TheMealDB** (decided, §8) | recipes JSON (list + search) | fetched per request |
| Recipe cache | JSON file via `path_provider` | `getApplicationDocumentsDirectory()/cache/recipes_cache.json` | `{ savedAt: <epoch ms>, recipes: [...] }` | survives restarts; cleared on uninstall; TTL 24 h |
| Favourites | `shared_preferences` | Android: private XML prefs in app data dir · iOS: `NSUserDefaults` | key `favorite_recipe_ids` → `List<String>` of recipe IDs | survives restarts & OS cache clears; cleared on uninstall |

Why `getApplicationDocumentsDirectory()` and not the temp dir for the cache: the OS
may wipe `getTemporaryDirectory()` at any time, which would silently break the
"works without internet" requirement; the documents dir is app-private and stable.

Why favourites store **IDs, not full recipes**: a favourite may reference a recipe
that is not in the current cache (e.g. found via search); storing IDs keeps the
favourites store tiny and never stale, and the details screen resolves the recipe
through the recipe repository as usual.

Why SharedPreferences for favourites instead of a DB (sqflite/hive): a set of string
IDs is exactly what key-value storage is for — a database would add a dependency and
code to defend in the demo for zero benefit at this scale. (Noted as the upgrade path
if favourites later need notes/ratings per recipe.)

## 4. Data flow per function

### 4.1 Get recipes from API
```
HomeScreen → HomeViewModel.loadRecipes()
  → RecipeRepository.getRecipes()
      → ApiDataSource.fetchRecipes()            (http GET, 10 s timeout)
          → success → CacheDataSource.save(recipes)   (write-through cache)
                      → return recipes, isFromCache=false
          → NetworkException → CacheDataSource.load()
              → hit  → return cached recipes, isFromCache=true
              → miss → throw CacheMissException
  → ViewModel sets HomeStatus.loading → success | error (+ isFromCache flag)
```
This is the **cache-aside** pattern: the cache is written on success and read only
on failure, so one code path serves both online and offline.

### 4.2 Search recipes
```
SearchBar → SearchViewModel.search(query)   (debounced 300 ms)
  → RecipeRepository.searchRecipes(query)
      → online:  ApiDataSource.searchRecipes(query)  (server-side search endpoint)
      → offline: filter cached recipes client-side by title (case-insensitive contains)
  → SearchStatus.idle → loading → success | error | empty
```
Why debounce: every keystroke would otherwise fire a network request — wasteful and
it makes the loading spinner flicker. Why search offline too: the offline guarantee
should cover search, not just the home list.

### 4.3 Favourite handling (toggle)
```
FavoriteButton.onTap → FavoritesViewModel.toggleFavorite(id)
  → FavoritesRepository.toggleFavorite(id)     (pure local operation)
      → FavoritesLocalDataSource: read IDs → add/remove → write back (SharedPreferences)
  → notifyListeners() → every listening card/details heart rebuilds
```
Favouriting is **local-only by design**: it must work offline and instantly, so it
never goes to the network. Optimistic UI is safe here because the only failure mode
is a disk write, which is surfaced as a VM error flag, not a crash.

### 4.4 Save favourites to device
Handled inside 4.3: every toggle writes `favorite_recipe_ids` via SharedPreferences.
On app start, `FavoritesViewModel.init()` loads the IDs once
(`FavoritesRepository.getFavoriteIds()`), so hearts render filled immediately —
favourites survive app restarts with zero network.

### 4.5 Show recipes without internet
Covered by the cache-aside fallback in 4.1: when the API call throws
`NetworkException`, the repository reads `recipes_cache.json`. The ViewModel exposes
`isFromCache=true` and Home shows a small banner ("Offline — showing saved recipes")
plus the list; the error state is reserved for *no cache at all* (first launch
offline). Search falls back to filtering the same cache (4.2). Favourites are local
already (4.3).

**Stale ≠ deleted.** The 24 h TTL never removes the cache file — it only sets the
`isStale` flag. If the user is offline for *more than* 24 h, the fallback still reads
`recipes_cache.json`: the list, search and favourites all keep working; the only
difference is the banner wording ("Offline — showing saved recipes, saved over 24 h
ago"). Offline access fails only when there is **no cache at all** (never fetched
successfully, or app data cleared / reinstall) → `CacheMissException` → error state
with Retry. While online, any successful fetch rewrites the cache and resets
`savedAt`, so staleness only accumulates during offline periods.

### 4.6 Loading & error handling
- **States**: each VM has its own enum — Home keeps `loading/success/error/empty`
  (+ `isFromCache`), Search gets `idle/loading/success/error/empty`. Loading shows a
  spinner/skeleton; error shows a message + **Retry** button that re-calls the same
  load method; empty shows the "no recipes found" empty state (per requirements Q4 in
  `docs/01-requirements-questions.md`).
- **Typed errors** (`core/error/failures.dart`): `NetworkException` (no
  connectivity/timeout/5xx), `ParseException` (bad JSON), `CacheMissException` (no
  cache). The repository never lets a raw `http` exception leak upward; the ViewModel
  maps each type to a user-meaningful message — this is what makes the error state
  testable and demo-able.
- **Timeout**: `ApiClient` wraps every call in a 10 s `timeout()` so a hung network
  becomes a `NetworkException` (→ cache fallback) instead of an infinite spinner.

## 5. Cross-cutting flow (one picture)

```
                    ┌──────────────┐
                    │  HomeScreen  │  (also SearchBar, RecipeDetailsScreen)
                    └──────┬───────┘
              state ↑        │ actions ↓
                    ┌────────┴─────────┐
                    │ HomeViewModel    │──── SearchViewModel ────┐
                    │ FavoritesViewModel│                         │
                    └────────┬─────────┘                         │
                             │ calls                             │ calls
              ┌──────────────┼──────────────────┐                │
              ▼              ▼                  ▼                ▼
   RecipeRepository   FavoritesRepository   (search goes through
   (cache-aside)      (local only)           RecipeRepository)
        │  │                │
   try ▼  ▼ fallback    SharedPreferences
   ApiDataSource ──write──▶ RecipeCacheDataSource
   (http)                  (recipes_cache.json)
        │
   fail ▼
   read cache
```

## 6. New dependencies (approved — §8)

| Package | Why (justification for the demo) |
|---|---|
| `http` | The standard Dart HTTP client (maintained by the dart.dev team); raw `dart:io` sockets would mean hand-rolling headers, timeouts and status handling. |
| `path_provider` | Official plugin to locate the app-private documents directory where `recipes_cache.json` lives; platform paths differ (Android/iOS) and should not be hand-coded. |
| `shared_preferences` | Official Flutter plugin for key-value persistence; exactly matches the favourites use case (a list of IDs), no database needed. |

No JSON codegen (`json_serializable`), no state package (provider/riverpod), no DB
(sqflite/hive) in this sprint: hand-written `fromJson`/`toJson` on one model and
`ChangeNotifier` VMs are enough and keep the dependency count — and the lightning
questions — small.

## 7. Decisions & why (one-liners for the demo)

- **Cache-aside in the repository, not in the VM** — the fallback rule is data logic,
  so it lives below the repository interface where the UI can't bypass it.
- **IDs for favourites, JSON file for the recipe cache** — each store uses the
  simplest technology that survives restarts; nothing needs SQL at this scale.
- **Typed exceptions instead of raw try/catch on `http`** — the VM can show
  "you're offline" vs "couldn't load" distinctly, which is a graded UX behavior.
- **10 s timeout on every API call** — a hung network must degrade to cache, not to
  an eternal spinner.
- **Debounced search (300 ms)** — protects the API rate limit and the UI from
  per-keystroke loading flicker.
- **Offline = cache fallback + banner, not a separate offline mode** — one list
  code path, the banner just communicates freshness.

## 8. Decisions (resolved by Előd)

1. **Recipe API: TheMealDB** — free, no API key, list + search + image URLs.
   Only `RecipeApiDataSource` + `Recipe.fromJson` are API-specific.
2. **Packages approved**: `http`, `path_provider`, `shared_preferences` (§6) —
   to be added to `pubspec.yaml` when implementation starts, not before.
3. **Cache TTL: 24 h** — a freshness flag only, never a deletion: online → refresh
   and reset `savedAt`; offline → still serve the cache regardless of age, but set
   `isStale` when older than 24 h so the banner can say "saved recipes may be
   outdated". Offline >24 h keeps full access (see §4.5); only a missing cache file
   produces the error state.
4. **Favourites on the details screen too** — the heart there is driven by the
   same `FavoritesViewModel`, so card and details never disagree.

## 9. Acceptance criteria for the implementation phase (when we build this)

- AC1 `flutter analyze` clean with the 3 packages added; app still runs on the emulator.
- AC2 Online: home list loads from the API; cache file exists afterwards.
- AC3 Airplane mode: home list loads from cache with the offline banner; search
  still filters cached recipes; favourites still toggle.
- AC4 First launch offline (no cache): error state with Retry, no crash.
- AC5 Kill and restart the app: hearts are still filled (SharedPreferences).
- AC6 Search: debounced, shows loading → results → empty state correctly.
>>>>>>> Stashed changes
