/// Emits Dart code from a translation key tree.
library;

import 'key_tree_builder.dart';

/// Generates Dart code from translation keys.
class CodeEmitter {
  /// Generates a complete Dart file from a key tree.
  ///
  /// [partOf] specifies the file this is a part of (e.g., 'translations.dart').
  /// [defaultValues] is an optional map of full dot-path -> value for the
  /// default locale. When provided, leaf fields will include the default
  /// locale value in their doc comments instead of the raw key path.
  static String emitCode(
    KeyNode tree,
    String partOf, {
    Map<String, String>? defaultValues,
  }) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln(
      '// ignore_for_file: constant_identifier_names, non_constant_identifier_names',
    );
    buffer.writeln();
    buffer.writeln("part of '$partOf';");
    buffer.writeln();

    // Main I18nKeys class
    buffer.writeln('/// Generated translation keys for type-safe access.');
    buffer.writeln('class I18nKeys {');
    buffer.writeln('  const I18nKeys._();');

    // Static fields for top-level keys
    for (final entry in tree.children.entries) {
      final key = entry.key;
      final camelKey = _toCamelCase(key);
      final node = entry.value;

      buffer.writeln();

      if (node.isLeaf) {
        final doc = _valueDoc(defaultValues, node.fullPath);

        buffer.writeln('  $doc');
        buffer.writeln("  static const String $camelKey = '${node.fullPath}';");
      } else {
        final className = _toClassNameFromPath(node.fullPath);

        buffer.writeln("  /// Translation keys under '$key.*'");
        buffer.writeln('  static const $camelKey = $className._();');
      }
    }

    buffer.writeln('}');

    // Generate nested classes
    for (final entry in tree.children.entries) {
      final node = entry.value;
      if (!node.isLeaf) {
        buffer.writeln();
        _emitClass(buffer, node, defaultValues);
      }
    }

    return buffer.toString();
  }

  /// Emits a class for a nested key group.
  static void _emitClass(
    StringBuffer buffer,
    KeyNode node, [
    Map<String, String>? defaultValues,
  ]) {
    final className = _toClassNameFromPath(node.fullPath);

    buffer.writeln('/// Translation keys under \'${node.fullPath}.*\'');
    buffer.writeln('class $className {');
    buffer.writeln('  const $className._();');

    // Generate fields for this class
    for (final entry in node.children.entries) {
      final key = entry.key;
      final camelKey = _toCamelCase(key);
      final childNode = entry.value;

      buffer.writeln();

      if (childNode.isLeaf) {
        final doc = _valueDoc(defaultValues, childNode.fullPath);

        buffer.writeln('  $doc');
        buffer.writeln("  final String $camelKey = '${childNode.fullPath}';");
      } else {
        final childClassName = _toClassNameFromPath(childNode.fullPath);

        buffer.writeln(
          "  /// Translation keys under '${childNode.fullPath}.*'",
        );
        buffer.writeln('  final $camelKey = const $childClassName._();');
      }
    }

    buffer.writeln('}');

    // Recursively emit nested classes
    for (final childNode in node.children.values) {
      if (!childNode.isLeaf) {
        buffer.writeln();
        _emitClass(buffer, childNode, defaultValues);
      }
    }
  }

  /// Converts a full path to a valid class name.
  ///
  /// Uses the full path to ensure uniqueness and avoid naming conflicts.
  /// Example: 'profile.details' -> '_ProfileDetailsKeys'
  ///          'user.details' -> '_UserDetailsKeys'
  static String _toClassNameFromPath(String path) {
    // Split by dots and underscores to get all parts
    final pathParts = path.split('.');
    final allParts = <String>[];

    for (final part in pathParts) {
      allParts.addAll(part.split('_'));
    }

    // Convert to PascalCase
    final pascalCase = allParts
        .map(
          (part) =>
              part.isEmpty ? '' : part[0].toUpperCase() + part.substring(1),
        )
        .join();

    return '_${pascalCase}Keys';
  }

  /// Validates that a string is a valid Dart identifier.
  static bool isValidIdentifier(String name) {
    if (name.isEmpty) return false;

    // Check if starts with letter or underscore
    final firstChar = name[0];
    if (!RegExp(r'[a-zA-Z_]').hasMatch(firstChar)) {
      return false;
    }

    // Check if rest are letters, digits, or underscores
    return RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$').hasMatch(name);
  }

  /// Sanitizes a key to be a valid Dart identifier.
  ///
  /// Replaces invalid characters with underscores.
  static String sanitizeIdentifier(String key) {
    if (isValidIdentifier(key)) {
      return key;
    }

    // Replace invalid characters
    var sanitized = key.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');

    // Ensure it starts with a letter or underscore
    if (!RegExp(r'^[a-zA-Z_]').hasMatch(sanitized[0])) {
      sanitized = '_$sanitized';
    }

    return sanitized;
  }

  /// Builds a doc comment line for a given fullPath using [defaultValues].
  /// Falls back to the original key path if no value is available.
  static String _valueDoc(Map<String, String>? defaultValues, String fullPath) {
    final val = defaultValues?[fullPath];

    if (val != null) {
      return "/// _${fullPath}_\n  /// ### ${_escapeDoc(val)}";
    }

    return "/// Translation key: '$fullPath'";
  }

  /// Escapes triple slashes and ensures safe single-line doc comments.
  static String _escapeDoc(String value) {
    // Replace CR/LF with spaces to keep single-line docs
    var v = value.replaceAll(RegExp(r'[\r\n]+'), ' ').trim();
    // Avoid starting with triple slashes conflicts or comment closers
    v = v.replaceAll('///', '///');
    return v;
  }

  static String _toCamelCase(String snakeCase) {
    return snakeCase.split('_').map((word) {
      // Capitalize the first letter of each word except the first one
      if (word == snakeCase.split('_').first) {
        return word;
      }
      return word[0].toUpperCase() + word.substring(1);
    }).join();
  }
}
