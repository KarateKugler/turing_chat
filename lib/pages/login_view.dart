import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../helpers/auth_utils.dart';
import '../logic/auth_cubit.dart';
import '../widgets/app_logo.dart';
import '../widgets/glass_box.dart';
import '../widgets/login_button.dart';
import '../widgets/login_text_field.dart';

class LoginView extends StatefulWidget {
  /// method to go to register page
  final void Function()? onTap;

  const LoginView({super.key, required this.onTap});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  /// Email and Password Text Controllers
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  /// error handling
  String? _emailErrorMessage;
  String? _passwordErrorMessage;

  void _validateInputs() {
    setState(() {

      /// Check valid E-mail
      if (!validateEmail(_emailController.text)) {
        _emailErrorMessage = 'Invalid E-Mail.';
      }

      /// Check Password length
      if (_passwordController.text.length < 8) {
        _passwordErrorMessage = 'Password must be at least 8 characters long.';
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
              child: BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Login failed: ${state.errorMessage}'),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /// Logo
                      const AppLogo(),
            
                      const SizedBox(height: 50),
            
                      /// Welcome Back message
                      Text(
                        'Welcome Back to ratatouille!',
                        style: TextStyle(
                          // put into theme data
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16,
                        ),
                      ),
            
                      const SizedBox(height: 25),
            
                      /// Email-Field
                      // todo: add username option
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: LoginTextField(
                          hintText: 'E-Mail',
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
                          hintText: 'Password',
                          obscureText: true,
                          controller: _passwordController,
                          errorText: _passwordErrorMessage,
                          // prefixIcon: Icons.lock,
                        ),
                      ),
            
                      const SizedBox(height: 25),
            
                      /// Login Button
                      LoginButton(
                        text: 'Login',
                        onTap: () async {
                          /// Check the Inputs
                          _validateInputs();
            
                          if (_emailErrorMessage == null &&
                              _passwordErrorMessage == null) {
                            /// AuthCubit
                            final AuthCubit authCubit = context.read<AuthCubit>();
            
                            /// try login
                            await authCubit.logInWithEmailPassword(
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
                            'Not a member yet? ',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface),
                          ),
                          GestureDetector(
                            onTap: widget.onTap,
                            child: Text(
                              'Register now',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          /// Loading overlay
          BlocBuilder<AuthCubit, AuthState>(
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}


