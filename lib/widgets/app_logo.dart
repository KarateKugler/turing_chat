import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: Theme.of(context).colorScheme.tertiary,
        border: Border.all(
            color: Theme.of(context).colorScheme.primary),
      ),
      child: Icon(
        Icons.chat,
        size: 60,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}