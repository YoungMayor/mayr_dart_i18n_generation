# mayr_i18n_generation Example

This example demonstrates how to use the `mayr_i18n_generation` package to generate type-safe translation keys.

## Setup

1. **Configure your `pubspec.yaml`**:

```yaml
mayr_i18n:
  lang_directory: assets/lang
  default_locale: en
```

2. **Create JSON translation files** in `assets/lang/`:
   - `en.json` - English translations
   - `fr.json` - French translations
   - Add more as needed

3. **Create a translations file** (e.g., `lib/translations.dart`):

```dart
library;

part 'translations.g.dart';
```

## Generate Code

Run one of these commands to generate the translation keys:

### Using build_runner (recommended):
```bash
cd example
dart pub get
dart run build_runner build
```

### Using the CLI tool:
```bash
cd example
dart pub get
dart run mayr_i18n_generation:generate
```

## Run the Example

After generating the code, run the example:

```bash
dart run mayr_i18n_generation_example.dart
```

**Note**: Additional CLI commands for verifying, syncing, and auditing translations are available in the [`mayr_i18n`](https://pub.dev/packages/mayr_i18n) package.

## Project Structure

```
example/
├── assets/
│   └── lang/
│       ├── en.json          # English translations
│       └── fr.json          # French translations
├── lib/
│   ├── translations.dart    # Declares the part directive
│   └── translations.g.dart  # Generated code (created by generator)
├── mayr_i18n_generation_example.dart  # Example usage
└── pubspec.yaml             # Configuration
```

## Generated Code

The generator creates a `translations.g.dart` file with:

- **`I18nKeys` class**: Main entry point with static accessors
- **Nested classes**: For grouped translation keys (e.g., `_AppKeys`, `_AuthKeys`)
- **Type-safe access**: All keys are compile-time checked
- **IDE support**: Full autocomplete and refactoring support

Example usage:

```dart
// Access keys in a type-safe way
final welcomeKey = I18nKeys.app.welcome;  // 'app.welcome'
final emailKey = I18nKeys.auth.email;     // 'auth.email'
final ageKey = I18nKeys.profile.details.age;  // 'profile.details.age'

// Use with translation function (requires mayr_i18n package)
final translated = I18nKeys.app.welcome.tr(args: {'name': 'John'});
// => "Welcome John!" (in English)
// => "Bienvenue John!" (in French)
```

## Tips

- Keep your JSON files synchronized across all locales
- Use descriptive, hierarchical key names
- Run `verify` regularly to catch missing translations
- Use `audit` to find unused keys and clean up
