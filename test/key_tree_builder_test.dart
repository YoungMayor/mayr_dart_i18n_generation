import 'package:test/test.dart';
import 'package:mayr_i18n_generation/src/key_tree_builder.dart';

void main() {
  group('KeyTreeBuilder', () {
    test('builds tree from simple flat structure', () {
      final data = {
        'welcome': 'Welcome',
        'logout': 'Goodbye',
      };

      final tree = KeyTreeBuilder.buildTree(data);

      expect(tree.key, equals('root'));
      expect(tree.children, hasLength(2));
      expect(tree.children['welcome']?.isLeaf, isTrue);
      expect(tree.children['welcome']?.fullPath, equals('welcome'));
      expect(tree.children['logout']?.isLeaf, isTrue);
    });

    test('builds tree from nested structure', () {
      final data = {
        'app': {
          'welcome': 'Welcome',
          'logout': 'Goodbye',
        },
        'errors': {
          'network': 'No connection',
        },
      };

      final tree = KeyTreeBuilder.buildTree(data);

      expect(tree.children, hasLength(2));
      expect(tree.children['app']?.isLeaf, isFalse);
      expect(tree.children['app']?.children, hasLength(2));
      expect(tree.children['app']?.children['welcome']?.fullPath, equals('app.welcome'));
      expect(tree.children['errors']?.children['network']?.fullPath, equals('errors.network'));
    });

    test('builds tree from deeply nested structure', () {
      final data = {
        'level1': {
          'level2': {
            'level3': {
              'deep': 'value',
            },
          },
        },
      };

      final tree = KeyTreeBuilder.buildTree(data);

      final level1 = tree.children['level1'];
      expect(level1?.isLeaf, isFalse);
      
      final level2 = level1?.children['level2'];
      expect(level2?.isLeaf, isFalse);
      
      final level3 = level2?.children['level3'];
      expect(level3?.isLeaf, isFalse);
      
      final deep = level3?.children['deep'];
      expect(deep?.isLeaf, isTrue);
      expect(deep?.fullPath, equals('level1.level2.level3.deep'));
    });

    test('merges multiple trees correctly', () {
      final tree1 = KeyTreeBuilder.buildTree({
        'app': {'welcome': 'Welcome'},
      });

      final tree2 = KeyTreeBuilder.buildTree({
        'app': {'logout': 'Goodbye'},
      });

      final merged = KeyTreeBuilder.mergeTrees([tree1, tree2]);

      expect(merged.children['app']?.children, hasLength(2));
      expect(merged.children['app']?.children.keys, containsAll(['welcome', 'logout']));
    });

    test('merges trees with overlapping keys', () {
      final tree1 = KeyTreeBuilder.buildTree({
        'app': {'welcome': 'Welcome', 'title': 'App'},
      });

      final tree2 = KeyTreeBuilder.buildTree({
        'app': {'welcome': 'Bienvenue', 'logout': 'Au revoir'},
      });

      final merged = KeyTreeBuilder.mergeTrees([tree1, tree2]);

      expect(merged.children['app']?.children, hasLength(3));
      expect(merged.children['app']?.children.keys, containsAll(['welcome', 'title', 'logout']));
    });

    test('handles empty tree list when merging', () {
      final merged = KeyTreeBuilder.mergeTrees([]);

      expect(merged.key, equals('root'));
      expect(merged.children, isEmpty);
    });

    test('returns single tree when merging list of one', () {
      final tree = KeyTreeBuilder.buildTree({
        'app': {'welcome': 'Welcome'},
      });

      final merged = KeyTreeBuilder.mergeTrees([tree]);

      expect(merged, equals(tree));
    });

    test('getAllPaths returns all leaf paths', () {
      final tree = KeyTreeBuilder.buildTree({
        'app': {
          'welcome': 'Welcome',
          'logout': 'Goodbye',
        },
        'errors': {
          'network': 'No connection',
        },
      });

      final paths = KeyTreeBuilder.getAllPaths(tree);

      expect(paths, hasLength(3));
      expect(paths, containsAll(['app.welcome', 'app.logout', 'errors.network']));
    });

    test('getAllPaths returns sorted paths', () {
      final tree = KeyTreeBuilder.buildTree({
        'z': {'key': 'value'},
        'a': {'key': 'value'},
        'm': {'key': 'value'},
      });

      final paths = KeyTreeBuilder.getAllPaths(tree);

      expect(paths, equals(['a.key', 'm.key', 'z.key']));
    });

    test('getAllPaths returns empty list for tree with no leaves', () {
      final tree = KeyNode(
        key: 'root',
        children: {},
        isLeaf: false,
        fullPath: '',
      );

      final paths = KeyTreeBuilder.getAllPaths(tree);

      expect(paths, isEmpty);
    });

    test('handles mixed nested and flat keys', () {
      final data = {
        'simple': 'value',
        'nested': {
          'key': 'value',
        },
      };

      final tree = KeyTreeBuilder.buildTree(data);

      expect(tree.children['simple']?.isLeaf, isTrue);
      expect(tree.children['simple']?.fullPath, equals('simple'));
      expect(tree.children['nested']?.isLeaf, isFalse);
      expect(tree.children['nested']?.children['key']?.fullPath, equals('nested.key'));
    });
  });

  group('KeyNode', () {
    test('copyWith creates new instance with updated fields', () {
      final node = KeyNode(
        key: 'original',
        children: {},
        isLeaf: false,
        fullPath: 'path.to.original',
      );

      final copied = node.copyWith(key: 'updated');

      expect(copied.key, equals('updated'));
      expect(copied.fullPath, equals(node.fullPath));
      expect(copied.isLeaf, equals(node.isLeaf));
    });
  });
}
