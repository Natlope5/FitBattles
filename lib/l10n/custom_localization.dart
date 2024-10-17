import 'package:flutter/material.dart';

class CustomLocalizations {
  final Locale locale;

  CustomLocalizations(this.locale);

  static CustomLocalizations? of(BuildContext context) {
    return Localizations.of<CustomLocalizations>(context, CustomLocalizations);
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'loginTitle': 'Login',
      'emailLabel': 'Email',
      'passwordLabel': 'Password',
      'loginButton': 'Login',
      'signupPrompt': 'Don’t have an account? Sign up',
      'userNotFoundError': 'User not found.',
      'wrongPasswordError': 'Incorrect password.',
      'genericError': 'An error occurred.',
    },
    'fr': {
      'loginTitle': 'Connexion',
      'emailLabel': 'E-mail',
      'passwordLabel': 'Mot de passe',
      'loginButton': 'Connexion',
      'signupPrompt': 'Vous n\'avez pas de compte ? Inscrivez-vous',
      'userNotFoundError': 'Utilisateur non trouvé.',
      'wrongPasswordError': 'Mot de passe incorrect.',
      'genericError': 'Une erreur est survenue.',
    },
    // Add more languages as needed
  };

  String? get loginTitle => _localizedValues[locale.languageCode]?['loginTitle'];
  String? get emailLabel => _localizedValues[locale.languageCode]?['emailLabel'];
  String? get passwordLabel => _localizedValues[locale.languageCode]?['passwordLabel'];
  String? get loginButton => _localizedValues[locale.languageCode]?['loginButton'];
  String? get signupPrompt => _localizedValues[locale.languageCode]?['signupPrompt'];
  String? get userNotFoundError => _localizedValues[locale.languageCode]?['userNotFoundError'];
  String? get wrongPasswordError => _localizedValues[locale.languageCode]?['wrongPasswordError'];
  String? get genericError => _localizedValues[locale.languageCode]?['genericError'];
}

class CustomLocalizationsDelegate extends LocalizationsDelegate<CustomLocalizations> {
  const CustomLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fr'].contains(locale.languageCode);

  @override
  Future<CustomLocalizations> load(Locale locale) async {
    return CustomLocalizations(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<CustomLocalizations> old) => false;
}
