import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatBubble({super.key, required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isUser ? colorScheme.primary : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ]
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: isUser 
          ? Text(
              text,
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontSize: 15,
              ),
            )
          : MarkdownBody(
              data: text,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(color: colorScheme.onSurface, fontSize: 15),
                strong: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
                listBullet: TextStyle(color: colorScheme.onSurface),
              ),
            ),
      ),
    );
  }
}
