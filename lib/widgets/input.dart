import 'package:flutter/material.dart';
// Constants
import 'package:hand_in_need/constants/widget_const/default_input_values.dart';
import 'package:hand_in_need/constants/colors.dart';

class Input extends StatelessWidget {
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final TextEditingController controller;
  final TextInputType? type;
  final EdgeInsetsGeometry? innerPadding;
  final String? hint;
  final bool border;
  final bool password;
  final bool autofocus;
  final bool autocorrect;
  final bool readOnly;
  final bool enabled;
  final double borderRadius;
  final double borderWidth;
  final int borderColor;
  final int maxLines;
  final int textColor;
  final int hintColor;
  final int? maxLength;
  final int? cursorColor;
  final int? fillColor;

  const Input({
    super.key,
    required this.controller,
    this.password = false,
    this.hint,
    this.type,
    this.innerPadding,
    this.borderRadius = defaultBorderRadius,
    this.borderWidth = defaultBorderWidth,
    this.borderColor = secondary,
    this.border = true,
    this.cursorColor,
    this.autofocus = false,
    this.autocorrect = false,
    this.maxLines = defaultMaxLines,
    this.maxLength,
    this.fillColor,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
    this.textColor = black,
    this.hintColor = mediumGray,
  });

  @override
  Widget build(BuildContext context) {
    final borderStyle = OutlineInputBorder(
      borderSide: border
          ? BorderSide(
              color: Color(borderColor),
              width: borderWidth,
            )
          : BorderSide.none,
      borderRadius: BorderRadius.all(
        Radius.circular(borderRadius),
      ),
    );

    return TextField(
      textAlignVertical: TextAlignVertical.center,
      controller: controller,
      keyboardType: type,
      obscureText: password,
      cursorColor: cursorColor != null ? Color(cursorColor!) : Colors.black,
      autocorrect: autocorrect,
      autofocus: autofocus,
      maxLines: maxLines,
      maxLength: maxLength,
      onChanged: onChanged,
      style: TextStyle(
        color: Color(textColor),
      ),
      onTap: onTap,
      enabled: enabled,
      readOnly: readOnly,
      decoration: InputDecoration(
        filled: true,
        fillColor: fillColor != null
            ? Color(fillColor!)
            : (enabled ? const Color(white) : const Color(gray)),
        contentPadding: innerPadding ??
            const EdgeInsets.symmetric(
              vertical: defaultInnerPaddingV,
              horizontal: defaultInnerPaddingH,
            ),
        enabledBorder: borderStyle,
        disabledBorder: borderStyle,
        focusedBorder: borderStyle,
        hintText: hint,
        hintStyle: TextStyle(
          color: Color(hintColor),
          fontWeight: FontWeight.w500,
        ),
        counter: const SizedBox(height: 0),
      ),
    );
  }
}
