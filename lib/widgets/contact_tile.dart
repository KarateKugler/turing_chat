import 'package:flutter/material.dart';

import '../models/contact.dart';

const double leadingIconSize = 25;

class ContactTile extends StatelessWidget {
  final String text;
  final int? unread;
  final ContactStatus status;
  final void Function()? onTap;

  const ContactTile({
    required this.text,
    this.unread,
    required this.status,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Widget leading;
    String? suffix;
    String? onTapMessage;
    Color tileColor = Theme.of(context).colorScheme.tertiaryContainer;

    switch (status) {
      case ContactStatus.error:
        leading = Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.error,
          size: leadingIconSize,
        );
        suffix = '(error...)';
        onTapMessage = 'an unknown error occured, please let me know.';
        break;

      case ContactStatus.requestedOut:
        leading = const Icon(
          Icons.schedule_send,
          size: leadingIconSize,
        );
        suffix = '(/pending<>>)';
        onTapMessage = 'the contact has not accepted your request... ._.';
        tileColor = tileColor.withAlpha(150);
        break;

      case ContactStatus.requestedIn:
        leading = const Icon(
          Icons.mail,
          size: leadingIconSize,
          shadows: [
            Shadow(
              color: Color(0xFF5F00FF),
              blurRadius: 60,
            )
          ],
        );
        suffix = '>> ... (accept)';
        break;

      case ContactStatus.friend:
        leading = const Icon(
          Icons.chat,
          size: leadingIconSize,
        );
        suffix = null;
        break;

      case ContactStatus.blockedIn:
        leading = Icon(
          Icons.block,
          color: Theme.of(context).colorScheme.error,
          size: leadingIconSize,
        );
        suffix = '(blocked you)';
        onTapMessage = 'this contact has blocked you! <0.o>';
        tileColor = tileColor.withAlpha(150);
        break;

      case ContactStatus.blockedOut:
        leading = Icon(
          Icons.no_accounts,
          color: Theme.of(context).colorScheme.error,
          size: leadingIconSize,
        );
        suffix = '(is blocked)';
        onTapMessage = 'you  b l o c k e d  this contact! o>o>';
        tileColor = tileColor.withAlpha(150);
        break;
    }

    return ListTile(
      title: Text(
        suffix != null ? '$text $suffix' : text,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontStyle: suffix != null ? FontStyle.italic : FontStyle.normal),
      ),
      leading: leading,
      onTap: onTapMessage == null
          ? onTap
          : () {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(onTapMessage!)));
            },
      tileColor: tileColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      trailing: null,
    );
  }

  Widget? _buildTrailing(BuildContext context) {
    return Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Center(
        child: Text(
          '1', // todo
          style: Theme.of(context)
              .textTheme
              .labelMedium!
              .copyWith(color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
    );
  }
}
