import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:turing_chat/logic/auth_cubit.dart';
import 'package:turing_chat/widgets/loading_widget.dart';

import '../logic/chat_cubit.dart';
import '../theme/style.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ///
  ScrollController _listViewScrollController = ScrollController();
  ScrollController _promptFieldScrollController = ScrollController();

  /// prompt settings
  TextEditingController _promptFieldTextController = TextEditingController();
  FocusNode _promptFocusNode = FocusNode();
  bool changesMade = false;
  String tokenCounter = '0';

  void onChanged(String value) {
    setState(() {
      changesMade = true;
    });

    calcTokens();
  }

  void resetSettings() {
    // todo: confirm dialog -> prefill again
    setState(() {
      changesMade = false;
    });

    calcTokens();
  }

  void calcTokens() {
    setState(() {
      tokenCounter = _promptFieldTextController.text.isEmpty
          ? '0'
          : '~${_promptFieldTextController.text.length ~/ 4 + 1}';
    });
  }

  /// account
  bool _logOutLoading = false;

  ///
  @override
  void initState() {
    super.initState();

    // prefill
    _promptFieldTextController.text =
        context.read<ChatCubit>().state.userSettings.systemPrompt;
    calcTokens();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('S E T T I N G S'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      ),
      floatingActionButton: changesMade
          ? FloatingActionButton(
              onPressed: resetSettings,
              backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
              child: Icon(
                Icons.restore,
                size: Style.fabIconSize,
              ),
              tooltip: 'reset',
            )
          : null,
      body: BlocListener<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state is AuthInitial) {
            context.go('/login');
          }
        },
        child: SingleChildScrollView(
          controller: _listViewScrollController,
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Divider(color: Theme.of(context).colorScheme.secondary),

                /// U S E R   C A R D

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      AuthLoggedIn authState = state as AuthLoggedIn;

                      return Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(Style.cornerRadius),
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer, // todo: try secondaryContainer
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
                              offset: Offset(0.0, 2.0),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 16.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                authState.user.username,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),

                            SizedBox(height: 16.0),

                            Text('e-mail: ${authState.user.email}'),

                            SizedBox(height: 16.0),

                            Text('friends: ${authState.user.friends.length}'),
                            // todo

                            SizedBox(height: 16.0),

                            Text(
                                'joined: ${timeago.format(authState.user.createdAt)}'),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                Divider(color: Theme.of(context).colorScheme.secondary),

                /// C H A T   S E T T I N G S

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: BlocBuilder<ChatCubit, ChatState>(
                    builder: (context, state) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(Style.cornerRadius),
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                          // try this:
                          // color: Theme.of(context).colorScheme.primaryContainer,
                          // and the border:
                          // border: Border.all(
                          //     color: Theme.of(context).colorScheme.secondary),
                          // boxShadow: [
                          //   BoxShadow(
                          //       color: Theme.of(context)
                          //           .colorScheme
                          //           .secondaryContainer
                          //           .withOpacity(0.5),
                          //       blurRadius: 2,
                          //       spreadRadius: 2,
                          //       offset: Offset(0.0, 2.0))
                          // ],
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            /// Caption
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                '✵ ✶ system_prompt ✶ ✵',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            SizedBox(height: 12),

                            /// Edit prompt
                            NotificationListener<OverscrollNotification>(
                              /// Couples scrolling to list view parent
                              onNotification: (notification) {
                                if (_promptFieldScrollController
                                        .position.atEdge &&
                                    notification.overscroll != 0) {
                                  if (_listViewScrollController.hasClients) {
                                    final newOffset = _listViewScrollController
                                            .position.pixels +
                                        notification.overscroll * 0.8;

                                    _listViewScrollController.jumpTo(newOffset);
                                  }
                                  return true;
                                }
                                return false;
                              },
                              child: TextField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            Style.cornerRadius - 8.0)),
                                  ),
                                  labelText: '$tokenCounter tokens',
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                ),
                                // by default bodyLarge
                                style: Theme.of(context).textTheme.bodyMedium,
                                minLines: 12,
                                maxLines: 24,
                                controller: _promptFieldTextController,
                                scrollController: _promptFieldScrollController,

                                /// unfocus on tap outside!
                                focusNode: _promptFocusNode,
                                onTapOutside: (_) {
                                  _promptFocusNode.unfocus();
                                },
                                onChanged: onChanged,
                              ),
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
                            ),

                            SizedBox(height: 12),

                            /// Update Prompt

                            FilledButton(
                              // tonal looks better
                              onPressed: changesMade
                                  ? () {}
                                  : null,
                              child: Text(
                                changesMade
                                    ? 'apply changes'
                                    : 'type to update',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .copyWith(
                                      fontSize: 20,
                                      color: changesMade
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onPrimary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onPrimary
                                              .withAlpha(120),
                                    ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),

                            SizedBox(height: 12),

                            /// Reset Prompt to default (conf. dialog)

                            OutlinedButton(
                              // tonal looks better
                              onPressed: () {
                                // todo
                              },
                              child: Text(
                                'reset to default',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .copyWith(
                                      fontSize: 20,
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                padding: EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                Divider(color: Theme.of(context).colorScheme.secondary),

                /// A C C O U N T   S E T T I N G S

                /// Email

                /// Logout
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 8.0),
                  child: FilledButton.tonal(
                    // tonal looks better
                    onPressed: () async {
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _logOutLoading
                            ? LoadingWidget()
                            : Icon(Icons.logout, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'log_out',
                          style:
                              Theme.of(context).textTheme.labelLarge!.copyWith(
                                    fontSize: 20,
                                  ),
                        ),
                      ],
                    ),
                    style: FilledButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        padding: EdgeInsets.symmetric(vertical: 8)),
                  ),
                ),

                /// Delete Account

                /// A P P   S E T T I N G S

                // buffer
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// D I A L O G S

  /// confirm changes to system prompt
  /// (shows snackbar)
  void _showSystemPromptDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('confirm changes'),
          content: Text(
              'your current prompt will be overwritten and cannot be restored.'),
          actions: [
            FilledButton(
              onPressed: () async {
                ChatCubit chatCubit = context.read<ChatCubit>();
                Navigator.pop(context);
                await chatCubit
                    .updateSystemPrompt(_promptFieldTextController.text);

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(chatCubit.state.status == ChatStatus.success
                        ? 'system prompt was successfully updated.'
                        : 'error occurred while updating system prompt: ${chatCubit.state.errorMessage}')));
              },
              child: Text('confirm'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('cancel'),
            )
          ],
        );
      },
    );
  }
}
