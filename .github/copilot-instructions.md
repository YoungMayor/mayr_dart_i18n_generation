# GitHub Copilot Instructions for mayr_i18n_generator

## 📦 Project Overview

`mayr_i18n_generator` is a **Dart code generation package** (not Flutter-specific) that provides type-safe translation key generation for the `mayr_i18n` internationalization package.

### Key Features:
- Scans JSON language files and generates Dart classes with type-safe translation keys
- Provides CLI tools for verifying, syncing, auditing, and creating language files
- Integrates with `build_runner` for automatic code generation
- Supports nested JSON structures for organized translation keys

## 🏗️ Architecture

### Core Components:

1. **Configuration Reader** (`src/config.dart`)
   - Reads `mayr_i18n` configuration from `pubspec.yaml`
   - Default values: `lang_directory: assets/lang`, `default_locale: en`
   - Reads `mayr_i18n_generation` configuration for generator settings
   - Default `output_file: lib/generated/translations.dart` (prevents conflicts with other generators)

2. **JSON Parser** (`src/json_parser.dart`)
   - Parses JSON language files from the configured directory
   - Handles nested JSON structures
   - Validates JSON format

3. **Key Tree Builder** (`src/key_tree_builder.dart`)
   - Converts parsed JSON into a hierarchical key structure
   - Example: `{"app": {"welcome": "..."}}` → `app.welcome`

4. **Code Emitter** (`src/code_emitter.dart`)
   - Generates Dart code from the key tree
   - Creates classes like `I18nKeys`, `_AppKeys`, `_ErrorKeys`, etc.

5. **Generator** (`src/i18n_generator.dart`)
   - Integrates with `build_runner` via `source_gen`
   - Main entry point for code generation

### CLI Tools (in `bin/`):
- `generate.dart` - Manual code generation

**Note**: CLI commands for verifying, syncing, auditing, and creating translation files are provided by the `mayr_i18n` package, not this generator package.

## 🔧 Development Guidelines

### Dependencies:
```yaml
dependencies:
  analyzer: ^6.0.0 or ^7.0.0 (use latest stable)
  build: ^2.4.0
  source_gen: ^1.5.0 or ^1.6.0
  path: ^1.9.0
  yaml: ^3.1.0
  args: ^2.4.0
  glob: ^2.1.0

dev_dependencies:
  build_runner: ^2.4.0
  test: ^1.25.0 or ^1.26.0
  lints: ^6.0.0
```

### Code Style:
- Follow Dart style guide and use `lints` package
- Add dartdoc comments to all public APIs
- Use meaningful variable and class names
- Keep functions focused and single-purpose

### Generated Code Format:
```dart
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: constant_identifier_names, non_constant_identifier_names

part of 'translations.dart';

class I18nKeys {
  const I18nKeys._();
  static const app = _AppKeys._();
  static const errors = _ErrorKeys._();
}

class _AppKeys {
  const _AppKeys._();
  final String welcome = 'app.welcome';
  final String logout = 'app.logout';
}

class _ErrorKeys {
  const _ErrorKeys._();
  final String network = 'errors.network';
}
```

### Testing:
- Write unit tests for each component
- Test with various JSON structures (simple, nested, deeply nested)
- Test error handling (missing files, invalid JSON, etc.)
- Test CLI commands

### Example Structure:
The `example/` directory should contain:
- Sample `pubspec.yaml` with `mayr_i18n` configuration
- Sample JSON files in `assets/lang/` (en.json, fr.json)
- `lib/translations.dart` demonstrating usage
- Generated `lib/translations.g.dart` (after running generator)
- Main example showing how to use the generated code

## 🚀 Usage Patterns

### For Package Users:

1. Add dependencies to `pubspec.yaml`
2. Configure `mayr_i18n` section with `lang_directory` and `default_locale`
3. Create JSON translation files
4. Create `lib/translations.dart` with `part 'translations.g.dart';`
5. Run `dart run build_runner build` or `dart run mayr_i18n_generator:generate`
6. Use generated keys: `I18nKeys.app.welcome.tr(args: {'name': 'John'})`

### CLI Commands:
- `dart run mayr_i18n_generator:generate` - Generate translation keys manually

**Note**: For verifying, syncing, auditing, and creating translation files, use the [`mayr_i18n`](https://pub.dev/packages/mayr_i18n) package CLI commands.

## 📝 Important Notes

### File Generation:
- The generator looks for files with `part 'translations.g.dart';` (or similar `.g.dart` parts)
- It reads the `mayr_i18n` configuration from the project's `pubspec.yaml`
- Generated code should be formatted and follow Dart conventions

### Error Handling:
- Gracefully handle missing configuration
- Provide clear error messages for invalid JSON
- Warn about missing keys between locales
- Handle file I/O errors appropriately

### Performance:
- Cache parsed JSON to avoid redundant parsing
- Use efficient data structures for key trees
- Optimize for build_runner's incremental builds

## 🧪 Testing Strategy

1. **Unit Tests**:
   - Test JSON parsing with various structures
   - Test key tree building logic
   - Test code emission with different scenarios
   - Test configuration reading

2. **Integration Tests**:
   - Test full generation pipeline
   - Test with real JSON files
   - Test CLI commands end-to-end

3. **Edge Cases**:
   - Empty JSON files
   - Deeply nested structures (5+ levels)
   - Special characters in keys
   - Very large translation files

## 🔍 Common Issues & Solutions

### Issue: Build runner not finding files
- **Solution**: Check `build.yaml` configuration and `generate_for` patterns

### Issue: Generated code has compilation errors
- **Solution**: Validate Dart identifiers, escape special characters

### Issue: Nested keys not working
- **Solution**: Ensure recursive traversal in key tree builder

### Issue: CLI commands not found
- **Solution**: Check `executables` in `pubspec.yaml`

## 📚 Additional Resources

- [Dart build_runner documentation](https://pub.dev/packages/build_runner)
- [source_gen documentation](https://pub.dev/packages/source_gen)
- [Dart analyzer package](https://pub.dev/packages/analyzer)
- [mayr_i18n package](https://pub.dev/packages/mayr_i18n) (if published)

## 🎯 Success Criteria

The package is complete when:
- ✅ All core components are implemented and tested
- ✅ CLI tools work correctly
- ✅ Generated code compiles without errors
- ✅ Example project demonstrates all features
- ✅ Documentation is comprehensive and clear
- ✅ All tests pass
- ✅ Package follows Dart best practices
