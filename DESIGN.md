## ⚙️ **Design Document: `mayr_i18n_generator`**

### 🧩 **Package Type**

Dart package (not Flutter)

---

## 1. 📦 **Purpose**

`mayr_i18n_generator` provides **code generation utilities** for the `mayr_i18n` package.
It scans all JSON language files in the configured directory and generates **type-safe translation accessors** and helpers, enabling autocompletion and compile-time safety.

---

## 2. 🔧 **Dependencies**

```yaml
dependencies:
  analyzer: ^6.0.0
  build: ^2.4.0
  source_gen: ^1.5.0
  mayr_i18n: ^1.0.0

dev_dependencies:
  build_runner: ^2.4.0
```

---

## 3. 📁 **File Structure**

```
mayr_i18n_generator/
│
├── lib/
│   ├── mayr_i18n_generator.dart     # Entry point
│   ├── src/
│   │   ├── i18n_generator.dart      # Main generator logic
│   │   ├── json_parser.dart         # Parses language JSON files
│   │   ├── key_tree_builder.dart    # Converts JSON to Dart accessors
│   │   └── emitter.dart             # Writes out the final Dart code
│
├── build.yaml
└── pubspec.yaml
```

---

## 4. 🧠 **How It Works**

### 1️⃣ Scans JSON files

The generator looks inside the configured `lang_directory` (default: `assets/lang`).

Example:

```bash
assets/lang/en.json
assets/lang/fr.json
assets/lang/genz.json
```

---

### 2️⃣ Parses Nested Keys

Given a JSON file like:

```json
{
  "app": {
    "welcome": "Welcome {name}",
    "logout": "Goodbye"
  },
  "errors": {
    "network": "No connection"
  }
}
```

It builds a **key tree**:

```
app.welcome
app.logout
errors.network
```

---

### 3️⃣ Generates a Dart file

Creates `translations.g.dart` like this:

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: constant_identifier_names, non_constant_identifier_names

part of 'translations.dart';

class I18nKeys {
  static const app = _AppKeys();
  static const errors = _ErrorKeys();
}

class _AppKeys {
  final welcome = 'app.welcome';
  final logout = 'app.logout';
}

class _ErrorKeys {
  final network = 'errors.network';
}
```

---

### 4️⃣ Supports CLI Commands

You can optionally run:

```bash
dart run mayr_i18n_generator:generate
```

to trigger generation manually (for users who prefer direct CLI over build_runner).

---

## 5. ⚙️ **Configuration**

Reads from `pubspec.yaml` under `mayr_i18n`:

```yaml
mayr_i18n:
  lang_directory: assets/lang
  default_locale: en
```

---

## 6. 🏗️ **build.yaml**

```yaml
targets:
  $default:
    builders:
      mayr_i18n_generator:
        generate_for:
          - lib/**.dart
        options:
          enabled: true
builders:
  mayr_i18n_generator:
    import: "package:mayr_i18n_generator/mayr_i18n_generator.dart"
    builder_factories: ["i18nBuilder"]
    build_extensions: {".dart": [".g.dart"]}
    auto_apply: dependents
    build_to: source
```

---

## 7. 🚀 **Usage Example**

### In user’s `pubspec.yaml`:

```yaml
dependencies:
  mayr_i18n: ^1.0.0

dev_dependencies:
  build_runner: ^2.4.0
  mayr_i18n_generator: ^1.0.0
```

### In `lib/translations.dart`

```dart
import 'package:mayr_i18n/mayr_i18n.dart';

part 'translations.g.dart';
```

Then run:

```bash
dart run mayr_i18n_generator:generate
```
or
```bash
dart run build_runner build
```

---

## 8. 💡 **Bonus Features (Optional)**

* 🧩 **Generate enums** for keys (`I18nKeys.app.welcome` → `I18nKey.appWelcome`)
* 🔍 **Watch mode:** Auto-regenerate on JSON changes
