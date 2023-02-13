import 'package:flutter/material.dart';
import 'package:hand_in_need/constants/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkText extends StatefulWidget {
  final String? leading;
  final String? trailing;
  final String url;
  final TextStyle? style;
  final String scheme;
  const LinkText({
    super.key,
    this.leading,
    this.trailing,
    required this.url,
    this.style,
    required this.scheme,
  });

  @override
  State<LinkText> createState() => _LinkTextState();
}

class _LinkTextState extends State<LinkText> {
  bool _tapped = false;

  @override
  Widget build(BuildContext context) {
    final url = widget.scheme == 'https'
        ? Uri.parse(widget.url)
        : Uri(
            scheme: widget.scheme,
            path: widget.url,
          );

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _tapped = true;
        });
      },
      onTapUp: (_) async {
        await launchUrl(url);
        setState(() {
          _tapped = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _tapped = false;
        });
      },
      child: RichText(
        text: TextSpan(
          style: widget.style ?? Theme.of(context).textTheme.labelMedium,
          text: widget.leading,
          children: [
            TextSpan(
              text: widget.url,
              style: TextStyle(
                fontSize: widget.style?.fontSize,
                color: _tapped ? const Color(blue) : Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
