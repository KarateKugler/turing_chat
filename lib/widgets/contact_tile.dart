import 'package:flutter/material.dart';

class ContactTile extends StatelessWidget {
  final String text;
  final int? unread;
  final void Function()? onTap;


  const ContactTile({required this.text, this.unread, this.onTap, super.key,});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(text, style: Theme.of(context).textTheme.titleLarge),
      leading: Icon(Icons.chat, size: 20,),
      onTap: onTap,
      tileColor: Theme.of(context).colorScheme.tertiaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),

    );
  }
}
