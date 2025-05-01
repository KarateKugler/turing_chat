import 'package:flutter/material.dart';

class ChatInputField extends StatelessWidget {
  final FocusNode? focusNode;
  final TextEditingController controller;
  final void Function(String value)? onChanged;

  const ChatInputField({
    super.key,
    this.focusNode,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: focusNode,
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        hintText: 'Type a message...',
      ),
      onTapUpOutside: focusNode != null ? (_) {
        focusNode!.unfocus();
      } : null,
      style: Theme.of(context).textTheme.bodyMedium,
      minLines: 1,
      maxLines: 5,
    );
  }
}
