#!/usr/bin/env dart
/// CLI tool for syncing translation keys across locales.

import 'dart:io';
import 'dart:convert';
import 'package:mayr_i18n_generation/src/config.dart';
import 'package:mayr_i18n_generation/src/json_parser.dart';

void main(List<String> args) async {
  print('🔄 mayr_i18n_generator - Syncing translation keys...\n');

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
      print('✅ All locales already have the same keys!\n');
      exit(0);
    }

    // Get all possible keys
    final allKeys = <String>{};
    for (final translation in translations) {
      allKeys.addAll(_flattenKeys(translation.translations));
    }

    print('📊 Total unique keys: ${allKeys.length}\n');

    // Sync missing keys
    print('🔄 Syncing missing keys...\n');
    
    var updatedCount = 0;
    for (final translation in translations) {
      if (missingKeys.containsKey(translation.locale)) {
        final missing = missingKeys[translation.locale]!;
        print('📝 Adding ${missing.length} key(s) to ${translation.locale}.json...');
        
        // Read the current data
        final updatedData = Map<String, dynamic>.from(translation.translations);
        
        // Add missing keys with empty values
        for (final key in missing) {
          _setNestedValue(updatedData, key, '');
        }
        
        // Write back to file
        final encoder = JsonEncoder.withIndent('  ');
        final jsonString = encoder.convert(updatedData);
        File(translation.filePath).writeAsStringSync('$jsonString\n');
        
        updatedCount++;
        print('   ✅ Updated ${translation.filePath}');
      }
    }

    print('\n✅ Sync complete! Updated $updatedCount file(s).');
    print('💡 Tip: Fill in the empty translation values in your JSON files.');
  } catch (e, stackTrace) {
    print('\n❌ Error: $e');
    if (args.contains('--verbose') || args.contains('-v')) {
      print('\nStack trace:');
      print(stackTrace);
    }
    exit(1);
  }
}

/// Flattens a nested map into dot-notation keys.
Set<String> _flattenKeys(Map<String, dynamic> map, [String prefix = '']) {
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

/// Sets a value in a nested map using dot notation.
void _setNestedValue(Map<String, dynamic> map, String key, dynamic value) {
  final parts = key.split('.');
  
  if (parts.length == 1) {
    map[key] = value;
    return;
  }

  var current = map;
  for (var i = 0; i < parts.length - 1; i++) {
    final part = parts[i];
    if (!current.containsKey(part)) {
      current[part] = <String, dynamic>{};
    }
    current = current[part] as Map<String, dynamic>;
  }

  current[parts.last] = value;
}
