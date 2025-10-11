/// Builds a tree structure from translation keys for code generation.
library;

/// A node in the translation key tree.
class KeyNode {
  /// The key name for this node.
  final String key;

  /// Child nodes (for nested keys).
  final Map<String, KeyNode> children;

  /// Whether this node represents a leaf (actual translation key).
  final bool isLeaf;

  /// The full dot-notation path to this key.
  final String fullPath;

  KeyNode({
    required this.key,
    this.children = const {},
    required this.isLeaf,
    required this.fullPath,
  });

  /// Creates a copy of this node with optional modifications.
  KeyNode copyWith({
    String? key,
    Map<String, KeyNode>? children,
    bool? isLeaf,
    String? fullPath,
  }) {
    return KeyNode(
      key: key ?? this.key,
      children: children ?? this.children,
      isLeaf: isLeaf ?? this.isLeaf,
      fullPath: fullPath ?? this.fullPath,
    );
  }
}

/// Builds a hierarchical tree from flat translation keys.
class KeyTreeBuilder {
  /// Builds a key tree from parsed translation data.
  ///
  /// Example input:
  /// ```dart
  /// {
  ///   'app': {
  ///     'welcome': 'Welcome',
  ///     'logout': 'Goodbye'
  ///   },
  ///   'errors': {
  ///     'network': 'No connection'
  ///   }
  /// }
  /// ```
  ///
  /// Returns a root node with children representing the structure.
  static KeyNode buildTree(Map<String, dynamic> translations) {
    final root = KeyNode(
      key: 'root',
      children: {},
      isLeaf: false,
      fullPath: '',
    );

    _buildTreeRecursive(translations, root, '');

    return root;
  }

  /// Recursively builds the tree structure.
  static void _buildTreeRecursive(
    Map<String, dynamic> data,
    KeyNode parent,
    String prefix,
  ) {
    final children = <String, KeyNode>{};

    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;
      final fullPath = prefix.isEmpty ? key : '$prefix.$key';

      if (value is Map<String, dynamic>) {
        // This is a nested object
        final node = KeyNode(
          key: key,
          children: {},
          isLeaf: false,
          fullPath: fullPath,
        );
        children[key] = node;
        _buildTreeRecursive(value, node, fullPath);
        
        // Update the node with its children
        children[key] = node.copyWith(
          children: node.children,
        );
      } else {
        // This is a leaf node (actual translation)
        children[key] = KeyNode(
          key: key,
          children: {},
          isLeaf: true,
          fullPath: fullPath,
        );
      }
    }

    // Update parent's children
    if (parent.children.isEmpty) {
      parent = parent.copyWith(children: children);
    } else {
      final updatedChildren = Map<String, KeyNode>.from(parent.children)
        ..addAll(children);
      parent = parent.copyWith(children: updatedChildren);
    }
  }

  /// Merges multiple trees into one, taking the union of all keys.
  ///
  /// Useful when multiple locale files should have the same structure.
  static KeyNode mergeTrees(List<KeyNode> trees) {
    if (trees.isEmpty) {
      return KeyNode(
        key: 'root',
        children: {},
        isLeaf: false,
        fullPath: '',
      );
    }

    if (trees.length == 1) {
      return trees.first;
    }

    final root = KeyNode(
      key: 'root',
      children: {},
      isLeaf: false,
      fullPath: '',
    );

    final allChildren = <String, KeyNode>{};

    for (final tree in trees) {
      for (final entry in tree.children.entries) {
        if (allChildren.containsKey(entry.key)) {
          // Merge children recursively
          if (!entry.value.isLeaf && !allChildren[entry.key]!.isLeaf) {
            allChildren[entry.key] = _mergeNodes(
              allChildren[entry.key]!,
              entry.value,
            );
          }
        } else {
          allChildren[entry.key] = entry.value;
        }
      }
    }

    return root.copyWith(children: allChildren);
  }

  /// Merges two nodes recursively.
  static KeyNode _mergeNodes(KeyNode node1, KeyNode node2) {
    if (node1.isLeaf || node2.isLeaf) {
      return node1; // Keep the first one if either is a leaf
    }

    final mergedChildren = Map<String, KeyNode>.from(node1.children);

    for (final entry in node2.children.entries) {
      if (mergedChildren.containsKey(entry.key)) {
        mergedChildren[entry.key] = _mergeNodes(
          mergedChildren[entry.key]!,
          entry.value,
        );
      } else {
        mergedChildren[entry.key] = entry.value;
      }
    }

    return node1.copyWith(children: mergedChildren);
  }

  /// Gets all leaf paths from a tree.
  ///
  /// Returns a list of dot-notation paths like ['app.welcome', 'app.logout'].
  static List<String> getAllPaths(KeyNode tree) {
    final paths = <String>[];
    _collectPaths(tree, paths);
    return paths..sort();
  }

  /// Recursively collects all leaf paths.
  static void _collectPaths(KeyNode node, List<String> paths) {
    if (node.isLeaf) {
      paths.add(node.fullPath);
    } else {
      for (final child in node.children.values) {
        _collectPaths(child, paths);
      }
    }
  }
}
