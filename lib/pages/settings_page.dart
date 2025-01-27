import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:turing_chat/logic/auth_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('S E T T I N G S'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// A C C O U N T   S E T T I N G S

            /// Current user Card
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                AuthLoggedIn authState = state as AuthLoggedIn;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      color: Theme.of(context).colorScheme.primaryContainer,
                      border: Border.all(
                          color: Theme.of(context).colorScheme.secondary),
                      boxShadow: [
                        BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer
                                .withOpacity(0.5),
                            blurRadius: 2,
                            spreadRadius: 2,
                            offset: Offset(0.0, 2.0))
                      ],
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            authState.user.username,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        SizedBox(height: 16.0,),
                        Text('e-mail: ${authState.user.email}'),
                        SizedBox(height: 16.0,),
                        Text('friends: ${authState.user.friends.length}'),
                        SizedBox(height: 16.0,),
                        Text('joined: ${timeago.format(authState.user.createdAt)}'),
                      ],
                    ),
                  ),
                );
              },
            )

            /// Email

            /// Logout

            /// Delete Account

            /// A P P   S E T T I N G S
          ],
        ),
      ),
    );
  }
}
