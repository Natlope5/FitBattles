import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomLocalizations {
  final Locale locale;

  CustomLocalizations(this.locale);

  static CustomLocalizations? of(BuildContext context) {
    return Localizations.of<CustomLocalizations>(context, CustomLocalizations);
  }

  // Define custom localized strings
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'emptyFieldsError': 'Please fill in all fields.',
      'unexpectedError': 'An unexpected error occurred. Please try again.',
      'signupPrompt': "Don't have an account? Sign up here.",
      'userNotFoundError': 'User not found.',
      'wrongPasswordError': 'Wrong Password, Please try again!',
      'defaultError': 'Error occurred, please try again.',
      'accountManagement': 'Account Management',
      'logoutButton': 'Logout',
      'notificationSettings': 'Notification Settings',
      'privacyPolicy': 'Privacy Policy',
    },
    'es': {
      'emptyFieldsError': 'Por favor, rellena todos los campos.',
      'unexpectedError': 'Ocurrió un error inesperado. Inténtalo de nuevo.',
      'signupPrompt': '¿No tienes una cuenta? Regístrate aquí.',
      'userNotFoundError': 'Usuario no encontrado.',
      'wrongPasswordError': 'Contraseña incorrecta, ¡inténtalo de nuevo!',
      'defaultError': 'Ocurrió un error, por favor intenta de nuevo.',
      'accountManagement': 'Gestión de cuenta',
      'logoutButton': 'Cerrar sesión',
      'notificationSettings': 'Configuración de notificaciones',
      'privacyPolicy': 'Política de privacidad',
    },
    'fr': {
      'emptyFieldsError': 'Veuillez remplir tous les champs.',
      'unexpectedError': "Une erreur inattendue est survenue. Veuillez réessayer.",
      'signupPrompt': "Vous n'avez pas de compte ? Inscrivez-vous ici.",
      'userNotFoundError': "Utilisateur non trouvé.",
      'wrongPasswordError': 'Mot de passe incorrect, veuillez réessayer !',
      'defaultError': "Une erreur est survenue, veuillez réessayer.",
      'accountManagement': 'Gestion de compte',
      'logoutButton': 'Se déconnecter',
      'notificationSettings': 'Paramètres de notification',
      'privacyPolicy': 'Politique de confidentialité',
    },
    'de': {
      'emptyFieldsError': 'Bitte füllen Sie alle Felder aus.',
      'unexpectedError': 'Ein unerwarteter Fehler ist aufgetreten. Bitte versuchen Sie es erneut.',
      'signupPrompt': 'Haben Sie kein Konto? Hier registrieren.',
      'userNotFoundError': 'Benutzer nicht gefunden.',
      'wrongPasswordError': 'Falsches Passwort, bitte versuchen Sie es erneut!',
      'defaultError': 'Ein Fehler ist aufgetreten, bitte versuchen Sie es erneut.',
      'accountManagement': 'Kontoverwaltung',
      'logoutButton': 'Ausloggen',
      'notificationSettings': 'Benachrichtigungseinstellungen',
      'privacyPolicy': 'Datenschutzbestimmungen',
    },
    'zh': {
      'emptyFieldsError': '请填写所有字段。',
      'unexpectedError': '发生意外错误。请再试一次。',
      'signupPrompt': '还没有账户？在这里注册。',
      'userNotFoundError': '用户未找到。',
      'wrongPasswordError': '密码错误，请再试一次！',
      'defaultError': '发生错误，请再试一次。',
      'accountManagement': '账户管理',
      'logoutButton': '注销',
      'notificationSettings': '通知设置',
      'privacyPolicy': '隐私政策',
    },
    // Add more languages here
  };

  String get accountManagement {
    return _localizedValues[locale.languageCode]!['accountManagement']!;
  }

  String get emptyFieldsError {
    return _localizedValues[locale.languageCode]!['emptyFieldsError']!;
  }

  String get unexpectedError {
    return _localizedValues[locale.languageCode]!['unexpectedError']!;
  }

  String get signupPrompt {
    return _localizedValues[locale.languageCode]!['signupPrompt']!;
  }

  // Add getters for the error messages
  String get userNotFoundError {
    return _localizedValues[locale.languageCode]!['userNotFoundError']!;
  }

  String get wrongPasswordError {
    return _localizedValues[locale.languageCode]!['wrongPasswordError']!;
  }

  String get defaultError {
    return _localizedValues[locale.languageCode]!['defaultError']!;
  }

  // Add missing getters for logoutButton and privacyPolicy
  String get logoutButton {
    return _localizedValues[locale.languageCode]!['logoutButton']!;
  }

  String get notificationSettings {
    return _localizedValues[locale.languageCode]!['notificationSettings']!;
  }

  String get privacyPolicy {
    return _localizedValues[locale.languageCode]!['privacyPolicy']!;
  }
}

// To handle the change of languages
class CustomLocalizationsDelegate extends LocalizationsDelegate<CustomLocalizations> {
  const CustomLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es', 'fr', 'de', 'zh'].contains(locale.languageCode); // Support for English, Spanish, French, German, and Chinese
  }

  @override
  Future<CustomLocalizations> load(Locale locale) {
    return SynchronousFuture<CustomLocalizations>(CustomLocalizations(locale));
  }

  @override
  bool shouldReload(CustomLocalizationsDelegate old) => false;
}
