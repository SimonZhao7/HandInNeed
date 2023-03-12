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
  final bool password;
  final bool autofocus;
  final bool autocorrect;
  final bool readOnly;
  final bool? enabled;
  final double borderRadius;
  final double borderWidth;
  final int borderColor;
  final int maxLines;
  final int? maxLength;
  final int? focusedBorderColor;
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
    this.borderColor = black,
    this.focusedBorderColor,
    this.cursorColor,
    this.autofocus = false,
    this.autocorrect = false,
    this.maxLines = defaultMaxLines,
    this.maxLength,
    this.fillColor,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.enabled,
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
      maxLength: maxLength,
      onChanged: onChanged,
      style: const TextStyle(
        color: Colors.black,
      ),
      onTap: onTap,
      enabled: enabled,
      readOnly: readOnly,
      decoration: InputDecoration(
        filled: true,
        fillColor: fillColor != null ? Color(fillColor!) : null,
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
        disabledBorder: OutlineInputBorder(
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
        counter: const SizedBox(height: 0),
      ),
    );
  }
}
