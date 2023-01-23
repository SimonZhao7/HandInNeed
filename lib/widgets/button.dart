import 'package:flutter/material.dart';
// Constants
import '../constants/widget_const/default_button_values.dart';

class Button extends StatelessWidget {
  final void Function() onPressed;
  final EdgeInsetsGeometry? padding;
  final String? label;
  final Widget? center;
  final Widget? icon;
  final Widget? trailing;
  final double height;
  final double borderRadius;
  final int? backgroundColor;
  final int? textColor;

  const Button({
    super.key,
    required this.onPressed,
    this.label,
    this.padding,
    this.textColor,
    this.height = defaultHeight,
    this.borderRadius = defaultBorderRadius,
    this.backgroundColor,
    this.center,
    this.icon,
    this.trailing,
  });

  List<Widget> renderContent() {
    List<Widget> result = [];
    if (icon != null) {
      result.add(
        Align(
          alignment: Alignment.centerLeft,
          child: icon,
        ),
      );
    }
    result.add(
      Align(
        alignment: Alignment.center,
        child: center ??
            Text(
              label ?? '',
              style: TextStyle(
                color: textColor != null ? Color(textColor!) : null,
                fontSize: defaultFontSize,
              ),
            ),
      ),
    );
    if (trailing != null) {
      result.add(
        Align(
          alignment: Alignment.centerRight,
          child: trailing,
        ),
      );
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor:
            backgroundColor != null ? Color(backgroundColor!) : null,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(borderRadius),
          ),
        ),
      ),
      child: Stack(children: renderContent()),
    );
  }
}
