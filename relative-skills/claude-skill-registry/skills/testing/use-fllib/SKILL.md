---
name: use-fllib
description: Use fl_lib stores, widgets, utils, and extensions in Flutter apps. Use when requests mention fl_lib APIs or integration.
---

# Use fl_lib

## When to use
- Use when the user asks about fl_lib setup, localization, or Paths init.
- Use when requests mention PrefStore, SecureStore, HiveStore, AdaptiveReorderableList, Input, SizedLoading, or fl_lib extensions/utils.

## Instructions
1) **Setup**: Follow the fl_lib Setup & Usage section below for dependency, Paths init, and localization wiring.
2) **Stores**: Use the right store for the data type; see the fl_lib Stores section below. Prefer PrefStore for settings, SecureStore for secrets, HiveStore for structured caching.
3) **Widgets**: Prefer fl_lib widgets for common UI patterns; see the fl_lib Widgets section below.
4) **Utils & extensions**: Use provided helpers for IDs, crypto, UI/system, and convenience APIs; see the fl_lib Utils and fl_lib Extensions sections below.
5) **Library changes**: If modifying fl_lib itself, run `./export_all.dart` in the fl_lib root.

## Requirements
### fl_lib usage
1) **Foundation**: Use fl_lib as the common library when it is already part of the project.
2) **Storage**: Use PrefStore for key-value settings and SecureStore for sensitive data; use HiveStore for local structured caching.

# fl_lib Setup & Usage

## Installation
Add the dependency to your `pubspec.yaml` pointing to the GitHub repository:

```yaml
dependencies:
  fl_lib:
    git:
      url: https://github.com/lppcg/fl_lib.git
      ref: main
```

## Initialization
Before running `runApp`, you must initialize the `Paths` utility:

```dart
void main() async {
  // Initialize fl_lib Paths
  await Paths.init();
  runApp(MyApp());
}
```

## Localization
Configure `localizationsDelegates` in your `MaterialApp` to include `LibLocalizations.delegate`. This ensures fl_lib's internal widgets and utilities are properly localized.

```dart
MaterialApp(
  localizationsDelegates: const [
    LibLocalizations.delegate,
    ...AppLocalizations.localizationsDelegates,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
)
```

In your main app widget (e.g., in `didChangeDependencies`), call `context.setLibL10n()` only in root Widget to synchronize localization settings:

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  context.setLibL10n();
}
```

## Maintenance
If you are modifying `fl_lib` itself (e.g., adding new files), remember to run the `./export_all.dart` script in the `fl_lib` root to update exports.

# fl_lib Stores

fl_lib provides three types of stores for different persistence needs: `PrefStore`, `SecureStore`, and `HiveStore`.
All stores implement the `Store` interface, providing a unified API for data access.

## Store Interface
The core interface for all stores. Key features include:
- **Unified API**: `get<T>`, `set<T>`, `remove`, `clear`, `keys`.
- **Type Safety**: Automatic conversion support via `StoreFromObj` and `StoreToObj`.
- **Reactive**: `getAll()` stream support.
- **Metadata**: Tracks `lastUpdateTs` automatically (optional).

## PrefStore
A wrapper around `SharedPreferences` for storing simple key-value pairs (settings, flags, etc.).

### Initialization
Must be initialized before use, typically in `main.dart`.
```dart
await PrefStore.shared.init(prefix: 'my_app_');
```

### Usage
Define properties using `PrefProp` or `PrefPropDefault` for type safety.
Recommended pattern: Define all prefs in a static class or extension.

```dart
// Define properties
abstract class Prefs {
  // Simple property, nullable
  static const userToken = PrefProp<String>('user_token');
  
  // Property with default value, non-nullable
  static const isDarkMode = PrefPropDefault<bool>('is_dark_mode', false);
  
  // Custom object with JSON serialization
  static final userProfile = PrefProp<UserProfile>(
    'user_profile',
    fromObj: (json) => UserProfile.fromJson(json),
    toObj: (obj) => obj.toJson(),
  );
}

// Read
final isDark = Prefs.isDarkMode.get(); // Returns bool
final token = Prefs.userToken.get();   // Returns String?

