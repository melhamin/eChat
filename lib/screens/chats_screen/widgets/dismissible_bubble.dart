import 'package:flutter/material.dart';
import 'package:whatsapp_clone/models/message.dart';

import '../../../consts.dart';


class DismssibleBubble extends StatelessWidget {
  final bool isMe;
  final Message message;
  final Widget child;
  final Function onDismissed;
  const DismssibleBubble({
    this.isMe,
    this.message,
    this.child,
    this.onDismissed,
    Key key,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(      
      direction: isMe
          ? DismissDirection.endToStart
          : DismissDirection.startToEnd,
      onDismissed: (direction) {},
      key: UniqueKey(),
      confirmDismiss: (_) async {                      
        final f = Future.delayed(Duration.zero).then((value) {
          onDismissed(message);
          return false;
        });
        return await f;
      },
      background: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Wrap(
          children: [
            if(!isMe)
            SizedBox(width: 20),
            FittedBox(
                child: Icon(
              Icons.reply,
              color: kBaseWhiteColor.withOpacity(0.5),
            )),
            if(isMe)
            SizedBox(width: 20),
          ],
        ),
      ),
      child: child,
    );
  }
}
