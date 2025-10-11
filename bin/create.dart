#!/usr/bin/env dart

/// CLI tool for creating new language files.
library;

import 'dart:io';
import 'dart:convert';
import 'package:mayr_i18n_generation/src/config.dart';
import 'package:mayr_i18n_generation/src/json_parser.dart';
import 'package:path/path.dart' as p;

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart run mayr_i18n_generator:create <locale>');
    print('Example: dart run mayr_i18n_generator:create fr');
    exit(1);
  }

  final newLocale = args[0];

  print('🌍 mayr_i18n_generator - Creating new language file...\n');
  print('📝 Locale: $newLocale\n');

  try {
    // Read configuration
    final config = I18nConfig.findAndRead();

    // Get language directory
    final langDir = config.getAbsoluteLangDirectory();

    // Create directory if it doesn't exist
    final dir = Directory(langDir);
    if (!dir.existsSync()) {
      print('📁 Creating language directory: $langDir');
      dir.createSync(recursive: true);
    }

    // Check if file already exists
    final newFilePath = p.join(langDir, '$newLocale.json');
    final newFile = File(newFilePath);

    if (newFile.existsSync()) {
      print('⚠️  File already exists: $newFilePath');
      print('   Aborting to avoid overwriting existing data.');
      exit(1);
    }

    // Try to find existing translation files to use as template
    Map<String, dynamic> template = {};

    try {
      final translations = JsonParser.parseDirectory(langDir);
      if (translations.isNotEmpty) {
        // Use the first locale as template with empty values
        print('📋 Using ${translations.first.locale}.json as template...');
        template = _createEmptyTemplate(translations.first.translations);
      }
    } catch (e) {
      // No existing files, create an empty template
      print('📋 Creating empty template...');
      template = {
        'app': {'welcome': '', 'logout': ''},
        'errors': {'network': ''},
      };
    }

    // Write the new file
    final encoder = JsonEncoder.withIndent('  ');
    final jsonString = encoder.convert(template);
    newFile.writeAsStringSync('$jsonString\n');

    print('\n✅ Created: $newFilePath');
    print('\n💡 Next steps:');
    print('   1. Open $newFilePath');
    print('   2. Fill in the translation values');
    print(
      '   3. Run `dart run mayr_i18n_generator:generate` to update generated code',
    );
  } catch (e, stackTrace) {
    print('\n❌ Error: $e');
    if (args.contains('--verbose') || args.contains('-v')) {
      print('\nStack trace:');
      print(stackTrace);
    }
    exit(1);
  }
}

/// Creates an empty template from existing translations.
Map<String, dynamic> _createEmptyTemplate(Map<String, dynamic> source) {
  final template = <String, dynamic>{};

  for (final entry in source.entries) {
    if (entry.value is Map<String, dynamic>) {
      template[entry.key] = _createEmptyTemplate(entry.value);
    } else {
      template[entry.key] = '';
    }
  }

  return template;
}
