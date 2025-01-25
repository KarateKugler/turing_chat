import 'package:flutter/material.dart';

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
