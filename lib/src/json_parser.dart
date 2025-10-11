/// JSON parser for translation files.
///
/// Parses JSON translation files and validates their structure.
library;

import 'dart:convert';
import 'dart:io';

/// Result of parsing a JSON translation file.
class ParsedTranslations {
  /// The locale identifier (filename without extension).
  final String locale;

  /// The parsed translation data as a nested map.
  final Map<String, dynamic> translations;

  /// The source file path.
  final String filePath;

  const ParsedTranslations({
    required this.locale,
    required this.translations,
    required this.filePath,
  });
}

/// Parser for JSON translation files.
class JsonParser {
  /// Parses a JSON file and returns the translation data.
  ///
  /// Throws [FileSystemException] if the file doesn't exist.
  /// Throws [FormatException] if the JSON is invalid.
  static ParsedTranslations parseFile(String filePath) {
    final file = File(filePath);
    
    if (!file.existsSync()) {
      throw FileSystemException('Translation file not found', filePath);
    }

    final content = file.readAsStringSync();
    final locale = _getLocaleFromFilePath(filePath);

    try {
      final decoded = jsonDecode(content);
      
      if (decoded is! Map<String, dynamic>) {
        throw FormatException(
          'Translation file must contain a JSON object',
          filePath,
        );
      }

      return ParsedTranslations(
        locale: locale,
        translations: decoded,
        filePath: filePath,
      );
    } on FormatException catch (e) {
      throw FormatException(
        'Invalid JSON in $filePath: ${e.message}',
        e.source,
        e.offset,
      );
    }
  }

  /// Parses all JSON files in the given directory.
  ///
  /// Returns a list of parsed translations, one for each .json file.
  static List<ParsedTranslations> parseDirectory(String directoryPath) {
    final directory = Directory(directoryPath);

    if (!directory.existsSync()) {
      throw FileSystemException(
        'Language directory not found',
        directoryPath,
      );
    }

    final jsonFiles = directory
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.json'))
        .toList();

    if (jsonFiles.isEmpty) {
      throw StateError(
        'No JSON translation files found in $directoryPath',
      );
    }

    return jsonFiles.map((file) => parseFile(file.path)).toList();
  }

  /// Extracts the locale identifier from a file path.
  ///
  /// Example: 'assets/lang/en.json' -> 'en'
  static String _getLocaleFromFilePath(String filePath) {
    final fileName = filePath.split(Platform.pathSeparator).last;
    return fileName.replaceAll('.json', '');
  }

  /// Validates that all locales have the same set of keys.
  ///
  /// Returns a map of locale to missing keys, or empty map if all valid.
  static Map<String, List<String>> validateLocales(
    List<ParsedTranslations> allTranslations,
  ) {
    if (allTranslations.isEmpty) {
      return {};
    }

    // Get all keys from all locales
    final allKeys = <String, Set<String>>{};
    
    for (final translation in allTranslations) {
      allKeys[translation.locale] = _flattenKeys(translation.translations);
    }

    // Find the union of all keys
    final allPossibleKeys = allKeys.values
        .fold<Set<String>>({}, (acc, keys) => acc.union(keys));

    // Check for missing keys in each locale
    final missingKeys = <String, List<String>>{};
    
    for (final entry in allKeys.entries) {
      final locale = entry.key;
      final keys = entry.value;
      final missing = allPossibleKeys.difference(keys).toList()..sort();
      
      if (missing.isNotEmpty) {
        missingKeys[locale] = missing;
      }
    }

    return missingKeys;
  }

  /// Flattens a nested map into a set of dot-notation keys.
  ///
  /// Example: {'app': {'welcome': 'Hello'}} -> {'app.welcome'}
  static Set<String> _flattenKeys(Map<String, dynamic> map, [String prefix = '']) {
    final keys = <String>{};

    for (final entry in map.entries) {
      final key = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';
      
      if (entry.value is Map<String, dynamic>) {
        keys.addAll(_flattenKeys(entry.value, key));
      } else {
        keys.add(key);
      }
    }

    return keys;
  }
}
