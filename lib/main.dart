import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_api/supabase_api.dart';
import 'package:turing_chat/logic/chat_cubit.dart';
import 'package:turing_chat/theme/dark_scheme.dart';

import 'core/app_router.dart';
import 'logic/auth_cubit.dart';

/// DEV-LOG
/// 26.01.:
/// * started implementing the add friend by username --> if there is more information to
///   be stored about a particular user profile, we should add a separate table
///   and add read constraints, such that profile data doesn't leak.
///
/// * backend model logic also works now, constraints were wrong in table
/// * need to be able to reload or load all chatrooms on app start, or through refresh gesture
///
/// * implemented sql functions to get contacts depending on if its mutual or outgoing/incoming friend request
/// * refactored all the namings to be snake case in postgres
/// * added necessary auth permissions/policies
/// *
///
/// todo: refactor showsnackbar into ui util function


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
          ),
          BlocProvider(
            /// Also provide the ChatCubit to the whole app
            create: (_) => ChatCubit(
              supabaseApiClient.authService,
              supabaseApiClient.databaseService,
            ),
          ),
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
