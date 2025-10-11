/// Main generator for i18n code generation using build_runner.
library;

import 'dart:async';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';

import 'config.dart';
import 'json_parser.dart';
import 'key_tree_builder.dart';
import 'code_emitter.dart';

/// Generator for i18n translation keys.
class I18nGenerator extends Generator {
  @override
  FutureOr<String?> generate(LibraryReader library, BuildStep buildStep) async {
    // Check if this library has a part directive for .g.dart
    if (!_hasPartDirective(library)) {
      return null;
    }

    try {
      // Read configuration
      final config = I18nConfig.findAndRead();
      
      // Get the language directory path relative to the build
      final langDir = config.getAbsoluteLangDirectory();

      // Parse all JSON files
      final translations = JsonParser.parseDirectory(langDir);

      if (translations.isEmpty) {
        log.warning('No translation files found in $langDir');
        return null;
      }

      // Build key trees from all translations
      final trees = translations.map((t) {
        return KeyTreeBuilder.buildTree(t.translations);
      }).toList();

      // Merge all trees to get the complete key structure
      final mergedTree = KeyTreeBuilder.mergeTrees(trees);

      // Get the part file name from the library
      final partFileName = _getPartFileName(library);

      // Generate the code
      final generatedCode = CodeEmitter.emitCode(mergedTree, partFileName);

      return generatedCode;
    } catch (e, stackTrace) {
      log.severe('Error generating i18n code: $e', e, stackTrace);
      return null;
    }
  }

  /// Checks if the library has a part directive for a .g.dart file.
  bool _hasPartDirective(LibraryReader library) {
    final element = library.element;
    
    for (final part in element.parts) {
      if (part.uri.endsWith('.g.dart')) {
        return true;
      }
    }
    
    return false;
  }

  /// Gets the source file name from the library.
  String _getPartFileName(LibraryReader library) {
    final element = library.element;
    final source = element.source;
    final uri = source.uri;
    
    // Get just the filename from the URI
    final segments = uri.pathSegments;
    if (segments.isNotEmpty) {
      return segments.last;
    }
    
    return 'translations.dart';
  }
}

/// Builder factory for the i18n generator.
Builder i18nBuilder(BuilderOptions options) {
  return LibraryBuilder(
    I18nGenerator(),
    generatedExtension: '.g.dart',
  );
}
