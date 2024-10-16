import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  final Locale locale;

  static get delegate => AppLocalizations.delegate;


  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Add this method to initialize messages based on locale
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

  // Define initialization for each locale
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

  // Example of localized strings
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
    return 'FitBattles'; // Common title
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

  String get leaderboardRefreshed {
    switch (locale.languageCode) {
      case 'es':
        return 'Tabla de líderes actualizada';
      case 'fr':
        return 'Classement actualisé';
      case 'de':
        return 'Rangliste aktualisiert';
      case 'zh':
        return '排行榜已更新';
      case 'en':
      default:
        return 'Leaderboard refreshed';
    }
  }

  String get errorLoadingLeaderboard {
    switch (locale.languageCode) {
      case 'es':
        return 'Error al cargar la tabla de líderes';
      case 'fr':
        return 'Erreur de chargement du classement';
      case 'de':
        return 'Fehler beim Laden der Rangliste';
      case 'zh':
        return '加载排行榜时出错';
      case 'en':
      default:
        return 'Error loading leaderboard';
    }
  }

  // ========================
  // Workout Related Strings
  // ========================
  String get strengthWorkoutTitle {
    switch (locale.languageCode) {
      case 'es':
        return 'Entrenamiento de Fuerza';
      case 'fr':
        return 'Entraînement de Force';
      case 'de':
        return 'Krafttraining';
      case 'zh':
        return '力量训练';
      case 'en':
      default:
        return 'Strength Workout';
    }
  }

  String get strengthWorkoutDescription {
    switch (locale.languageCode) {
      case 'es':
        return 'Participa en desafíos de entrenamiento de fuerza y mejora tus habilidades.';
      case 'fr':
        return 'Participez à des défis d\'entraînement de force et améliorez vos compétences.';
      case 'de':
        return 'Nehmen Sie an Krafttraining-Herausforderungen teil und verbessern Sie Ihre Fähigkeiten.';
      case 'zh':
        return '参与力量训练挑战，提升你的技能。';
      case 'en':
      default:
        return 'Join strength workout challenges and improve your skills.';
    }
  }

  String get workoutStartedMessage {
    switch (locale.languageCode) {
      case 'es':
        return 'El entrenamiento ha comenzado. ¡Buena suerte!';
      case 'fr':
        return 'L\'entraînement a commencé. Bonne chance!';
      case 'de':
        return 'Das Training hat begonnen. Viel Glück!';
      case 'zh':
        return '训练已开始。祝你好运！';
      case 'en':
      default:
        return 'The workout has started. Good luck!';
    }
  }

  String get startWorkoutButton {
    switch (locale.languageCode) {
      case 'es':
        return 'Iniciar Entrenamiento';
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

  String get signupLink {
    switch (locale.languageCode) {
      case 'es':
        return '¿No tienes una cuenta? ¡Regístrate aquí!';
      case 'fr':
        return 'Vous n\'avez pas de compte ? Inscrivez-vous ici!';
      case 'de':
        return 'Haben Sie kein Konto? Melden Sie sich hier an!';
      case 'zh':
        return '没有帐户？在这里注册！';
      case 'en':
      default:
        return 'Don\'t have an account? Sign up here!';
    }
  }

  String streak(int days) {
    switch (locale.languageCode) {
      case 'es':
        return 'Racha de $days días';
      case 'fr':
        return 'Série de $days jours';
      case 'de':
        return '$days-Tage-Serie';
      case 'zh':
        return '$days 天的连胜纪录';
      case 'en':
      default:
        return '$days-day streak';
    }
  }


  String strengthWorkoutChallengesTitle(String workoutType) {
    switch (locale.languageCode) {
      case 'es':
        return 'Desafíos de entrenamiento de fuerza: $workoutType';
      case 'fr':
        return 'Défis d\'entraînement de force : $workoutType';
      case 'de':
        return 'Krafttrainingsherausforderungen: $workoutType';
      case 'zh':
        return '力量训练挑战: $workoutType';
      case 'en':
      default:
        return 'Strength Workout Challenges: $workoutType';
    }
  }

  String get noLeaderboardData {
    switch (locale.languageCode) {
      case 'es':
        return 'No hay datos disponibles en la tabla de clasificación.';
      case 'fr':
        return 'Aucune donnée disponible sur le classement.';
      case 'de':
        return 'Keine Daten auf der Bestenliste verfügbar.';
      case 'zh':
        return '排行榜上没有可用的数据。';
      case 'en':
      default:
        return 'No leaderboard data available.';
    }
  }


  String get days {
    switch (locale.languageCode) {
      case 'es':
        return 'días';
      case 'fr':
        return 'jours';
      case 'de':
        return 'Tage';
      case 'zh':
        return '天';
      case 'en':
      default:
        return 'days';
    }
  }


  String replacePlaceholder(String placeholder) {
    switch (locale.languageCode) {
      case 'es':
        return 'Reemplazar {placeholder}';
      case 'fr':
        return 'Remplacer {placeholder}';
      case 'de':
        return 'Ersetzen {placeholder}';
      case 'zh':
        return '替换 {placeholder}';
      case 'en':
      default:
        return 'Replace {placeholder}';
    }
  }
}