import 'package:flutter/material.dart';
import 'package:turing_chat/widgets/app_logo.dart';
import 'package:turing_chat/widgets/loading_widget.dart';

/// The Splash Page (not in use, should not be necessary ideally)
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// The App Logo
            AppLogo(),

            SizedBox(height: 20),

            /// The Loading Indicator
            LoadingWidget(size: 30),
          ],
        ),
      ),
    );
  }
}
