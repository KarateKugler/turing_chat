import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../logic/auth_cubit.dart';
import '../theme/style.dart';

class SharePage extends StatefulWidget {
  const SharePage({super.key});

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  final String _inviteLink =
      'https://play.google.com/apps/testing/com.aspect.turing_chat';
  late String _inviteText;

  @override
  void initState() {
    super.initState();
    final String username =
        (context.read<AuthCubit>().state as AuthLoggedIn).user.username;

    _inviteText = '''Join me in testing: Turing Chat - a fun AI chat game! 🎮
  
https://play.google.com/apps/testing/com.aspect.turing_chat

Test your skills in this unique chat game where you try to figure out if you\'re talking to a human or an AI machine. 
      
My username is: $username''';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('╚╗ ⎇ share ⎇ ╔╝'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _ShareInfo(),
                SizedBox(height: 20),
                _QRCodeSection(inviteLink: _inviteLink),
                SizedBox(height: 20),
                _ShareOptionsSection(inviteText: _inviteText),
                SizedBox(height: 40),
                Divider(color: theme.colorScheme.onSurfaceVariant),
                Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                        child: Text('Thank you for sharing!',
                            style: theme.textTheme.labelLarge!
                                .copyWith(fontStyle: FontStyle.italic)))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShareInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Style.cornerRadius),
        color: theme.colorScheme.primaryContainer,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invite Friends!',
              style: theme.textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Help us test Turing Chat! Share this with friends who you would like to play with.',
              style: theme.textTheme.bodyMedium!.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QRCodeSection extends StatelessWidget {
  final String inviteLink;

  const _QRCodeSection({required this.inviteLink});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Style.cornerRadius),
        color: theme.colorScheme.secondaryContainer,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'QR Code to Join',
              style: theme.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        QRCodeFullScreenPage(inviteLink: inviteLink),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Hero(
                  tag: 'qr_code_hero',
                  child: Image.asset(
                    'assets/images/qr_code.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Tap to view full screen',
              style: theme.textTheme.bodySmall!.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QRCodeFullScreenPage extends StatelessWidget {
  final String inviteLink;

  const QRCodeFullScreenPage({super.key, required this.inviteLink});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'QR Code',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: 'qr_code_hero',
              child: Container(
                padding: EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/qr_code.png',
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 32),
            Text(
              'Scan to join Testing',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareOptionsSection extends StatelessWidget {
  final String inviteText;

  const _ShareOptionsSection({required this.inviteText});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Style.cornerRadius),
        color: theme.colorScheme.secondaryContainer,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share Options',
              style: theme.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            SizedBox(height: 16),
            _ShareOption(
              icon: Icons.share,
              title: 'Share Testing Invite',
              subtitle: 'Via your device\'s share menu',
              onTap: () => Share.share(inviteText),
            ),
            SizedBox(height: 12),
            _ShareOption(
                icon: Icons.copy,
                title: 'Copy Link',
                subtitle: 'Copy to your Clipboard',
                onTap: () => _copyToClipboard(context)),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: inviteText));

    // Reset the copied state after 2 seconds
    Future.delayed(Duration(seconds: 2), () {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invite text copied to clipboard!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
