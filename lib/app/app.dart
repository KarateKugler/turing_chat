import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_router.dart';
import '../theme/dark_scheme.dart';

class App extends StatelessWidget {
  /// Whether to show the login screen first
  final bool activeSession;

  const App({super.key, required this.activeSession});

  @override
  Widget build(BuildContext context) {
    final iconBrightness = Brightness.values[(terminalDarkTheme.colorScheme.brightness.index + 1) % 2];

    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: terminalDarkTheme.colorScheme.surface,
        systemNavigationBarIconBrightness: iconBrightness,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: iconBrightness,
      ),
      child: MaterialApp.router(
        title: 'turing_chat',
        theme: terminalDarkTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
