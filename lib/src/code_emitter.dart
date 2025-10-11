/// Emits Dart code from a translation key tree.
library;

import 'key_tree_builder.dart';

/// Generates Dart code from translation keys.
class CodeEmitter {
  /// Generates a complete Dart file from a key tree.
  ///
  /// [partOf] specifies the file this is a part of (e.g., 'translations.dart').
  static String emitCode(KeyNode tree, String partOf) {
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
    buffer.writeln();

    // Static fields for top-level keys
    for (final entry in tree.children.entries) {
      final key = entry.key;
      final node = entry.value;

      if (node.isLeaf) {
        buffer.writeln("  /// Translation key: '${node.fullPath}'");
        buffer.writeln("  static const String $key = '${node.fullPath}';");
      } else {
        final className = _toClassName(key);
        buffer.writeln("  /// Translation keys under '$key.*'");
        buffer.writeln('  static const $key = $className._();');
      }
    }

    buffer.writeln('}');
    buffer.writeln();

    // Generate nested classes
    for (final entry in tree.children.entries) {
      final node = entry.value;
      if (!node.isLeaf) {
        _emitClass(buffer, node);
        buffer.writeln();
      }
    }

    // Extension method for .tr()
    buffer.writeln('/// Extension to add translation method to String.');
    buffer.writeln('extension I18nTranslationExtension on String {');
    buffer.writeln('  /// Translates this key using the current locale.');
    buffer.writeln('  ///');
    buffer.writeln(
      '  /// [args] - Optional arguments for placeholder replacement.',
    );
    buffer.writeln('  /// Example: "app.welcome".tr(args: {"name": "John"})');
    buffer.writeln('  String tr([Map<String, dynamic>? args]) {');
    buffer.writeln('    // This assumes mayr_i18n is available');
    buffer.writeln('    // Users should implement their own translation logic');
    buffer.writeln('    // or use this with the mayr_i18n package');
    buffer.writeln('    throw UnimplementedError(');
    buffer.writeln("      'Translation method not implemented. '");
    buffer.writeln(
      "      'Please implement this extension or use mayr_i18n package.',",
    );
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln('}');

    return buffer.toString();
  }

  /// Emits a class for a nested key group.
  static void _emitClass(StringBuffer buffer, KeyNode node) {
    final className = _toClassName(node.key);

    buffer.writeln('/// Translation keys under \'${node.fullPath}.*\'');
    buffer.writeln('class $className {');
    buffer.writeln('  const $className._();');
    buffer.writeln();

    // Generate fields for this class
    for (final entry in node.children.entries) {
      final key = entry.key;
      final childNode = entry.value;

      if (childNode.isLeaf) {
        buffer.writeln("  /// Translation key: '${childNode.fullPath}'");
        buffer.writeln("  final String $key = '${childNode.fullPath}';");
      } else {
        final childClassName = _toClassName(key);
        buffer.writeln(
          "  /// Translation keys under '${childNode.fullPath}.*'",
        );
        buffer.writeln('  final $key = const $childClassName._();');
      }
    }

    buffer.writeln('}');

    // Recursively emit nested classes
    for (final childNode in node.children.values) {
      if (!childNode.isLeaf) {
        buffer.writeln();
        _emitClass(buffer, childNode);
      }
    }
  }

  /// Converts a key to a valid class name.
  ///
  /// Example: 'app' -> '_AppKeys', 'error_messages' -> '_ErrorMessagesKeys'
  static String _toClassName(String key) {
    // Convert to PascalCase
    final parts = key.split('_');
    final pascalCase = parts
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
}
