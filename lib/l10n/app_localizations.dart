import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const LocalizationsDelegate<
      AppLocalizations> delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static Future<void> initializeMessages(String localeName) async {
    switch (localeName) {
      case 'en':
        await initializeMessagesForLocaleEn();
        break;
      case 'es':
        await initializeMessagesForLocaleEs();
        break;
      case 'fr':
        await initializeMessagesForLocaleFr();
        break;
      case 'de':
        await initializeMessagesForLocaleDe();
        break;
      case 'zh':
        await initializeMessagesForLocaleZh();
        break;
      default:
        await initializeMessagesForLocaleEn();
    }
  }

  static Future<void> initializeMessagesForLocaleEn() async {
    Intl.defaultLocale = 'en';
  }

  static Future<void> initializeMessagesForLocaleEs() async {
    Intl.defaultLocale = 'es';
  }

  static Future<void> initializeMessagesForLocaleFr() async {
    Intl.defaultLocale = 'fr';
  }

  static Future<void> initializeMessagesForLocaleDe() async {
    Intl.defaultLocale = 'de';
  }

  static Future<void> initializeMessagesForLocaleZh() async {
    Intl.defaultLocale = 'zh';
  }

  // Example of localized strings for login errors
  String get loginFailedWithError {
    switch (locale.languageCode) {
      case 'es':
        return 'Error de inicio de sesión: {error}';
      case 'fr':
        return 'Erreur de connexion : {error}';
      case 'de':
        return 'Anmeldefehler: {error}';
      case 'zh':
        return '登录错误：{error}';
      case 'en':
      default:
        return 'Login failed: {error}';
    }
  }

  // ========================
  // Streak and Leaderboard Related Strings
  // ========================
  String get streak {
    switch (locale.languageCode) {
      case 'es':
        return 'Racha';
      case 'fr':
        return 'Série';
      case 'de':
        return 'Serie';
      case 'zh':
        return '连胜';
      case 'en':
      default:
        return 'Streak';
    }
  }

  String get days {
    switch (locale.languageCode) {
      case 'es':
        return 'Días';
      case 'fr':
        return 'Jours';
      case 'de':
        return 'Tage';
      case 'zh':
        return '天';
      case 'en':
      default:
        return 'Days';
    }
  }

  String get noLeaderboardData {
    switch (locale.languageCode) {
      case 'es':
        return 'No hay datos de la tabla de líderes';
      case 'fr':
        return 'Pas de données de classement';
      case 'de':
        return 'Keine Ranglistendaten';
      case 'zh':
        return '没有排行榜数据';
      case 'en':
      default:
        return 'No leaderboard data';
    }
  }

  // ========================
  // Newly Added Getters
  // ========================
  String get strengthWorkoutTitle {
    switch (locale.languageCode) {
      case 'es':
        return 'Título del Entrenamiento de Fuerza';
      case 'fr':
        return 'Titre de l\'Entraînement de Force';
      case 'de':
        return 'Titel des Krafttrainings';
      case 'zh':
        return '力量训练标题';
      case 'en':
      default:
        return 'Strength Workout Title';
    }
  }

  String get strengthWorkoutDescription {
    switch (locale.languageCode) {
      case 'es':
        return 'Descripción del Entrenamiento de Fuerza';
      case 'fr':
        return 'Description de l\'Entraînement de Force';
      case 'de':
        return 'Beschreibung des Krafttrainings';
      case 'zh':
        return '力量训练说明';
      case 'en':
      default:
        return 'Strength Workout Description';
    }
  }

  String get workoutStartedMessage {
    switch (locale.languageCode) {
      case 'es':
        return '¡Entrenamiento Iniciado!';
      case 'fr':
        return 'Entraînement Commencé!';
      case 'de':
        return 'Training Gestartet!';
      case 'zh':
        return '训练开始了！';
      case 'en':
      default:
        return 'Workout Started!';
    }
  }

  String get startWorkoutButton {
    switch (locale.languageCode) {
      case 'es':
        return 'Comenzar Entrenamiento';
      case 'fr':
        return 'Commencer l\'Entraînement';
      case 'de':
        return 'Training Starten';
      case 'zh':
        return '开始训练';
      case 'en':
      default:
        return 'Start Workout';
    }
  }

  // ========================
  // Theme Related Strings
  // ========================
  String get themeTitle {
    switch (locale.languageCode) {
      case 'es':
        return 'Tema';
      case 'fr':
        return 'Thème';
      case 'de':
        return 'Thema';
      case 'zh':
        return '主题';
      case 'en':
      default:
        return 'Theme';
    }
  }

  String get lightTheme {
    switch (locale.languageCode) {
      case 'es':
        return 'Tema Claro';
      case 'fr':
        return 'Thème Clair';
      case 'de':
        return 'Helles Thema';
      case 'zh':
        return '明亮主题';
      case 'en':
      default:
        return 'Light Theme';
    }
  }

  String get darkTheme {
    switch (locale.languageCode) {
      case 'es':
        return 'Tema Oscuro';
      case 'fr':
        return 'Thème Sombre';
      case 'de':
        return 'Dunkles Thema';
      case 'zh':
        return '黑暗主题';
      case 'en':
      default:
        return 'Dark Theme';
    }
  }

  // ========================
  // App and Login Related Strings
  // ========================
  String get appTitle {
    return 'FitBattles';
  }

  String get emailLabel {
    switch (locale.languageCode) {
      case 'es':
        return 'Correo Electrónico';
      case 'fr':
        return 'E-mail';
      case 'de':
        return 'E-Mail';
      case 'zh':
        return '电子邮件';
      case 'en':
      default:
        return 'Email';
    }
  }

  String get passwordLabel {
    switch (locale.languageCode) {
      case 'es':
        return 'Contraseña';
      case 'fr':
        return 'Mot de passe';
      case 'de':
        return 'Passwort';
      case 'zh':
        return '密码';
      case 'en':
      default:
        return 'Password';
    }
  }

  String get loginFailed {
    switch (locale.languageCode) {
      case 'es':
        return 'Inicio de sesión fallido';
      case 'fr':
        return 'Échec de la connexion';
      case 'de':
        return 'Anmeldung fehlgeschlagen';
      case 'zh':
        return '登录失败';
      case 'en':
      default:
        return 'Login Failed';
    }
  }

  String get loginButton {
    switch (locale.languageCode) {
      case 'es':
        return 'Iniciar Sesión';
      case 'fr':
        return 'Connexion';
      case 'de':
        return 'Anmelden';
      case 'zh':
        return '登录';
      case 'en':
      default:
        return 'Login';
    }
  }

  // ========================
  // Challenge Related Strings
  // ========================
  String get selectChallenge {
    switch (locale.languageCode) {
      case 'es':
        return 'Seleccionar desafío';
      case 'fr':
        return 'Sélectionner un défi';
      case 'de':
        return 'Herausforderung auswählen';
      case 'zh':
        return '选择挑战';
      case 'en':
      default:
        return 'Select Challenge';
    }
  }

  String get sendChallenge {
    switch (locale.languageCode) {
      case 'es':
        return 'Enviar desafío';
      case 'fr':
        return 'Envoyer un défi';
      case 'de':
        return 'Herausforderung senden';
      case 'zh':
        return '发送挑战';
      case 'en':
      default:
        return 'Send Challenge';
    }
  }

  String get challengeSent {
    switch (locale.languageCode) {
      case 'es':
        return 'Desafío enviado';
      case 'fr':
        return 'Défi envoyé';
      case 'de':
        return 'Herausforderung gesendet';
      case 'zh':
        return '挑战已发送';
      case 'en':
      default:
        return 'Challenge Sent';
    }
  }

  // ========================
  // Leaderboard Related Strings
  // ========================
  String get leaderboardTitle {
    switch (locale.languageCode) {
      case 'es':
        return 'Tabla de líderes';
      case 'fr':
        return 'Classement';
      case 'de':
        return 'Rangliste';
      case 'zh':
        return '排行榜';
      case 'en':
      default:
        return 'Leaderboard';
    }
  }

  String get replacePlaceholder {
    switch (locale.languageCode) {
      case 'es':
        return 'Reemplazar marcador de posición';
      case 'fr':
        return 'Remplacer le paramètre fictif';
      case 'de':
        return 'Platzhalter ersetzen';
      case 'zh':
        return '替换占位符';
      case 'en':
      default:
        return 'Replace Placeholder';
    }
  }

  String get strengthWorkoutChallengesTitle {
    switch (locale.languageCode) {
      case 'es':
        return 'Desafíos de Entrenamiento de Fuerza';
      case 'fr':
        return 'Défis d\'Entraînement de Force';
      case 'de':
        return 'Krafttrainings-Herausforderungen';
      case 'zh':
        return '力量训练挑战';
      case 'en':
      default:
        return 'Strength Workout Challenges';
    }
  }

  // ========================
  // Error Handling Strings
  // ========================
  String get errorLoadingLeaderboard {
    switch (locale.languageCode) {
      case 'es':
        return 'Error al cargar la tabla de líderes';
      case 'fr':
        return 'Erreur lors du chargement du classement';
      case 'de':
        return 'Fehler beim Laden der Rangliste';
      case 'zh':
        return '加载排行榜时出错';
      case 'en':
      default:
        return 'Error loading leaderboard';
    }
  }

  String get leaderboardRefreshed {
    switch (locale.languageCode) {
      case 'es':
        return 'Tabla de líderes actualizada';
      case 'fr':
        return 'Classement mis à jour';
      case 'de':
        return 'Rangliste aktualisiert';
      case 'zh':
        return '排行榜已刷新';
      case 'en':
      default:
        return 'Leaderboard refreshed';
    }
  }

  String? get emptyFieldsError => null;

  String? get unexpectedError => null;
}
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es', 'fr', 'de', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await AppLocalizations.initializeMessages(locale.languageCode);
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
