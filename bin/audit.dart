#!/usr/bin/env dart
/// CLI tool for auditing translation key usage in code.

import 'dart:io';
import 'package:mayr_i18n_generation/src/config.dart';
import 'package:mayr_i18n_generation/src/json_parser.dart';
import 'package:path/path.dart' as p;

void main(List<String> args) async {
  print('🔍 mayr_i18n_generator - Auditing translation key usage...\n');

  try {
    // Read configuration
    final config = I18nConfig.findAndRead();
    print('📁 Language directory: ${config.langDirectory}\n');

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

    // Get all defined keys
    final definedKeys = <String>{};
    for (final translation in translations) {
      definedKeys.addAll(_flattenKeys(translation.translations));
    }

    print('   Found ${definedKeys.length} defined key(s)\n');

    // Scan codebase for key usage
    print('🔍 Scanning codebase for key usage...');
    final libDir = p.join(Directory.current.path, 'lib');
    final usedKeys = _scanForKeys(libDir, definedKeys);

    print('   Found ${usedKeys.length} used key(s)\n');

    // Find unused keys
    final unusedKeys = definedKeys.difference(usedKeys).toList()..sort();
    
    // Find undefined keys
    final undefinedKeys = usedKeys.difference(definedKeys).toList()..sort();

    // Report results
    print('📊 Audit Results:\n');

    if (undefinedKeys.isEmpty && unusedKeys.isEmpty) {
      print('✅ Perfect! All keys are defined and used.\n');
      exit(0);
    }

    var hasIssues = false;

    if (undefinedKeys.isNotEmpty) {
      hasIssues = true;
      print('⚠️  Keys used in code but NOT defined in JSON (${undefinedKeys.length}):');
      for (final key in undefinedKeys) {
        print('   - $key');
      }
      print('');
    }

    if (unusedKeys.isNotEmpty) {
      print('ℹ️  Keys defined in JSON but NOT used in code (${unusedKeys.length}):');
      for (final key in unusedKeys) {
        print('   - $key');
      }
      print('');
      print('💡 Note: Unused keys are not necessarily a problem - they might be used in other parts of your app.');
    }

    if (hasIssues) {
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

/// Scans Dart files for translation key usage.
Set<String> _scanForKeys(String directory, Set<String> definedKeys) {
  final usedKeys = <String>{};
  final dir = Directory(directory);

  if (!dir.existsSync()) {
    return usedKeys;
  }

  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart') && !entity.path.endsWith('.g.dart')) {
      final content = entity.readAsStringSync();
      
      // Look for string literals that match defined keys
      for (final key in definedKeys) {
        // Check various patterns:
        // - 'key' or "key"
        // - I18nKeys.key.path
        if (content.contains("'$key'") || 
            content.contains('"$key"') ||
            content.contains(key.replaceAll('.', '.'))) {
          usedKeys.add(key);
        }
      }
    }
  }

  return usedKeys;
}
