import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:turing_chat/logic/auth_cubit.dart';

import '../logic/chat_cubit.dart';
import '../theme/style.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController _promptController = TextEditingController();
  bool changesMade = false;

  @override
  void initState() {
    super.initState();

    // prefill
    _promptController.text =
        context.read<ChatCubit>().state.userSettings.systemPrompt;
  }

  void resetSettings() {
    // todo: confirm dialog
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('S E T T I N G S'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      ),
      floatingActionButton: changesMade ? FloatingActionButton(
        onPressed: resetSettings,
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        child: Icon(
          Icons.restore,
          size: Style.fabIconSize,
        ),
        tooltip: 'reset',
      ) : null,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Divider(color: Theme.of(context).colorScheme.secondary),

              /// C H A T   S E T T I N G S

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: BlocBuilder<ChatCubit, ChatState>(
                  builder: (context, state) {
                    return Container(
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
                      padding: EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Caption
                          Align(
                              alignment: Alignment.center,
                              child: Text(
                                '✵ ✶ system_prompt ✶ ✵',
                                style: Theme.of(context).textTheme.titleLarge,
                              )),
                          SizedBox(height: 12),

                          /// Edit prompt
                          TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                            // by default bodyLarge
                            style: Theme.of(context).textTheme.bodyMedium,
                            minLines: 12,
                            maxLines: 24,
                            controller: _promptController,
                          ),

                          SizedBox(height: 4),

                          /// Updated timestamp
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'updated: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(state.userSettings.promptUpdatedAt.toLocal())}',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .copyWith(fontStyle: FontStyle.italic),
                            ),
                          )

                          /// Undo Changes

                          /// Update Prompt

                          /// Reset Prompt to default (conf. dialog)
                        ],
                      ),
                    );
                  },
                ),
              ),

              Divider(color: Theme.of(context).colorScheme.secondary),

              /// A C C O U N T   S E T T I N G S

              /// Current user Card
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    AuthLoggedIn authState = state as AuthLoggedIn;

                    return Container(
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
                      padding: EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              authState.user.username,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          SizedBox(
                            height: 16.0,
                          ),
                          Text('e-mail: ${authState.user.email}'),
                          SizedBox(
                            height: 16.0,
                          ),
                          Text('friends: ${authState.user.friends.length}'),
                          // todo
                          SizedBox(
                            height: 16.0,
                          ),
                          Text(
                              'joined: ${timeago.format(authState.user.createdAt)}'),
                        ],
                      ),
                    );
                  },
                ),
              ),

              /// Email

              /// Logout

              /// Delete Account

              /// A P P   S E T T I N G S
            ],
          ),
        ),
      ),
    );
  }
}
