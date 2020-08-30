import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/models/message.dart';

import '../../../consts.dart';

class ReplyMessagePreview extends StatelessWidget {
  const ReplyMessagePreview({
    Key key,
    @required this.repliedMessage,
    @required this.userId,    
    @required this.reply,
    @required this.peerName,
    @required this.onCanceled,    
  }) : super(key: key);

  final Message repliedMessage;
  final String userId;
  // final Message replyMsg;
  final String peerName;
  final bool reply;
  final Function onCanceled;  

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: RichText(
                    text: TextSpan(
                      text: 'Replying to ',
                      style: TextStyle(
                        fontSize: 14,
                        color: kBaseWhiteColor,
                        // fontWeight: FontWeight.w600,
                      ),
                      children: [
                        TextSpan(
                          text: repliedMessage.fromId == userId
                              ? 'yourself'
                              : peerName,
                          style: TextStyle(
                            fontSize: 15,
                            color: kBaseWhiteColor,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                    height: repliedMessage.type == MessageType.Text ? 5 : 0),
                Flexible(
                  child: repliedMessage.type == MessageType.Text
                      ? Text(
                          repliedMessage?.content,
                          style: TextStyle(
                              color: kBaseWhiteColor.withOpacity(0.7)),
                          overflow: TextOverflow.ellipsis,
                        )
                      : Container(
                          height: 30,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: kBaseWhiteColor.withOpacity(0.5),
                              ),
                              SizedBox(width: 5),
                              Text('Photo')
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                  maxWidth: repliedMessage.type == MessageType.Text ? 54 : 130),
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (repliedMessage.type == MessageType.Media)
                    Container(
                      width: 40,
                      height: 50,
                      child: CachedNetworkImage(
                        imageUrl: repliedMessage.mediaUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  SizedBox(width: 10),
                  CupertinoButton(
                    padding: const EdgeInsets.only(
                        left: 0, top: 0, bottom: 0, right: 10),
                    onPressed: onCanceled,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                              color: Theme.of(context).accentColor, width: 2)),
                      child: Icon(Icons.close,
                          color: Theme.of(context).accentColor, size: 17),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
