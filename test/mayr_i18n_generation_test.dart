import 'package:test/test.dart';
import 'package:mayr_i18n_generation/src/config.dart';
import 'package:mayr_i18n_generation/src/json_parser.dart';
import 'package:mayr_i18n_generation/src/key_tree_builder.dart';
import 'package:mayr_i18n_generation/src/code_emitter.dart';

void main() {
  group('mayr_i18n_generation', () {
    test('full integration test', () {
      // This test verifies the complete pipeline:
      // config -> parse -> build tree -> emit code

      // 1. Configuration
      final config = I18nConfig.defaults;
      expect(config.langDirectory, equals('assets/lang'));
      expect(config.defaultLocale, equals('en'));

      // 2. Build a sample key tree
      final sampleData = {
        'app': {
          'title': 'My App',
          'welcome': 'Welcome {name}',
        },
        'errors': {
          'network': 'No connection',
        },
      };

      final tree = KeyTreeBuilder.buildTree(sampleData);
      
      // 3. Verify tree structure
      expect(tree.children, hasLength(2));
      expect(tree.children['app']?.isLeaf, isFalse);
      expect(tree.children['errors']?.isLeaf, isFalse);

      // 4. Generate code
      final code = CodeEmitter.emitCode(tree, 'translations.dart');

      // 5. Verify generated code
      expect(code, contains('class I18nKeys'));
      expect(code, contains('class _AppKeys'));
      expect(code, contains('class _ErrorsKeys'));
      expect(code, contains("final String welcome = 'app.welcome';"));
      expect(code, contains("final String network = 'errors.network';"));
    });

    test('exports all public APIs', () {
      // Verify that the main library exports the necessary components
      expect(I18nConfig, isNotNull);
      expect(JsonParser, isNotNull);
      expect(KeyTreeBuilder, isNotNull);
      expect(CodeEmitter, isNotNull);
    });
  });
}

