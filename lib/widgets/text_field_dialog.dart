import 'package:flutter/material.dart';

import '../theme/style.dart';

class TextFieldDialog extends StatefulWidget {
  final void Function(String submitText)? onSubmitted;
  final bool Function(String submitText)? validator;
  final String titleText;
  final String hintText;
  final String submitText;
  final String errorHint;

  const TextFieldDialog({
    super.key,
    required this.onSubmitted,
    required this.validator,
    required this.titleText,
    required this.hintText,
    required this.submitText,
    required this.errorHint,
  });

  @override
  State<TextFieldDialog> createState() => _TextFieldDialogState();
}

class _TextFieldDialogState extends State<TextFieldDialog> {
  final TextEditingController _textController = TextEditingController();
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titleText),
      contentPadding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Style.cornerRadius)),
      content: TextField(
        controller: _textController,
        decoration: InputDecoration(
          hintText: widget.hintText,
          errorText: _errorText,
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () {
            /// validate input string
            _errorText = null;
            if (widget.validator != null &&
                !widget.validator!(_textController.text)) {
              _errorText = widget.errorHint;
              return;
            }

            /// if valid, call onSubmitted function
            widget.onSubmitted!(_textController.text);
            Navigator.of(context).pop();
          },
          child: Text(
            widget.submitText,
            style: Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
          style: OutlinedButton.styleFrom(
              side: BorderSide(color:
                  Theme.of(context).colorScheme.onPrimaryContainer)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'cancel',
            style: Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
        ),
      ],
      actionsPadding: EdgeInsets.all(16.0),
    );
  }
}
