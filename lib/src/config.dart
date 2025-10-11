/// Configuration reader for mayr_i18n package settings.
///
/// Reads configuration from `pubspec.yaml` under the `mayr_i18n` key.
library;

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// Configuration for the i18n generator.
class I18nConfig {
  /// Directory containing JSON language files.
  final String langDirectory;

  /// Default locale identifier.
  final String defaultLocale;

  /// Creates a new configuration instance.
  const I18nConfig({required this.langDirectory, required this.defaultLocale});

  /// Default configuration values.
  static const I18nConfig defaults = I18nConfig(
    langDirectory: 'assets/lang',
    defaultLocale: 'en',
  );

  /// Reads configuration from the given pubspec.yaml file.
  ///
  /// Returns default configuration if the file doesn't exist or
  /// doesn't contain mayr_i18n configuration.
  static I18nConfig fromPubspec(String pubspecPath) {
    final file = File(pubspecPath);

    if (!file.existsSync()) {
      return defaults;
    }

    try {
      final content = file.readAsStringSync();
      final yaml = loadYaml(content);

      if (yaml is! Map || !yaml.containsKey('mayr_i18n')) {
        return defaults;
      }

      final config = yaml['mayr_i18n'];

      return I18nConfig(
        langDirectory:
            config['lang_directory']?.toString() ?? defaults.langDirectory,
        defaultLocale:
            config['default_locale']?.toString() ?? defaults.defaultLocale,
      );
    } catch (e) {
      print('Warning: Failed to read mayr_i18n configuration: $e');
      return defaults;
    }
  }

  /// Finds and reads configuration from the nearest pubspec.yaml.
  ///
  /// Searches upwards from [startPath] until a pubspec.yaml is found.
  static I18nConfig findAndRead([String? startPath]) {
    startPath ??= Directory.current.path;

    var currentDir = Directory(startPath);

    // Search upwards for pubspec.yaml
    while (true) {
      final pubspecPath = p.join(currentDir.path, 'pubspec.yaml');
      final file = File(pubspecPath);

      if (file.existsSync()) {
        return fromPubspec(pubspecPath);
      }

      final parentDir = currentDir.parent;
      if (parentDir.path == currentDir.path) {
        // Reached root directory
        break;
      }
      currentDir = parentDir;
    }

    return defaults;
  }

  /// Gets the absolute path to the language directory.
  String getAbsoluteLangDirectory([String? basePath]) {
    basePath ??= Directory.current.path;
    return p.normalize(p.join(basePath, langDirectory));
  }

  @override
  String toString() {
    return 'I18nConfig(langDirectory: $langDirectory, defaultLocale: $defaultLocale)';
  }
}

/// Configuration for the code generator itself.
class GeneratorConfig {
  /// Output file path for code generation.
  /// If specified, only this file will be processed by the generator.
  final String outputFile;

  /// Creates a new generator configuration instance.
  const GeneratorConfig({required this.outputFile});

  /// Default configuration values.
  static const GeneratorConfig defaults = GeneratorConfig(
    outputFile: 'lib/generated/translations.dart',
  );

  /// Reads generator configuration from the given pubspec.yaml file.
  ///
  /// Returns default configuration if the file doesn't exist or
  /// doesn't contain mayr_i18n_generation configuration.
  static GeneratorConfig fromPubspec(String pubspecPath) {
    final file = File(pubspecPath);

    if (!file.existsSync()) {
      return defaults;
    }

    try {
      final content = file.readAsStringSync();
      final yaml = loadYaml(content);

      if (yaml is! Map || !yaml.containsKey('mayr_i18n_generation')) {
        return defaults;
      }

      final config = yaml['mayr_i18n_generation'];

      return GeneratorConfig(
        outputFile: config['output_file']?.toString() ?? defaults.outputFile,
      );
    } catch (e) {
      print('Warning: Failed to read mayr_i18n_generation configuration: $e');
      return defaults;
    }
  }

  /// Finds and reads configuration from the nearest pubspec.yaml.
  ///
  /// Searches upwards from [startPath] until a pubspec.yaml is found.
  static GeneratorConfig findAndRead([String? startPath]) {
    startPath ??= Directory.current.path;

    var currentDir = Directory(startPath);

    // Search upwards for pubspec.yaml
    while (true) {
      final pubspecPath = p.join(currentDir.path, 'pubspec.yaml');
      final file = File(pubspecPath);

      if (file.existsSync()) {
        return fromPubspec(pubspecPath);
      }

      final parentDir = currentDir.parent;
      if (parentDir.path == currentDir.path) {
        // Reached root directory
        break;
      }
      currentDir = parentDir;
    }

    return defaults;
  }

  @override
  String toString() {
    return 'GeneratorConfig(outputFile: $outputFile)';
  }
}
