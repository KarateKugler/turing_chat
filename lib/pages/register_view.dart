import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../helpers/auth_utils.dart';
import '../logic/auth_cubit.dart';
import '../widgets/app_logo.dart';
import '../widgets/glass_box.dart';
import '../widgets/login_button.dart';
import '../widgets/login_text_field.dart';

class RegisterView extends StatefulWidget {
  /// method to go to login page
  final void Function()? onTap;

  const RegisterView({super.key, required this.onTap});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  /// Email and Password Text Controllers
  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _passwordConfirmController =
      TextEditingController();

  /// error handling
  String? _usernameErrorMessage;
  String? _emailErrorMessage;
  String? _passwordErrorMessage;

  // Could also possibly be solved with Form, TextFormField.validator
  void _validateInputs() {
    setState(() {
      /// Check valid Username and ...
      _usernameErrorMessage = null;
      if (!validateUsername(_usernameController.text.trim())) {
        _usernameErrorMessage = 'username must be $usernameRegexString, bro';
      }
      _usernameController.text = _usernameController.text.trim();

      /// Check valid E-mail and ...
      _emailErrorMessage = null;
      if (!validateEmail(_emailController.text.trim())) {
        _emailErrorMessage = 'invalid e-mail. bro';
      }
      _emailController.text = _emailController.text.trim();

      /// Check Password matching
      _passwordErrorMessage = null;
      if (_passwordController.text != _passwordConfirmController.text) {
        _passwordErrorMessage = 'passwords don\'t match... ... bro';
      }

      /// Check Password length
      else if (_passwordController.text.length < 8) {
        _passwordErrorMessage = 'password must be at least 8 characters long.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// Logo
                  const AppLogo(),

                  const SizedBox(height: 50),

                  /// Welcome Back message
                  Text(
                    'welcome back',
                    style: TextStyle(
                      // put into theme data
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// Username-field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: LoginTextField(
                      hintText: 'username',
                      obscureText: false,
                      controller: _usernameController,
                      errorText: _usernameErrorMessage,
                      // prefixIcon: Icons.email,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// Email-Field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: LoginTextField(
                      hintText: 'e-mail',
                      obscureText: false,
                      controller: _emailController,
                      errorText: _emailErrorMessage,
                      // prefixIcon: Icons.email,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// Password-Field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: LoginTextField(
                      hintText: 'password',
                      obscureText: true,
                      controller: _passwordController,
                      errorText: _passwordErrorMessage != null ? '' : null,
                      // prefixIcon: Icons.lock,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// Confirm Password
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: LoginTextField(
                      hintText: 'confirm password',
                      obscureText: true,
                      controller: _passwordConfirmController,
                      errorText: _passwordErrorMessage,
                      // prefixIcon: Icons.lock,
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// Register Button
                  LoginButton(
                    text: 'Register',
                    onTap: () async {
                      /// Check the Inputs
                      _validateInputs();

                      if (_emailErrorMessage == null &&
                          _passwordErrorMessage == null) {
                        /// AuthCubit
                        final AuthCubit authCubit = context.read<AuthCubit>();

                        /// try login
                        await authCubit.signUpWithUsernameEmailPassword(
                          username: _usernameController.text,
                          email: _emailController.text,
                          password: _passwordController.text,
                        );

                        /// todo redirect to welcome or home page
                      }
                    },
                  ),

                  const SizedBox(height: 25),

                  /// Text for register instead
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already a member? ',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          'Login here',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),

          /// Loading overlay
          BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              /// Display errors if occurred
              if (state is AuthError) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(state.errorMessage)));
              }
            },
            builder: (context, state) {
              debugPrint(state.toString());
              if (state is AuthLoading) {
                return const GlassBox(
                  blur: 1,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          )
        ],
      ),
    );
  }
}
