import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:whatsapp_clone/models/message.dart';
import 'package:whatsapp_clone/models/user.dart';

import '../../../consts.dart';

class ChatReplyBubble extends StatelessWidget {
  const ChatReplyBubble({
    @required this.message,
    @required this.peer,      
    Key key,
  }) : super(key: key);

  final Message message;
  final User peer;  

  String _getReplyDetails() {    
    if (message.fromId == peer.id) {
      if (message.reply.repliedToId == peer.id)
        return '${peer.username.split(' ')[0]} replied to themselve';
      return '${peer.username.split(' ')[0]} replied to you';
    } else {
      if (message.reply.repliedToId == peer.id)
        return 'You replied to ${peer.username.split(' ')[0]}';
      return 'You replied to yourself';
    }
  }

  @override
  Widget build(BuildContext context) {
    // check if message is replied by peer or user and
    // render details accordingly
    final isPeerMsg = message.fromId == peer.id;
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: _getReplyDetails,
      child: Container(
        child: Column(
          crossAxisAlignment: message.fromId == peer.id
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(right: message.reply.type == MessageType.Text ? 15 : 0),
              child: FittedBox(
                child: Row(
                  children: [
                    Icon(
                      Icons.reply,
                      size: 15,
                      color: kBaseWhiteColor.withOpacity(0.5),
                    ),
                    SizedBox(width: 3),
                    Text(
                      _getReplyDetails(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: kBaseWhiteColor.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: message.reply.type ==MessageType.Text ? 2 : 5),
            message.reply.type == MessageType.Text
                ? _buildReplyText(size, isPeerMsg)
                : _buildMediaReply(size),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyText(Size size, bool isPeerMsg) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: size.width * 0.8,
        minWidth: 60,
      ),
      // alignment: Alignment.topCenter,
      padding: const EdgeInsets.only(top: 10, right: 15, left: 15, bottom: 30),
      // margin: EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: kBlackColor2
      ),
      child: Text(
        message.reply.content,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: kBaseWhiteColor.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildMediaReply(Size size) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: size.width * 0.3,
      ),
      // alignment: Alignment.topCenter,
      width: double.infinity,
      height: size.height * 0.25,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: kBlackColor2.withOpacity(0.45),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CachedNetworkImage(
          imageUrl: message.reply.content,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}


