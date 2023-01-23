import 'package:flutter/material.dart';
// Constants
import 'package:hand_in_need/constants/colors.dart';
import 'package:hand_in_need/constants/widget_const/default_input_values.dart';

class Input extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType? type;
  final EdgeInsetsGeometry? innerPadding;
  final String? hint;
  final bool password;
  final bool autofocus;
  final bool autocorrect;
  final double borderRadius;
  final double borderWidth;
  final int borderColor;
  final int maxLines;
  final int? focusedBorderColor;
  final int? cursorColor;

  const Input({
    super.key,
    required this.controller,
    this.password = false,
    this.hint,
    this.type,
    this.innerPadding,
    this.borderRadius = defaultBorderRadius,
    this.borderWidth = defaultBorderWidth,
    this.borderColor = black,
    this.focusedBorderColor,
    this.cursorColor,
    this.autofocus = false,
    this.autocorrect = false,
    this.maxLines = defaultMaxLines,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      textAlignVertical: TextAlignVertical.center,
      controller: controller,
      keyboardType: type,
      obscureText: password,
      cursorColor: cursorColor != null ? Color(cursorColor!) : Colors.black,
      autocorrect: autocorrect,
      autofocus: autofocus,
      maxLines: maxLines,
      style: const TextStyle(
        color: Colors.black,
      ),
      decoration: InputDecoration(
        contentPadding: innerPadding ??
            const EdgeInsets.symmetric(
              vertical: defaultInnerPaddingV,
              horizontal: defaultInnerPaddingH,
            ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(borderColor),
            width: borderWidth,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(borderRadius),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: focusedBorderColor != null
                ? Color(focusedBorderColor!)
                : Color(borderColor),
            width: borderWidth,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(borderRadius),
          ),
        ),
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(mediumGray),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
