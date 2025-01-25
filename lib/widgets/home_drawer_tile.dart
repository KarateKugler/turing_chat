import 'package:flutter/material.dart';

class HomeDrawerTile extends StatelessWidget {
  final String text;
  final Widget? icon;
  final void Function()? onTap;

  const HomeDrawerTile({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 36.0),
      title: Text(
        text,
      ),
      leading: icon,
      onTap: onTap,
    );
  }
}