// Write
await Prefs.isDarkMode.set(true);
await Prefs.userToken.set('xyz-123');

// Listen (Reactive)
return ValueListenableBuilder(
  valueListenable: Prefs.isDarkMode.listenable(),
  builder: (context, value, child) {
    return Text('Dark Mode: $value');
  },
);
```

### Supported Types
- Native: `bool`, `double`, `int`, `String`, `List<String>`.
- JSON: `Map<String, dynamic>` is automatically JSON encoded/decoded.
- Custom: Use `fromObj` and `toObj` converters.

## SecureStore
Uses `flutter_secure_storage` to store sensitive data (passwords, tokens).
Includes built-in `JSON` support extensions.

### Usage
Access via `SecureStore` static methods or `SecureProp`.

```dart
// Define secure property
static const apiToken = SecureProp('api_token');

// Read/Write
await apiToken.write('secret_token');
final token = await apiToken.read();

// Direct usage with JSON extensions
await SecureStore.storage.writeJson(
  'user_creds', 
  credsObj, 
  (c) => c.toJson(),
);

final creds = await SecureStore.storage.readJson(
  'user_creds', 
  (json) => Credentials.fromJson(json),
);
```

### Built-in Props
- `SecureStoreProps.bakPwd`: Backup password.
- `SecureStoreProps.hivePwd`: Encryption key for HiveStore (managed automatically).

## HiveStore
A NoSQL-like store using `hive_ce` (Community Edition).
**Key Feature**: Automatic encryption management via `SecureStore`.

### Initialization
```dart
final myStore = HiveStore('my_box');
await myStore.init(); // Handles encryption key generation/retrieval automatically
```

### Usage
Use `HiveProp` or `HivePropDefault`.

```dart
final cacheProp = myStore.propertyDefault<int>('cache_count', 0);

// Read/Write
cacheProp.put(42);
final count = cacheProp.fetch(); // or .get()

// List Property
final logs = myStore.listProperty<String>('logs');
logs.put(['log1', 'log2']);
```

### Encryption Logic
1. `HiveStore` checks `SecureStore` for an existing encryption key.
2. If missing, generates a new secure key.
3. Saves the key to `SecureStore` (under `SecureStoreProps.hivePwd`).
4. Opens the Hive box using this key.
5. Auto-migrates from unencrypted to encrypted if an old unencrypted box exists.

# fl_lib Widgets

fl_lib provides a rich collection of production-ready widgets, focusing on responsiveness, adaptability, and common UI patterns.

## AdaptiveReorderableList
A powerful, responsive multi-column reorderable list that adapts to screen width.

### Features
- **Responsive Layout**: Automatically calculates column count based on available width.
- **Dual Layout Modes**:
  - `useMasonry: true` (default): Waterfall/Masonry layout (minimizes vertical gaps).
  - `useMasonry: false` (or `rowMajor: true`): Aligned row-major grid (preserves order).
- **Animations**:
  - `animationDuration`: Insert/Remove animations.
  - `dropAnimationDuration`: Drag-and-drop settle animations.
  - `insertCurve` / `removeCurve`: Customizable curves.
- **Drag & Drop**: Long-press to drag. Includes feedback opacity (`draggingChildOpacity`).
- **Separators**: Supports `AdaptiveReorderableList.separated` constructor.

### Usage
```dart
AdaptiveReorderableList.builder<String>(
  items: myItems,
  itemKey: (item) => item.id,
  itemBuilder: (context, item, index, animation) {
     return SizeTransition(
       sizeFactor: animation,
       child: MyCard(item),
     );
  },
  onReorderComplete: (newItems) {
    setState(() => myItems = newItems);
  },
  // Optional customizations
  maxColumns: 4,
  columnWidth: 300,
  crossAxisSpacing: 16,
  mainAxisSpacing: 16,
)
```

## Input
A high-level wrapper around `TextField` designed to reduce boilerplate.

### Key Features
- **Auto-Card Wrapping**: By default, wraps input in a `CardX` for consistent styling. Use `noWrap: true` to disable.
- **Password Toggle**: If `obscureText: true`, automatically adds a visibility toggle icon.
- **Reactive IME**: Respects global IME suggestions setting via `PrefProps.imeSuggestions`.
- **Context Menu**: Uses `AdaptiveTextSelectionToolbar` by default.

### Usage
```dart
Input(
  label: 'Password',
  obscureText: true,
  icon: Icons.lock,
  onChanged: (val) => print(val),
  // Validators/Error text
  errorText: _errorMsg,
  // Custom actions
  onSubmitted: (val) => _submit(),
)
```

## SizedLoading
Standardized loading indicators to ensure consistency across the app.

### Predefined Sizes
- `SizedLoading.small`: 25x25 (e.g., inside buttons)
- `SizedLoading.medium`: 45x45 (e.g., card loading)
- `SizedLoading.large`: 65x65 (e.g., page loading)

### Custom Usage
```dart
// Custom size with padding
SizedLoading(30, padding: 5)

