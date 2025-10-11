import 'dart:io';
import 'package:test/test.dart';
import 'package:mayr_i18n_generation/src/config.dart';
import 'package:path/path.dart' as p;

void main() {
  group('I18nConfig', () {
    test('has correct default values', () {
      const config = I18nConfig.defaults;
      
      expect(config.langDirectory, equals('assets/lang'));
      expect(config.defaultLocale, equals('en'));
    });

    test('reads configuration from pubspec.yaml', () {
      final testDir = Directory.systemTemp.createTempSync('config_test_');
      
      try {
        // Create a test pubspec.yaml
        final pubspecPath = p.join(testDir.path, 'pubspec.yaml');
        File(pubspecPath).writeAsStringSync('''
name: test_project
version: 1.0.0

mayr_i18n:
  lang_directory: translations
  default_locale: fr
''');

        final config = I18nConfig.fromPubspec(pubspecPath);
        
        expect(config.langDirectory, equals('translations'));
        expect(config.defaultLocale, equals('fr'));
      } finally {
        testDir.deleteSync(recursive: true);
      }
    });

    test('returns defaults when pubspec.yaml does not exist', () {
      final config = I18nConfig.fromPubspec('/nonexistent/pubspec.yaml');
      
      expect(config.langDirectory, equals(I18nConfig.defaults.langDirectory));
      expect(config.defaultLocale, equals(I18nConfig.defaults.defaultLocale));
    });

    test('returns defaults when mayr_i18n section is missing', () {
      final testDir = Directory.systemTemp.createTempSync('config_test_');
      
      try {
        final pubspecPath = p.join(testDir.path, 'pubspec.yaml');
        File(pubspecPath).writeAsStringSync('''
name: test_project
version: 1.0.0
''');

        final config = I18nConfig.fromPubspec(pubspecPath);
        
        expect(config.langDirectory, equals(I18nConfig.defaults.langDirectory));
        expect(config.defaultLocale, equals(I18nConfig.defaults.defaultLocale));
      } finally {
        testDir.deleteSync(recursive: true);
      }
    });

    test('returns partial config when only some values are set', () {
      final testDir = Directory.systemTemp.createTempSync('config_test_');
      
      try {
        final pubspecPath = p.join(testDir.path, 'pubspec.yaml');
        File(pubspecPath).writeAsStringSync('''
name: test_project
version: 1.0.0

mayr_i18n:
  lang_directory: custom_lang
''');

        final config = I18nConfig.fromPubspec(pubspecPath);
        
        expect(config.langDirectory, equals('custom_lang'));
        expect(config.defaultLocale, equals(I18nConfig.defaults.defaultLocale));
      } finally {
        testDir.deleteSync(recursive: true);
      }
    });

    test('getAbsoluteLangDirectory returns correct path', () {
      const config = I18nConfig(
        langDirectory: 'assets/lang',
        defaultLocale: 'en',
      );
      
      final testPath = '/test/project';
      final absolutePath = config.getAbsoluteLangDirectory(testPath);
      
      expect(absolutePath, contains('assets'));
      expect(absolutePath, contains('lang'));
    });

    test('toString returns readable representation', () {
      const config = I18nConfig(
        langDirectory: 'assets/lang',
        defaultLocale: 'en',
      );
      
      final str = config.toString();
      
      expect(str, contains('assets/lang'));
      expect(str, contains('en'));
    });
  });
}
