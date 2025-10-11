## 1.0.0

### 🎉 Initial Release

A complete Dart code generation package for type-safe i18n translation keys.

#### Features

- ✨ **Type-safe translation keys** - Generate Dart classes from JSON translation files
- 🏗️ **build_runner integration** - Automatic code generation with build_runner
- 🔧 **CLI tools** for managing translations:
  - `generate` - Generate translation keys manually
  - `verify` - Check for missing keys across locales
  - `sync` - Synchronize keys across all locale files
  - `audit` - Find unused or undefined translation keys
  - `create` - Create new language files with proper structure
- 📦 **Nested JSON support** - Handle deeply nested translation structures
- 🌐 **Multi-locale support** - Manage multiple language files easily
- 📝 **Comprehensive documentation** - Full API docs and examples
- ✅ **Well-tested** - Extensive test coverage for all components

#### Core Components

- `I18nConfig` - Read and manage configuration from pubspec.yaml
- `JsonParser` - Parse and validate JSON translation files
- `KeyTreeBuilder` - Build hierarchical key structures
- `CodeEmitter` - Generate clean, readable Dart code
- `I18nGenerator` - build_runner integration for automatic generation

#### Example Usage

```dart
// Define translations in JSON
{
  "app": {
    "welcome": "Welcome {name}!",
    "logout": "Goodbye"
  }
}

// Access with type-safe keys
I18nKeys.app.welcome.tr(args: {'name': 'John'});
```

See the [README.md](README.md) for complete documentation and [example/](example/) for working examples.
