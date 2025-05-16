import 'package:flutter/material.dart';
import 'package:healthbot_app/models/chat_message.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:healthbot_app/utils/text_styles.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  MessageBubble(this.message);

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final radius = isUser
        ? BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          )
        : BorderRadius.only(
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Image.asset(
                'assets/images/image_profile_healthbot.png',
                height: 38,
              ),
            ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isUser ? Color(0xFFD7F1FF) : Color(0xFFE3E9F3),
              borderRadius: radius,
            ),
            child: RichText(
              text: _buildFormattedText(message.text),
            ),
          ),
        ],
      ),
    );
  }

  TextSpan _buildFormattedText(String text) {
    List<TextSpan> spans = [];
    RegExp exp = RegExp(r'\*\*(.*?)\*\*');
    int lastMatchEnd = 0;
    
    for (Match match in exp.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: AppTextStyles.interRegular16.copyWith(
            color: Color(0xFF3B3B3B),
            height: 1.6,
            letterSpacing: 0.2,
          ),
        ));
      }
      
      spans.add(TextSpan(
        text: match.group(1),
        style: AppTextStyles.interBold16.copyWith(
          color: Color(0xFF3B3B3B),
          height: 1.6,
          letterSpacing: 0.2,
        ),
      ));
      
      lastMatchEnd = match.end;
    }
    
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: AppTextStyles.interRegular16.copyWith(
          color: Color(0xFF3B3B3B),
          height: 1.6,
          letterSpacing: 0.2,
        ),
      ));
    }
    
    return TextSpan(children: spans);
  }
}
