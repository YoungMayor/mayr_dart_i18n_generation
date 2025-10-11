# Contributing to mayr_i18n_generation

Thank you for considering contributing to `mayr_i18n_generation`! We appreciate your interest in making this package better.

## 🤝 How to Contribute

### Reporting Issues

If you find a bug or have a feature request:

1. Check if the issue already exists in [GitHub Issues](https://github.com/YoungMayor/mayr_dart_i18n_generation/issues)
2. If not, create a new issue with:
   - Clear title and description
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - Dart/Flutter version and OS
   - Code samples when applicable

### Pull Requests

We welcome pull requests! Here's how to contribute code:

1. **Fork the repository** and create a new branch from `main`
2. **Make your changes** following our coding standards
3. **Add tests** for new features or bug fixes
4. **Run tests** to ensure everything passes: `dart test`
5. **Update documentation** if you changed public APIs
6. **Commit your changes** with clear commit messages
7. **Submit a pull request** with a description of your changes

### Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/mayr_dart_i18n_generation.git
cd mayr_dart_i18n_generation

# Get dependencies
dart pub get

# Run tests
dart test

# Run example
cd example
dart pub get
dart run mayr_i18n_generation:generate
dart run mayr_i18n_generation_example.dart
```

## 📋 Coding Standards

### Code Style

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `dart format` to format your code
- Run `dart analyze` to check for issues
- Keep functions focused and under 50 lines when possible
- Add dartdoc comments to all public APIs

### Testing

- Write tests for all new features
- Ensure existing tests pass
- Aim for high code coverage
- Test edge cases and error conditions

### Documentation

- Update the README.md if you add new features
- Add dartdoc comments to public classes and methods
- Include usage examples in documentation
- Update CHANGELOG.md with your changes

## 🎯 Areas for Contribution

We especially welcome contributions in these areas:

- **New CLI commands** - Additional utilities for managing translations
- **Performance improvements** - Making generation faster
- **Better error messages** - More helpful feedback to users
- **Documentation** - Examples, tutorials, guides
- **Bug fixes** - Help us squash bugs!
- **Tests** - Increase test coverage

## 🐛 Reporting Security Issues

If you discover a security vulnerability, please email security@mayrlabs.com instead of creating a public issue.

## 📜 Code of Conduct

This project follows the [Dart Code of Conduct](https://dart.dev/community/code-of-conduct). By participating, you're expected to uphold this code.

## ❓ Questions?

If you have questions about contributing, feel free to:

- Open a [discussion](https://github.com/YoungMayor/mayr_dart_i18n_generation/discussions)
- Contact us through GitHub issues
- Reach out to the maintainers

## 🌟 Recognition

Contributors will be:
- Listed in our README.md
- Credited in release notes
- Thanked publicly for their contributions

Thank you for helping make `mayr_i18n_generation` better! 🚀
