import 'package:flutter/material.dart';

import '../models/contact.dart';
import '../theme/style.dart';
import 'shadow_widget.dart';

const double leadingIconSize = 25;

class ContactTile extends StatelessWidget {
  final String text;
  final int? unread;
  final FriendStatus friendStatus;
  final OnlineStatus onlineStatus;
  final void Function()? onTap;
  final String? lastMessage;
  final bool isLastMessageFromUser;

  const ContactTile({
    required this.text,
    this.unread,
    required this.friendStatus,
    required this.onlineStatus,
    this.onTap,
    this.lastMessage,
    this.isLastMessageFromUser = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Widget leading;
    String? suffix;
    String? onTapMessage;
    Color tileColor = Theme.of(context).colorScheme.tertiaryContainer;
    Color borderColor = onlineStatus.isOnline
        ? Theme.of(context).colorScheme.primary
        : Colors.transparent; // can add some pulsating effect?

    switch (friendStatus) {
      case FriendStatus.error:
        leading = Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.error,
          size: leadingIconSize,
        );
        suffix = '(error...)';
        onTapMessage = 'an unknown error occured, please let me know.';
        break;

      case FriendStatus.requestedOut:
        leading = const Icon(
          Icons.schedule_send,
          size: leadingIconSize,
        );
        suffix = '(/pending<>>)';
        onTapMessage = 'the contact has not accepted your request... ._.';
        tileColor = tileColor.withAlpha(150);
        break;

      case FriendStatus.requestedIn:
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
        suffix = '> (accept) <';
        break;

      case FriendStatus.friend:
        leading = const Icon(
          Icons.chat,
          size: leadingIconSize,
        );
        suffix = null;
        break;

      case FriendStatus.blockedIn:
        leading = Icon(
          Icons.block,
          color: Theme.of(context).colorScheme.error,
          size: leadingIconSize,
        );
        suffix = '(blocked you)';
        onTapMessage = 'this contact has blocked you! <0.o>';
        tileColor = tileColor.withAlpha(150);
        break;

      case FriendStatus.blockedOut:
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

    return ShadowWidget(
      shadow: [BoxShadow(color: borderColor, spreadRadius: 2, blurRadius: 5)],
      color: tileColor,
      borderRadius: BorderRadius.circular(Style.contactTileBorderRadius),
      child: ListTile(
        /// username and online status
        title: RichText(
            text: TextSpan(
          text: suffix != null ? '$text $suffix' : text,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontStyle: suffix != null ? FontStyle.italic : FontStyle.normal,
              ),
          children: [
            TextSpan(
              text: onlineStatus.isOnline ? ' (online)' : '',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        )),
        /// leading icon
        leading: leading,
        onTap: onTapMessage == null
            ? onTap
            : () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(onTapMessage!)));
              },
        tileColor: tileColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Style.contactTileBorderRadius)),
        trailing: null,
        subtitle: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Text(
            lastMessage != null 
                ? (isLastMessageFromUser ? 'you? :  ' : '$text? :  ') + lastMessage!
                : '',
            style: Theme.of(context).textTheme.labelMedium!.copyWith(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
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
