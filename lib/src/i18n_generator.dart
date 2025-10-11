/// Main generator for i18n code generation using build_runner.
library;

import 'dart:async';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'config.dart';
import 'json_parser.dart';
import 'key_tree_builder.dart';
import 'code_emitter.dart';

/// Generator for i18n translation keys.
class I18nGenerator extends Generator {
  @override
  FutureOr<String?> generate(LibraryReader library, BuildStep buildStep) async {
    // Read generator configuration to check if we should process this file
    final generatorConfig = GeneratorConfig.findAndRead();
    
    // Check if this file matches the configured output_file
    final inputPath = buildStep.inputId.path;
    final normalizedOutputFile = generatorConfig.outputFile.replaceAll('\\', '/');
    
    if (!inputPath.endsWith(normalizedOutputFile)) {
      log.fine(
        'Skipping ${buildStep.inputId} - not the configured output_file ($normalizedOutputFile)',
      );
      return null;
    }
    
    // Check if this library has a part directive for .g.dart
    if (!_hasPartDirective(library)) {
      log.info('Skipping ${buildStep.inputId} - no .g.dart part directive');
      return null;
    }

    log.info('Generating i18n code for ${buildStep.inputId}');

    try {
      // Read i18n configuration
      final config = I18nConfig.findAndRead();
      log.info(
        'Config loaded: lang_directory=${config.langDirectory}, default_locale=${config.defaultLocale}',
      );
      log.info('Generator config: output_file=${generatorConfig.outputFile}');

      // Get the language directory path
      final langDir = config.getAbsoluteLangDirectory();
      log.info('Looking for translations in: $langDir');

      // Parse all JSON files
      final translations = JsonParser.parseDirectory(langDir);

      if (translations.isEmpty) {
        log.warning('No translation files found in $langDir');
        return null;
      }

      log.info('Found ${translations.length} translation file(s)');

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

      log.info('Generated ${generatedCode.length} characters of code');
      return generatedCode;
    } catch (e, stackTrace) {
      log.severe('Error generating i18n code: $e', e, stackTrace);
      return null;
    }
  }

  /// Checks if the library has a part directive for a .g.dart file.
  bool _hasPartDirective(LibraryReader library) {
    final element = library.element;

    // Check the library source for part directives
    // This is more reliable than trying to navigate the AST
    try {
      final source = element.source;

      final contents = source.contents.data;

      // Look for part directive with .g.dart
      // Simple string search is sufficient
      final hasPartDirective =
          contents.contains('.g.dart') &&
          (contents.contains("part '") || contents.contains('part "'));

      log.fine(
        'Checking for .g.dart part directive in ${element.source.uri}: $hasPartDirective',
      );

      return hasPartDirective;
    } catch (e) {
      log.warning('Error checking for part directive: $e');
      return false;
    }
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
  return LibraryBuilder(I18nGenerator(), generatedExtension: '.g.dart');
}
