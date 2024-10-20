import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  static GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  static Future<Object?>? navigateTo(String routeName, {Object? arguments}) {
    return _navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
  }

  static Future<Object?>? replaceWith(String routeName, {Object? arguments}) {
    return _navigatorKey.currentState?.pushReplacementNamed(routeName, arguments: arguments);
  }

  static void goBack() {
    return _navigatorKey.currentState?.pop();
  }
}
