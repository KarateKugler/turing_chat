/// App Router
///
/// Centralized routing configuration using go_router for navigation between app screens.
/// Handles authentication redirects and custom page transitions.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../logic/auth_cubit.dart';
import '../models/chat_room.dart';
import '../pages/auth/login_register_page.dart';
import '../pages/chat_room_page.dart';
import '../pages/home_page.dart';
import '../pages/settings_page.dart';
import '../pages/splash_page.dart';

/// Router config constants
class RouterConstants {
  // Paths
  static const String splash = '/splash';
  static const String home = '/';
  static const String login = '/login';
  static const String settings = '/settings';
  static const String chat = '/chat/:id';
  
  static const Duration transitionDuration = Duration(milliseconds: 150);
  
  // Prevent instantiation
  RouterConstants._();
}

/// Main router configuration
class AppRouter {
  /// Public router instance
  static GoRouter get router => _router;

  /// Private router instance with configuration
  static final _router = GoRouter(
    initialLocation: RouterConstants.home,
    redirect: _handleRedirect,
    routes: _buildRoutes(),
  );
  
  /// Authentication redirect logic
  static String? _handleRedirect(BuildContext context, GoRouterState state) {
    final isLoggedIn = context.read<AuthCubit>().state is AuthLoggedIn;
    
    // Always allow splash page
    if (state.path == RouterConstants.splash) return null;
    
    // Auth redirect logic
    if (!isLoggedIn && state.path != RouterConstants.login) return RouterConstants.login;
    if (isLoggedIn && state.path == RouterConstants.login) return RouterConstants.home;
    
    return null;
  }

  /// Build app routes
  static List<RouteBase> _buildRoutes() {
    return [
      _splashRoute(),
      _homeRoute(),
      _loginRoute(),
      _settingsRoute(),
      _chatRoute(),
    ];
  }

  ///////
  // Route builders
  ///////

  /// Splash screen route
  static GoRoute _splashRoute() {
    return GoRoute(
      path: RouterConstants.splash,
      builder: (context, state) => const SplashPage(),
    );
  }
  
  /// Home screen route
  static GoRoute _homeRoute() {
    return GoRoute(
      path: RouterConstants.home,
      builder: (context, state) => const HomePage(),
    );
  }
  
  /// Login/register route
  static GoRoute _loginRoute() {
    return GoRoute(
      path: RouterConstants.login,
      builder: (context, state) => const LoginOrRegisterPage(),
    );
  }
  
  /// Settings screen route
  static GoRoute _settingsRoute() {
    return GoRoute(
      path: RouterConstants.settings,
      builder: (context, state) => const SettingsPage(),
    );
  }
  
  /// Chat room route with slide transition
  static GoRoute _chatRoute() {
    return GoRoute(
      path: RouterConstants.chat,
      pageBuilder: (context, state) {
        final chatRoom = state.extra as ChatRoom;
        return _buildChatTransition(state, chatRoom);
      },
    );
  }

  ///////
  // Custom transitions
  ///////
  
  /// Create custom transition for chat page
  static CustomTransitionPage<void> _buildChatTransition(
    GoRouterState state, 
    ChatRoom chatRoom
  ) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: ChatRoomPage(chatRoom: chatRoom),
      transitionDuration: RouterConstants.transitionDuration,
      reverseTransitionDuration: RouterConstants.transitionDuration,
      transitionsBuilder: _slideTransition,
    );
  }
  
  /// Slide transition animation
  static Widget _slideTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child
  ) {
    const begin = Offset(1.0, 0.0); // Slide from right
    const end = Offset.zero;
    const curve = Curves.easeInOut;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    var reverseTween = Tween(begin: Offset.zero, end: begin).chain(CurveTween(curve: curve));

    return SlideTransition(
      position: animation.drive(tween), // Push animation
      child: SlideTransition(
        position: secondaryAnimation.drive(reverseTween), // Pop animation
        child: child,
      ),
    );
  }
}
