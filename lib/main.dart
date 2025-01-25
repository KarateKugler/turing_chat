import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_api/supabase_api.dart';
import 'package:turing_chat/theme/dark_scheme.dart';

import 'core/app_router.dart';
import 'logic/auth_cubit.dart';

void main() async {
  /// setup supabase (horizons/turing_chat project
  await SupabaseApi.initialize(
    anonKey:
    '',
  );

  /// set Repository SupabaseApiClient
  SupabaseApiClient supabaseApiClient = SupabaseApi.client;

  /// Initialize AuthCubit
  AuthCubit authCubit = AuthCubit(
    supabaseApiClient.authService,
    supabaseApiClient.databaseService,
  );
  authCubit.init();

  /// Ensure WidgetBinding
  WidgetsFlutterBinding.ensureInitialized();

  /// Dependency Injection of SupabaseApiClient and AuthCubit
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(
          // Not exactly right, should normally create extra repository layer between ApiClient (data provider) and logic layer.
          value: supabaseApiClient,
        )
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(
            /// Inject AuthCubit with AuthService for Auth functionality and
            /// databaseService for database functionality
            value: authCubit,
          )
        ],
        child: TuringChatApp(
          activeSession: authCubit.state is AuthLoggedIn,
        ),
      ),
    ),
  );
}

class TuringChatApp extends StatelessWidget {
  /// Whether to show the login screen first
  final bool activeSession;

  const TuringChatApp({super.key, required this.activeSession});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ratatouille',
      theme: ThemeData(
        colorScheme: darkColorScheme,
        useMaterial3: true,
      ),
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: activeSession ? '/' : '/login',
      // todo: caching user credentials,
      // todo: auth gate,
    );
  }
}
