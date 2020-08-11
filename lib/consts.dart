import 'package:flutter/material.dart';

final String ALL_MESSAGES_COLLECTION = 'MESSAGES';
final String USERS_COLLECTION = 'USERS';
final String CHATS_COLLECTION = 'CHATS';
final String MEDIA_COLLECTION = 'MEDIA';

Color kBorderColor1 = Colors.white.withOpacity(0.1);
Color kBorderColor2 = Colors.white.withOpacity(0.07);

Color kBaseWhiteColor = Colors.white.withOpacity(0.87);

TextStyle kWhatsAppStyle = TextStyle(
  fontSize: 21,
  fontWeight: FontWeight.bold,
  color: Colors.black.withOpacity(0.95),
);

TextStyle kSelectedTabStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: Colors.black.withOpacity(0.95),
);

TextStyle kUnselectedTabStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: Colors.black.withOpacity(0.4),
);

TextStyle kChatItemTitleStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: Colors.white,
);

TextStyle kChatItemSubtitleStyle = TextStyle(
  fontSize: 14,
  color: Colors.white.withOpacity(0.7),
);

TextStyle kAppBarTitleStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: kBaseWhiteColor,
);

TextStyle kChatBubbleTextStyle = TextStyle(
  fontSize: 17,
  color: kBaseWhiteColor,
);
