#!/usr/bin/env dart
/// CLI tool for verifying translation keys across locales.

import 'dart:io';
import 'package:mayr_i18n_generation/src/config.dart';
import 'package:mayr_i18n_generation/src/json_parser.dart';

void main(List<String> args) async {
  print('🔍 mayr_i18n_generator - Verifying translation keys...\n');

  try {
    // Read configuration
    final config = I18nConfig.findAndRead();
    print('📁 Language directory: ${config.langDirectory}');
    print('🌐 Default locale: ${config.defaultLocale}\n');

    // Get language directory
    final langDir = config.getAbsoluteLangDirectory();

    if (!Directory(langDir).existsSync()) {
      print('❌ Error: Language directory not found: $langDir');
      exit(1);
    }

    // Parse all JSON files
    print('📖 Parsing translation files...');
    final translations = JsonParser.parseDirectory(langDir);

    if (translations.isEmpty) {
      print('❌ Error: No JSON translation files found in $langDir');
      exit(1);
    }

    print('   Found ${translations.length} locale(s): ${translations.map((t) => t.locale).join(", ")}\n');

    // Validate locales
    print('🔍 Checking for missing keys...');
    final missingKeys = JsonParser.validateLocales(translations);

    if (missingKeys.isEmpty) {
      print('✅ All locales have the same keys!\n');
      
      // Show key count
      final firstLocale = translations.first;
      final keyCount = _countKeys(firstLocale.translations);
      print('📊 Total keys: $keyCount');
      exit(0);
    }

    // Report missing keys
    print('⚠️  Found missing keys:\n');
    
    var hasErrors = false;
    for (final entry in missingKeys.entries) {
      final locale = entry.key;
      final missing = entry.value;
      
      hasErrors = true;
      print('❌ Locale "$locale" is missing ${missing.length} key(s):');
      for (final key in missing) {
        print('   - $key');
      }
      print('');
    }

    if (hasErrors) {
      print('💡 Tip: Run `dart run mayr_i18n_generator:sync` to add missing keys automatically.');
      exit(1);
    }
  } catch (e, stackTrace) {
    print('\n❌ Error: $e');
    if (args.contains('--verbose') || args.contains('-v')) {
      print('\nStack trace:');
      print(stackTrace);
    }
    exit(1);
  }
}

/// Counts the number of leaf keys in a translation map.
int _countKeys(Map<String, dynamic> map) {
  var count = 0;
  
  for (final value in map.values) {
    if (value is Map<String, dynamic>) {
      count += _countKeys(value);
    } else {
      count++;
    }
  }
  
  return count;
}
