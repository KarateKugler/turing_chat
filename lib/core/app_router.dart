import 'package:flutter/material.dart';
import 'package:turing_chat/pages/splash_page.dart';

import '../pages/home_page.dart';
import '../pages/login_register_page.dart';
import '../pages/settings_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => HomePage(),
        );
      case '/login':
        return MaterialPageRoute(
          builder: (_) => const LoginOrRegisterPage(),
        );
      case '/settings':
        return MaterialPageRoute(
          builder: (_) => const SettingsPage(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Unknown Route'),
            ),
          ),
        );
    }
  }
}