// Custom builder (e.g., linear)
SizedLoading(
  100, 
  builder: SizedLoading.linearBuilder
)
```

## Other Notable Widgets

### Layout & Containers
- **AdaptiveList**: Similar to reorderable list but static.
- **CardX**: An extended `Card` widget with better defaults for the design system.
- **Split**: A split-view widget for resizable panes.
- **VirtualWindowFrame**: For desktop apps, handles custom window frame rendering.

### Interactive
- **Btn**: Standardized buttons (implementations in `src/view/widget/btn`).
- **Choice**: Chip-like selection widgets.
- **ColorPicker**: A simple color selection widget.
- **SlideTrans**: Slide transition wrapper.

### Content
- **Markdown**: Wrapper for `flutter_markdown` with custom styling.
- **Tag**: Tag/Badge component.
- **Turnstile**: Cloudflare Turnstile integration widget.

# fl_lib Utils

fl_lib provides a robust set of utility classes for ID generation, cryptography, and UI/System integration.

## ID Generation

### SnowflakeLite
A lightweight, high-performance ID generator based on the Snowflake algorithm (timestamp + sequence).
- **Structure**: 66 bits (54 bit timestamp + 12 bit sequence).
- **Format**: Radix-36 string (alphanumeric).
- **Use Case**: Primary keys, sortable unique IDs.

```dart
// Generate
final id = SnowflakeLite.generate();

// Decode
final (timestamp, seq) = SnowflakeLite.decode(id)!;
```

### ShortId
Generates shorter, URL-friendly IDs based on timestamp and randomness.
- **Format**: Custom base64-like string (a-Z, 0-9, -, +).
- **Use Case**: Public facing IDs, shareable links.

```dart
final shortId = ShortId.generate();
```

## Cryptography

### Cryptor
A secure encryption utility class designed for sensitive data storage.
- **Algorithm**: AES-GCM (Authenticated Encryption).
- **Key Derivation**: PBKDF2 (SHA-256, 100k iterations).
- **Structure**: `Header` + `Salt` + `Nonce` + `Ciphertext` + `AuthTag`.

```dart
// Encrypt
final encrypted = Cryptor.encrypt('my_secret_data', 'my_password');

// Decrypt
final decrypted = Cryptor.decrypt(encrypted, 'my_password');

// Verification
final isEnc = Cryptor.isEncrypted(someString);

// Test Helper
final randPwd = Cryptor.generatePassword();
```

## UI & System Utils

### FontUtils
Helper for dynamic font loading.

```dart
// Load font from a local file path
await FontUtils.loadFrom('/path/to/font.ttf');
```

### SystemUIs
Manages system UI overlays and window configurations for different platforms.

```dart
// Android: Transparent Navigation Bar (Edge-to-Edge)
SystemUIs.setTransparentNavigationBar(context);

// Toggle Status Bar
SystemUIs.switchStatusBar(hide: true); // Immersive Sticky
SystemUIs.switchStatusBar(hide: false); // Edge-to-Edge

