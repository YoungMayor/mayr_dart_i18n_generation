import 'dart:io';
import 'package:test/test.dart';
import 'package:mayr_i18n_generation/src/json_parser.dart';
import 'package:path/path.dart' as p;

void main() {
  group('JsonParser', () {
    late Directory testDir;

    setUp(() {
      testDir = Directory.systemTemp.createTempSync('json_parser_test_');
    });

    tearDown(() {
      testDir.deleteSync(recursive: true);
    });

    test('parses valid JSON file', () {
      final jsonPath = p.join(testDir.path, 'en.json');
      File(jsonPath).writeAsStringSync('''
{
  "app": {
    "welcome": "Welcome",
    "logout": "Goodbye"
  },
  "errors": {
    "network": "No connection"
  }
}
''');

      final result = JsonParser.parseFile(jsonPath);

      expect(result.locale, equals('en'));
      expect(result.filePath, equals(jsonPath));
      expect(result.translations, isA<Map<String, dynamic>>());
      expect(result.translations['app'], isA<Map<String, dynamic>>());
      expect(result.translations['app']['welcome'], equals('Welcome'));
    });

    test('throws FileSystemException for non-existent file', () {
      expect(
        () => JsonParser.parseFile('/nonexistent/file.json'),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('throws FormatException for invalid JSON', () {
      final jsonPath = p.join(testDir.path, 'invalid.json');
      File(jsonPath).writeAsStringSync('{ invalid json }');

      expect(
        () => JsonParser.parseFile(jsonPath),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when JSON is not an object', () {
      final jsonPath = p.join(testDir.path, 'array.json');
      File(jsonPath).writeAsStringSync('["not", "an", "object"]');

      expect(
        () => JsonParser.parseFile(jsonPath),
        throwsA(isA<FormatException>()),
      );
    });

    test('parses directory with multiple JSON files', () {
      File(
        p.join(testDir.path, 'en.json'),
      ).writeAsStringSync('{"app": {"title": "App"}}');
      File(
        p.join(testDir.path, 'fr.json'),
      ).writeAsStringSync('{"app": {"title": "Application"}}');
      File(
        p.join(testDir.path, 'es.json'),
      ).writeAsStringSync('{"app": {"title": "Aplicación"}}');

      final results = JsonParser.parseDirectory(testDir.path);

      expect(results, hasLength(3));
      expect(results.map((r) => r.locale), containsAll(['en', 'fr', 'es']));
    });

    test('throws FileSystemException for non-existent directory', () {
      expect(
        () => JsonParser.parseDirectory('/nonexistent/directory'),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('throws StateError when no JSON files found', () {
      expect(
        () => JsonParser.parseDirectory(testDir.path),
        throwsA(isA<StateError>()),
      );
    });

    test('validates locales and finds missing keys', () {
      File(p.join(testDir.path, 'en.json')).writeAsStringSync('''
{
  "app": {"welcome": "Welcome", "logout": "Goodbye"},
  "errors": {"network": "No connection"}
}
''');

      File(p.join(testDir.path, 'fr.json')).writeAsStringSync('''
{
  "app": {"welcome": "Bienvenue"},
  "errors": {"network": "Pas de connexion"}
}
''');

      final translations = JsonParser.parseDirectory(testDir.path);
      final missingKeys = JsonParser.validateLocales(translations);

      expect(missingKeys, isNotEmpty);
      expect(missingKeys['fr'], contains('app.logout'));
    });

    test('validates locales returns empty map when all keys match', () {
      File(p.join(testDir.path, 'en.json')).writeAsStringSync('''
{
  "app": {"welcome": "Welcome"},
  "errors": {"network": "No connection"}
}
''');

      File(p.join(testDir.path, 'fr.json')).writeAsStringSync('''
{
  "app": {"welcome": "Bienvenue"},
  "errors": {"network": "Pas de connexion"}
}
''');

      final translations = JsonParser.parseDirectory(testDir.path);
      final missingKeys = JsonParser.validateLocales(translations);

      expect(missingKeys, isEmpty);
    });

    test('handles nested JSON structures correctly', () {
      final jsonPath = p.join(testDir.path, 'en.json');
      File(jsonPath).writeAsStringSync('''
{
  "level1": {
    "level2": {
      "level3": {
        "deep": "value"
      }
    }
  }
}
''');

      final result = JsonParser.parseFile(jsonPath);
      final nested = result.translations['level1']['level2']['level3'];

      expect(nested, isA<Map<String, dynamic>>());
      expect(nested['deep'], equals('value'));
    });
  });
}
