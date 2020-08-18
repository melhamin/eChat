import 'package:flutter/material.dart';

import '../../../consts.dart';

class ChatText extends StatelessWidget {
  const ChatText({
    Key key,
    @required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SelectableText(
        text,
        style: TextStyle(
          fontSize: 17,
          color: kBaseWhiteColor,
        ),
      ),
    );
  }
}