// Desktop: Window Initialization
await SystemUIs.initDesktopWindow(
  hideTitleBar: true,
  size: Size(800, 600),
  position: Offset.zero,
);
```

# fl_lib Extensions

fl_lib provides a comprehensive set of Dart extensions to reduce boilerplate and enhance developer productivity.

## BuildContext Extensions
Found in `src/core/ext/ctx/common.dart` and `dialog.dart`.

### Navigation & Theme
```dart
context.pop();             // Safer Navigator.pop
context.canPop;            // Check if can pop
context.theme;             // Theme.of(context)
context.isDark;            // Check brightness
context.mediaQuery;        // MediaQuery.of(context)
context.windowSize;        // MediaQuery.sizeOf(context) (Optimized)
context.libL10n;           // Access library localization
```

### Responsive Design
Using `responsive_framework`:
```dart
context.responsiveBreakpoints; // Raw data
context.isMobile;              // Phone or Mobile breakpoint
context.isDesktop;             // Desktop or Tablet breakpoint
```

### Dialogs & Overlays
```dart
// Show a consistent rounded dialog
await context.showRoundDialog(
  title: 'Hello',
  child: Text('Content'),
  actions: [TextButton(child: Text('OK'))], // Or use Btnx.cancelOks
);

// Show loading dialog with async task
await context.showLoadingDialog(
  fn: () async => await doSomething(),
);

// Show password input dialog
final pwd = await context.showPwdDialog(title: 'Enter Password');

// Show pickers
final selected = await context.showPickDialog(
  items: ['A', 'B', 'C'],
  multi: true,
);
```

## Widget Extensions
Found in `src/core/ext/widget.dart`. Use these for cleaner UI code.

```dart
Text('Hello')
  .center()                    // Center(child: ...)
  .paddingAll(8)               // Padding(padding: EdgeInsets.all(8), child: ...)
  .paddingSymmetric(horizontal: 16)
  .expanded(flex: 2)           // Expanded(flex: 2, child: ...)
  .tap(onTap: () => print('tapped')); // InkWell wrapper with throttle
  
// Sliver conversion
Container().sliver();          // SliverToBoxAdapter(child: ...)
```

## String Extensions
Found in `src/core/ext/string.dart`.

### Manipulation & Validation
```dart
'hello'.capitalize;        // "Hello"
'#FF0000'.fromColorHex;    // Color(0xFFFF0000)
'https://example.com'.isUrl; 
'https://example.com'.launchUrl();
```

### Path & File
```dart
'/path/to'.joinPath('file.txt');
'/path/to/file.txt'.getFileName(); // "file.txt"
'/path/to/file.txt'.getFileName(withoutExtension: true); // "file"
```

### DateTime Parsing
```dart
'2023-01-01'.parseDateTime();
'1672531200000'.parseTimestamp();
```

### Image Provider
```dart
'https://img.com/a.png'.imageProvider; // Handles Network, Asset, and File automatically
```

## Collection Extensions
Found in `src/core/ext/iter.dart`.

```dart
// List
[1, 2, 3].joinWith(0);        // [1, 0, 2, 0, 3]

// Iterable Null Safety
list.firstOrNull;
list.firstWhereOrNull((e) => e > 5);
list.nullOrEmpty;             // Checks if null or empty
```

## DateTime Extensions
Found in `src/core/ext/datetime.dart`.

```dart
final now = DateTime.now();
now.hourMinute;     // "14:30"
now.ymd();          // "2023-05-20"
now.hms();          // "14:30:45"
now.simple();       // Smart format: "14:30", "Yesterday 14:30", or "5-20"
DateTimeX.timestamp; // Current millis
```

## Riverpod & State Extensions
Found in `src/core/ext/ctx/common.dart`.

```dart
// In ConsumerState
refSafe;        // Returns ref only if mounted
contextSafe;    // Returns context only if mounted
setStateSafe(() {}); // setState only if mounted
```

## Example prompts
- "Wire fl_lib localization and Paths init in main.dart"
- "Store auth tokens using SecureStore and preferences using PrefStore"
- "Build a responsive grid with AdaptiveReorderableList"
- "Use fl_lib context extensions to show a loading dialog"
- "Generate IDs with SnowflakeLite and ShortId"
