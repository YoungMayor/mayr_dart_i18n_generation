## 1.0.0

### 🎉 Initial Release

A complete Dart code generation package for type-safe i18n translation keys.

#### Features

- ✨ **Type-safe translation keys** - Generate Dart classes from JSON translation files
- 🏗️ **build_runner integration** - Automatic code generation with build_runner
- 🔧 **CLI tool** for manual code generation:
  - `generate` - Automatically creates output file and generates translation keys
- 📦 **Nested JSON support** - Handle deeply nested translation structures
- 🌐 **Multi-locale support** - Manage multiple language files easily
- 🎯 **Targeted generation** - Configure which file to process via `output_file` to avoid conflicts with other generators
- 🚀 **Automatic file creation** - CLI command creates the output file with proper structure if it doesn't exist
- 📝 **Comprehensive documentation** - Full API docs and examples
- ✅ **Well-tested** - Extensive test coverage for all components

**Note**: Commands for verifying, syncing, and auditing translations are available in the [`mayr_i18n`](https://pub.dev/packages/mayr_i18n) package.

#### Configuration

```yaml
mayr_i18n:
  lang_directory: assets/lang
  default_locale: en

mayr_i18n_generation:
  output_file: lib/translations.dart  # Default: lib/generated/translations.dart
```

The `output_file` configuration specifies which file to create and process. The CLI command will automatically create this file (with the necessary part directive) if it doesn't exist, then generate the `.g.dart` file with translation keys.

#### Core Components

- `I18nConfig` - Read and manage i18n configuration from pubspec.yaml
- `GeneratorConfig` - Read generator-specific settings (output_file)
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
