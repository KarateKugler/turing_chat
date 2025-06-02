import 'package:flutter/material.dart';

import '../core/app_router.dart';
import '../theme/dark_scheme.dart';

class App extends StatelessWidget {
  /// Whether to show the login screen first
  final bool activeSession;

  const App({super.key, required this.activeSession});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'turing_chat',
      theme: terminalDarkTheme,
      routerConfig: AppRouter.router,
    );
  }
}
