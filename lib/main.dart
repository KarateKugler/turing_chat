import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_api/supabase_api.dart';
import 'package:turing_chat/logic/chat_cubit.dart';
import 'package:turing_chat/logic/feedback_cubit.dart';

import 'app/app.dart';
import 'logic/auth_cubit.dart';

void main() async {
  await dotenv.load();

  /// setup supabase (horizons/turing_chat project
  await SupabaseApi.initialize(
    supabaseUrl: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
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
          // BAD ! should not be in app context, refactor later
          BlocProvider(create: (_) => FeedbackCubit()),
        ],
        child: App(
          activeSession: authCubit.state is AuthLoggedIn,
        ),
      ),
    ),
  );
}
