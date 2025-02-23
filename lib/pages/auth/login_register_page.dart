import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../logic/auth_cubit.dart';
import 'login_view.dart';
import 'register_view.dart';

// good practice but could also use flutter_login package

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  /// initially show login page
  bool showLoginView = true;

  /// toggle between register and login
  void togglePages() {
    setState(() {
      showLoginView = !showLoginView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        debugPrint(state.toString());
        if (state is AuthLoggedIn) {
          context.go('/');
        }
      },
      child: (showLoginView) // todo: refactor redundancies
          ? LoginView(
              onTap: togglePages,
            )
          : RegisterView(
              onTap: togglePages,
            ),
    );
  }
}
