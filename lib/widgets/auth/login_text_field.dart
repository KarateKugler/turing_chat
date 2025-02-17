import 'package:flutter/material.dart';

class LoginTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final IconData? prefixIcon;
  final TextEditingController controller;
  final String? errorText;

  const LoginTextField({
    super.key,
    required this.hintText,
    required this.obscureText,
    this.prefixIcon,
    required this.controller,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        icon: prefixIcon != null
            ? Icon(
                prefixIcon,
              )
            : null,
        filled: true,
        hintText: hintText,
        errorText: errorText,
      ),
      autocorrect: false,
      controller: controller,

      /// obscure with *
      obscuringCharacter: '*',
    );
  }

// @override
// Widget build(BuildContext context) {
//   return TextField(
//     obscureText: obscureText,
//     style: TextStyle(
//       color: Theme.of(context).colorScheme.onTertiaryContainer,
//     ),
//     decoration: InputDecoration(
//       enabledBorder: OutlineInputBorder(
//         borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 2),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 2),
//
//       ),
//       icon: Icon(prefixIcon, color: Theme.of(context).colorScheme.onSurface,),
//       fillColor: Theme.of(context).colorScheme.tertiaryContainer,
//       filled: true,
//       hintText: hintText,
//       hintStyle: TextStyle(
//         color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
//       ),
//     ),
//   );
// }
}
