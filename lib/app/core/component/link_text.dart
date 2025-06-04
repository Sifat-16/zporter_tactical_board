import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// A widget that displays text styled as a hyperlink and launches a URL when tapped.
class LinkText extends StatelessWidget {
  /// The text to display.
  final String text;

  /// The URL to launch when the text is tapped.
  final String url;

  /// The style to apply to the link text.
  /// Defaults to blue color with an underline.
  final TextStyle? style;

  /// The text style to use when the link is hovered (for web/desktop).
  /// Defaults to a slightly brighter blue with an underline.
  final TextStyle? hoverStyle;

  /// Creates a LinkText widget.
  ///
  /// [text] is the string that will be displayed.
  /// [url] is the string representing the URL to be launched.
  /// [style] is an optional TextStyle for the link.
  /// [hoverStyle] is an optional TextStyle for the link when hovered.
  const LinkText({
    Key? key,
    required this.text,
    required this.url,
    this.style,
    this.hoverStyle,
  }) : super(key: key);

  /// Attempts to launch the given URL.
  ///
  /// Shows a SnackBar if the URL can't be launched.
  Future<void> _launchUrl(BuildContext context) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        // It's good practice to show feedback to the user if launching fails.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch $url. Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch $url'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Default style for the link
    final TextStyle defaultStyle = TextStyle(
      color: Colors.blue,
      decoration: TextDecoration.underline,
      decorationColor: Colors.blue, // Ensure underline color matches text
    );

    // Default hover style for the link
    final TextStyle defaultHoverStyle = TextStyle(
      color: Colors.blue.shade700, // A slightly different shade for hover
      decoration: TextDecoration.underline,
      decorationColor: Colors.blue.shade700,
    );

    // Use provided style or default
    final TextStyle currentStyle = style ?? defaultStyle;
    final TextStyle currentHoverStyle = hoverStyle ?? defaultHoverStyle;

    return MouseRegion(
      cursor: SystemMouseCursors.click, // Show a pointer cursor on hover
      child: GestureDetector(
        onTap: () => _launchUrl(context),
        child: Text(
          text,
          style: currentStyle,
        ),
      ),
    );
  }
}
