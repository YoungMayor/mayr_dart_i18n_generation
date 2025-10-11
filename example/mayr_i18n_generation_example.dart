/// Example demonstrating mayr_i18n_generation usage.
///
/// This example shows how to use the generated translation keys.
library;

import 'lib/translations.dart';

void main() {
  print('🌍 mayr_i18n_generation Example\n');

  // The generated code provides type-safe access to translation keys
  print('Available translation keys:');
  print('');

  // Top-level keys
  print('App keys:');
  print('  - ${I18nKeys.app.title}');
  print('  - ${I18nKeys.app.welcome}');
  print('  - ${I18nKeys.app.logout}');
  print('  - ${I18nKeys.app.settings}');
  print('');

  // Auth keys
  print('Auth keys:');
  print('  - ${I18nKeys.auth.login}');
  print('  - ${I18nKeys.auth.signup}');
  print('  - ${I18nKeys.auth.email}');
  print('  - ${I18nKeys.auth.password}');
  print('  - ${I18nKeys.auth.forgotPassword}');
  print('');

  // Error keys
  print('Error keys:');
  print('  - ${I18nKeys.errors.network}');
  print('  - ${I18nKeys.errors.invalidEmail}');
  print('  - ${I18nKeys.errors.passwordTooShort}');
  print('  - ${I18nKeys.errors.unknown}');
  print('');

  // Nested profile keys
  print('Profile keys:');
  print('  - ${I18nKeys.profile.name}');
  print('  - ${I18nKeys.profile.bio}');
  print('  - ${I18nKeys.profile.details.age}');
  print('  - ${I18nKeys.profile.details.email}');
  print('  - ${I18nKeys.profile.details.phone}');
  print('');

  print('✅ All keys are type-safe and provide autocomplete!');
  print('');
  print(
    '💡 In a real app, you would use these keys with the mayr_i18n package:',
  );
  print('   I18nKeys.app.welcome.tr(args: {"name": "Mayor"})');
  print('   // => "Welcome Mayor!" (in English)');
  print('   // => "Bienvenue Mayor!" (in French)');
}
