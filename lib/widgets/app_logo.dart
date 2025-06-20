import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.animatedBorderEnabled = false,
  });


  final bool animatedBorderEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Theme.of(context).colorScheme.primary),
        ),
        child: SizedBox(
          height: 80,
          width: 80,
          child: Image.asset(
            'assets/icon/icon4.png',
            fit: BoxFit.contain,
          ),
        ),
    );
  }
}
