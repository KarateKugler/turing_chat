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

class AppRouter {
  static GoRouter get router => _router;

  static final _router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = context.read<AuthCubit>().state is AuthLoggedIn;
      
      // Always allow splash page
      if (state.path == '/splash') return null;
      
      // Auth redirect logic
      if (!isLoggedIn && state.path != '/login') return '/login';
      if (isLoggedIn && state.path == '/login') return '/';
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginOrRegisterPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) {
          final chatRoom = state.extra as ChatRoom;
          return ChatRoomPage(chatRoom: chatRoom);
        },
      ),
    ],
  );
}
