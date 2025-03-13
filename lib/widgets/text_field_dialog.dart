import 'package:flutter/material.dart';

import '../theme/style.dart';

class TextFieldDialog extends StatefulWidget {
  final void Function(String submitText)? onSubmitted;
  final bool Function(String submitText)? validator;
  final Widget? content;
  final String titleText;
  final String hintText;
  final String submitText;
  /// whether it is a critical action
  final bool critical;
  final String errorHint;

  const TextFieldDialog({
    super.key,
    required this.onSubmitted,
    required this.validator,
    this.content,
    required this.titleText,
    required this.hintText,
    required this.submitText,
    required this.critical,
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.content ?? SizedBox.shrink(),
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              hintText: widget.hintText,
              errorText: _errorText,
            ),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () {
            /// validate input string
            _errorText = null;
            if (widget.validator != null &&
                !widget.validator!(_textController.text)) {
              setState(() {
                _errorText = widget.errorHint;
              });
              return;
            }

            /// if valid, call onSubmitted function
            widget.onSubmitted!(_textController.text);
            Navigator.of(context).pop();
          },
          style: FilledButton.styleFrom(
            backgroundColor: widget.critical ? Theme.of(context).colorScheme.error : null,
          ),
          child: Text(
            widget.submitText,
            style: Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'cancel',
          ),
        ),
      ],
      actionsPadding: EdgeInsets.all(16.0),
    );
  }
}
