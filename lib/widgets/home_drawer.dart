import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turing_chat/logic/auth_cubit.dart';
import 'package:turing_chat/widgets/loading_widget.dart';

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
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => true,
          );
        }
      },
      child: Drawer(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        child: Column(
          children: [
            /// App logo
            Padding(
              padding: EdgeInsets.only(top: 100),
              child: AppLogo(),
            ),

            Padding(
              padding: EdgeInsets.all(25.0),
              child: Divider(),
            ),

            /// home list tile
            HomeDrawerTile(
              text: 'H O M E',
              icon: Icon(Icons.home),
              onTap: () {
                Navigator.pop(context);
                // Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false,);
              },
            ),

            Spacer(),

            /// settings
            HomeDrawerTile(
              text: 'S E T T I N G S',
              icon: Icon(Icons.settings),
              onTap: () {
                Navigator.of(context).pushNamed('/settings');
              },
            ),

            /// logout
            HomeDrawerTile(
              text: 'L O G   O U T',
              icon: (_logOutLoading)

                  /// If log out initiated and loading show progress indicator
                  ? LoadingWidget()

                  /// Otherwise just the logout icon
                  : Icon(Icons.logout),
              onTap: () async {
                /// Perform Log out
                AuthCubit authCubit = context.read<AuthCubit>();

                setState(() {
                  _logOutLoading = true;
                });

                await authCubit.logOut();

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
