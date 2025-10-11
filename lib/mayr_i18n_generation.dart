/// Support for generating type-safe i18n translation keys.
///
/// This package provides code generation for the mayr_i18n package,
/// creating type-safe accessors for translation keys from JSON files.
///
/// ## Usage
///
/// 1. Add this package to your dev_dependencies
/// 2. Configure `mayr_i18n` in your pubspec.yaml
/// 3. Create translation JSON files
/// 4. Add `part 'filename.g.dart';` to your translations file
/// 5. Run `dart run mayr_i18n_generator:generate`
library;

export 'src/config.dart';
export 'src/json_parser.dart';
export 'src/key_tree_builder.dart';
export 'src/code_emitter.dart';
export 'src/i18n_generator.dart' show i18nBuilder;
