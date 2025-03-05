import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_api/supabase_api.dart';
import 'package:turing_chat/logic/chat_cubit.dart';
import 'package:turing_chat/theme/dark_scheme.dart';

import 'core/app_router.dart';
import 'logic/auth_cubit.dart';

/// ## DEV-LOG
/// ### 26.01.
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
///
/// * added user card to the settings page
///
/// ### 27.01.
/// * ordered a new credit card for the open ai api.
///
/// ### 16.02.
/// * ordered a new credit card from a different bank cause postbank sucks ass
/// * slight UI changes to home page
/// * todo: make chatrooms functional
///
/// ### 23.02.
/// * started working with Cline in VSCode to dish out the UI more quickly
/// * chat room page started with message bubble (no functionality yet)
///
/// ### 24.02.
/// * added chat input field and send/generate button
/// * refactored chat cubit (and associated function calls) to store and use
///   user data separately in state and not depend on auth cubit
/// * checked gemini api pricing, has free tier actually (15 RPM, 1Mil TPM,
///   1.500 RPD, so more than enough for testing purposes.)
/// * (also added a slide transition to the chat room navigation for funsies)
/// todo: refactor showsnackbar into ui util function
///
/// ### 26./27.02.
/// * Added blur widget, which is clunky and kinda sucks
/// * but params, widg.tr. and basic layout works
/// * ya, (scrapped animations from cline, hard to work while away, forgot to
/// pack .env and supabase login)
///
/// ### 27.02.
/// * So fucking tired today
/// * added an animation controller which drives some animations in the blur
/// widget.
///
/// ### 28.02.
/// * started rebuilding blur widget and fixing the alignment of the msgbbl
/// * put animatedbuilder at top of widg.tree and added/ synced multiple animations
/// * tried fixing the deselect animation by adding another bool flag (sucks)
///
/// ### 01.03.
/// (notes: - need to add keys to every msg bubble and store
///   - two modes for blurring, either just highlight and show action bubbles
///     - or show centered and display large action buttons (onLongPressEnd)
///   - blur widget takes position for onLongPress from:
///     ```dart
///     final context = key.currentContext;
///     final renderBox = context.findRenderObject() as RenderBox?;
///     if (renderBox != null) {
///       final position = renderBox.localToGlobal(Offset.zero);
///       print("Item $index is at position: $position");
///     }
///     ```
///   - that means the msg bubble gets a callback that adds the msg to chatCubit
///
/// ### 02.03./03.03.
/// * honestly, there is not much to do right now, the backend has to be
/// set up and cabled up to the front end
/// * then only the actual game rules I think are missing
/// -> Like can you just keep sending gen. msgs/ only one/ not stop until
///    ur friend notices?
/// -> I think probably easiest is, just keep sending, and for each missed
/// msg u get one point/ for wrong guesses -1 pt. then just see how it plays
///
/// -> and then apart from supabase backend the gemini api has to be hooked up,
/// which doesn't sound too tedious honestly.
///
///
/// " Hey, welcome to my app!
/// I did it myself, I'm a student, trying to make something fun
/// for you and your friends to enjoy. I spent a lot of time
/// to as entertaining as possible for you.
/// ...

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
    return MaterialApp.router(
      title: 'Ratatouille',
      theme: ThemeData(
        colorScheme: darkColorScheme,
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router,
    );
  }
}
