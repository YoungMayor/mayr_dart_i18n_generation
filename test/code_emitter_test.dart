import 'package:test/test.dart';
import 'package:mayr_i18n_generation/src/code_emitter.dart';
import 'package:mayr_i18n_generation/src/key_tree_builder.dart';

void main() {
  group('CodeEmitter', () {
    test('emits code for simple structure', () {
      final tree = KeyTreeBuilder.buildTree({
        'welcome': 'Welcome',
        'logout': 'Goodbye',
      });

      final code = CodeEmitter.emitCode(tree, 'translations.dart');

      expect(code, contains('// GENERATED CODE - DO NOT MODIFY BY HAND'));
      expect(code, contains("part of 'translations.dart';"));
      expect(code, contains('class I18nKeys'));
      expect(code, contains("static const String welcome = 'welcome';"));
      expect(code, contains("static const String logout = 'logout';"));
    });

    test('emits code for nested structure', () {
      final tree = KeyTreeBuilder.buildTree({
        'app': {
          'welcome': 'Welcome',
          'logout': 'Goodbye',
        },
        'errors': {
          'network': 'No connection',
        },
      });

      final code = CodeEmitter.emitCode(tree, 'translations.dart');

      expect(code, contains('class I18nKeys'));
      expect(code, contains('static const app = _AppKeys._();'));
      expect(code, contains('static const errors = _ErrorsKeys._();'));
      expect(code, contains('class _AppKeys'));
      expect(code, contains('class _ErrorsKeys'));
      expect(code, contains("final String welcome = 'app.welcome';"));
      expect(code, contains("final String network = 'errors.network';"));
    });

    test('emits code for deeply nested structure', () {
      final tree = KeyTreeBuilder.buildTree({
        'profile': {
          'details': {
            'age': 'Age',
            'email': 'Email',
          },
        },
      });

      final code = CodeEmitter.emitCode(tree, 'translations.dart');

      expect(code, contains('class _ProfileKeys'));
      expect(code, contains('class _DetailsKeys'));
      expect(code, contains("final String age = 'profile.details.age';"));
      expect(code, contains("final String email = 'profile.details.email';"));
    });

    test('emits extension method for translation', () {
      final tree = KeyTreeBuilder.buildTree({'key': 'value'});

      final code = CodeEmitter.emitCode(tree, 'translations.dart');

      expect(code, contains('extension I18nTranslationExtension on String'));
      expect(code, contains('String tr([Map<String, dynamic>? args])'));
    });

    test('includes documentation comments', () {
      final tree = KeyTreeBuilder.buildTree({
        'app': {
          'welcome': 'Welcome',
        },
      });

      final code = CodeEmitter.emitCode(tree, 'translations.dart');

      expect(code, contains('/// Generated translation keys'));
      expect(code, contains("/// Translation key: 'app.welcome'"));
      expect(code, contains("/// Translation keys under 'app.*'"));
    });

    test('sanitizes invalid identifiers', () {
      expect(CodeEmitter.sanitizeIdentifier('valid_name'), equals('valid_name'));
      expect(CodeEmitter.sanitizeIdentifier('123invalid'), equals('_123invalid'));
      expect(CodeEmitter.sanitizeIdentifier('with-dash'), equals('with_dash'));
      expect(CodeEmitter.sanitizeIdentifier('with.dot'), equals('with_dot'));
      expect(CodeEmitter.sanitizeIdentifier('with space'), equals('with_space'));
    });

    test('validates identifiers correctly', () {
      expect(CodeEmitter.isValidIdentifier('valid'), isTrue);
      expect(CodeEmitter.isValidIdentifier('valid_name'), isTrue);
      expect(CodeEmitter.isValidIdentifier('_private'), isTrue);
      expect(CodeEmitter.isValidIdentifier('name123'), isTrue);
      
      expect(CodeEmitter.isValidIdentifier(''), isFalse);
      expect(CodeEmitter.isValidIdentifier('123invalid'), isFalse);
      expect(CodeEmitter.isValidIdentifier('with-dash'), isFalse);
      expect(CodeEmitter.isValidIdentifier('with.dot'), isFalse);
      expect(CodeEmitter.isValidIdentifier('with space'), isFalse);
    });

    test('handles mixed flat and nested keys', () {
      final tree = KeyTreeBuilder.buildTree({
        'simple': 'value',
        'nested': {
          'key': 'value',
        },
      });

      final code = CodeEmitter.emitCode(tree, 'translations.dart');

      expect(code, contains("static const String simple = 'simple';"));
      expect(code, contains('static const nested = _NestedKeys._();'));
      expect(code, contains('class _NestedKeys'));
    });

    test('emits valid Dart code structure', () {
      final tree = KeyTreeBuilder.buildTree({
        'app': {
          'title': 'App',
          'welcome': 'Welcome',
        },
      });

      final code = CodeEmitter.emitCode(tree, 'translations.dart');

      // Check for proper class structure
      expect(code, contains('class I18nKeys {'));
      expect(code, contains('const I18nKeys._();'));
      expect(code, contains('}'));
      
      // Check for nested class
      expect(code, contains('class _AppKeys {'));
      expect(code, contains('const _AppKeys._();'));
    });

    test('includes ignore_for_file directive', () {
      final tree = KeyTreeBuilder.buildTree({'key': 'value'});

      final code = CodeEmitter.emitCode(tree, 'translations.dart');

      expect(code, contains('// ignore_for_file: constant_identifier_names, non_constant_identifier_names'));
    });
  });
}
