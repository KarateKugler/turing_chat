import 'package:flutter/material.dart';

class TextFieldDialog extends StatefulWidget {
  final void Function()? onSubmitted;
  final String titleText;
  final String hintText;
  final String submitText;

  const TextFieldDialog({required this.onSubmitted, super.key, required this.titleText, required this.hintText, required this.submitText});

  @override
  State<TextFieldDialog> createState() => _TextFieldDialogState();
}

class _TextFieldDialogState extends State<TextFieldDialog> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titleText),
      contentPadding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      shape: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      content: TextField(
        controller: _textController,
        decoration: InputDecoration(hintText: widget.hintText),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onSubmitted!();
            Navigator.of(context).pop();
          },
          child: Text(widget.submitText),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('cancel'),
        ),
      ],
    );;
  }
}
