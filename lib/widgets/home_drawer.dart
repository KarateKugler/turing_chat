import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:turing_chat/logic/auth_cubit.dart';
import 'package:turing_chat/widgets/loading_widget.dart';

import '../logic/chat_cubit.dart';
import 'app_logo.dart';
import 'home_drawer_tile.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  bool _logOutLoading = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        /// When logged out, and AuthInitial is emitted, go back to Login

        if (state is AuthInitial) {
          context.go('/login');
        }
      },
      child: Drawer(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .surfaceContainer,
        child: Column(
          children: [

            /// App logo
            const Padding(
              padding: EdgeInsets.only(top: 100),
              child: AppLogo(),
            ),

            const Padding(
              padding: EdgeInsets.all(25.0),
              child: Divider(),
            ),

            /// home list tile
            HomeDrawerTile(
              text: 'H O M E',
              icon: const Icon(Icons.home),
              onTap: () {
                context.pop();
                context.go('/');
              },
            ),

            const Spacer(),

            /// share
            HomeDrawerTile(text: 'S H A R E',
                icon: const Icon(Icons.share),
                onTap: () {
                  context.push('/share');
                }),

            /// feedback
            HomeDrawerTile(text: 'F E E D B A C K',
                icon: const Icon(Icons.favorite_outline),
                onTap: () {
                  context.push('/feedback');
                }),

            /// settings
            HomeDrawerTile(
              text: 'S E T T I N G S',
              icon: const Icon(Icons.settings),
              onTap: () {
                context.push('/settings');
              },
            ),

            /// logout
            HomeDrawerTile(
              text: 'L O G   O U T',
              icon: (_logOutLoading)

              /// If log out initiated and loading show progress indicator
                  ? const LoadingWidget()

              /// Otherwise just the logout icon
                  : const Icon(Icons.logout),
              onTap: () async {
                /// Perform Log out
                AuthCubit authCubit = context.read<AuthCubit>();

                setState(() {
                  _logOutLoading = true;
                });

                try {
                  await authCubit.logOut();

                  context.read<ChatCubit>().logOut();
                }

                /// If log out fails, show error message
                catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Log out failed'),
                      backgroundColor: Theme
                          .of(context)
                          .colorScheme
                          .error,
                    ),
                  );
                }

                setState(() {
                  _logOutLoading = false;
                });
              },
            ),

            const SizedBox(
              height: 25,
            ),
          ],
        ),
      ),
    );
  }
}
