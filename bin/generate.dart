#!/usr/bin/env dart
/// CLI tool for generating i18n translation keys.

import 'dart:io';
import 'package:mayr_i18n_generation/src/config.dart';
import 'package:mayr_i18n_generation/src/json_parser.dart';
import 'package:mayr_i18n_generation/src/key_tree_builder.dart';
import 'package:mayr_i18n_generation/src/code_emitter.dart';
import 'package:path/path.dart' as p;

void main(List<String> args) async {
  print('🌍 mayr_i18n_generator - Generating translation keys...\n');

  try {
    // Read configuration
    final config = I18nConfig.findAndRead();
    print('📁 Language directory: ${config.langDirectory}');
    print('🌐 Default locale: ${config.defaultLocale}\n');

    // Get language directory
    final langDir = config.getAbsoluteLangDirectory();

    if (!Directory(langDir).existsSync()) {
      print('❌ Error: Language directory not found: $langDir');
      print('   Please create it and add JSON translation files.');
      exit(1);
    }

    // Parse all JSON files
    print('📖 Parsing translation files...');
    final translations = JsonParser.parseDirectory(langDir);

    if (translations.isEmpty) {
      print('❌ Error: No JSON translation files found in $langDir');
      exit(1);
    }

    print('   Found ${translations.length} locale(s): ${translations.map((t) => t.locale).join(", ")}');

    // Build key trees
    print('\n🌲 Building key tree...');
    final trees = translations.map((t) {
      return KeyTreeBuilder.buildTree(t.translations);
    }).toList();

    final mergedTree = KeyTreeBuilder.mergeTrees(trees);
    final allPaths = KeyTreeBuilder.getAllPaths(mergedTree);
    print('   Found ${allPaths.length} translation key(s)');

    // Find dart files with part directives
    print('\n🔍 Looking for Dart files with part directives...');
    final dartFiles = _findDartFilesWithPartDirective();

    if (dartFiles.isEmpty) {
      print('⚠️  No Dart files with .g.dart part directives found.');
      print('   Create a file like lib/translations.dart with:');
      print('   part \'translations.g.dart\';');
      exit(0);
    }

    print('   Found ${dartFiles.length} file(s)');

    // Generate code for each file
    for (final dartFile in dartFiles) {
      final fileName = p.basename(dartFile);
      final generatedFile = dartFile.replaceAll('.dart', '.g.dart');
      
      print('\n✨ Generating code for $fileName...');
      final code = CodeEmitter.emitCode(mergedTree, fileName);

      File(generatedFile).writeAsStringSync(code);
      print('   ✅ Generated: $generatedFile');
    }

    print('\n✅ Code generation complete!');
    print('\n💡 Tip: You can also use `dart run build_runner build` for automatic generation.');
  } catch (e, stackTrace) {
    print('\n❌ Error: $e');
    if (args.contains('--verbose') || args.contains('-v')) {
      print('\nStack trace:');
      print(stackTrace);
    }
    exit(1);
  }
}

/// Finds all Dart files with .g.dart part directives.
List<String> _findDartFilesWithPartDirective([String? startPath]) {
  startPath ??= p.join(Directory.current.path, 'lib');
  
  final libDir = Directory(startPath);
  if (!libDir.existsSync()) {
    return [];
  }

  final dartFiles = <String>[];
  
  for (final entity in libDir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart') && !entity.path.endsWith('.g.dart')) {
      final content = entity.readAsStringSync();
      if (content.contains(RegExp(r"part\s+['\"].*\.g\.dart['\"]"))) {
        dartFiles.add(entity.path);
      }
    }
  }

  return dartFiles;
}
