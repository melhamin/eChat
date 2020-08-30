import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_clone/models/message.dart';
import 'package:whatsapp_clone/providers/chat.dart';
import 'package:whatsapp_clone/screens/chats_screen/widgets/avatar.dart';
import 'package:whatsapp_clone/screens/chats_screen/widgets/chat_text.dart';
import 'package:whatsapp_clone/screens/chats_screen/widgets/seen_status.dart';
import 'package:whatsapp_clone/widgets/media_view.dart';
import 'package:whatsapp_clone/widgets/video_player.dart';

import '../../../consts.dart';
import 'dismissible_bubble.dart';

class MediaBubble extends StatelessWidget {
  final Message message;
  final Function onReplied;
  final String avatarImageUrl;

  const MediaBubble({
    Key key,
    @required this.message,
    @required this.onReplied,
    @required this.avatarImageUrl,
  }) : super(key: key);

  void navToImageView(BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          MediaView(url: message.mediaUrl, type:message.mediaType),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = 0.0;
        var end = 1.0;
        var tween = Tween(begin: begin, end: end);
        var fadeAnimation = animation.drive(tween);

        return FadeTransition(
          opacity: fadeAnimation,
          child: child,
        );
      },
    ));
  }

  Widget _buildWithoutText(BuildContext context, Size size, bool isMe) {    
    return Stack(
      children: [
        Container(          
          constraints: BoxConstraints(
            minWidth: size.width * 0.7,
            maxWidth: size.width * 0.7,
            minHeight: size.height * 0.35,
            maxHeight: size.height * 0.35,
          ),
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: message.mediaType == MediaType.Video
              ? CVideoPlayer(
                  url: message.mediaUrl,
                  isLocal: false,
                )
              : CachedNetworkImage(
                  imageUrl: message.mediaUrl,                          
                  fit: BoxFit.cover,
                ),
          ),
           
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                          child: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.all(5),
                height: 30,
                constraints: BoxConstraints(
                  maxWidth: size.width * 0.8,
                ),
                width: double.infinity,
                decoration: BoxDecoration(
                  // borderRadius: BorderRadius.only(
                  //   bottomLeft: Radius.circular(10),
                  //   bottomRight: Radius.circular(10),
                  // ),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.01),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: SeenStatus(
                  isMe: isMe,
                  isSeen: message.isSeen,
                  timestamp: message.sendDate,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWithText(BuildContext context, Size size, bool isMe) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      alignment: WrapAlignment.end,
      runAlignment: WrapAlignment.spaceBetween,
      children: [
        Wrap(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                constraints: BoxConstraints(
                  minWidth: size.width * 0.7,
                  maxWidth: size.width * 0.7,
                  minHeight: size.height * 0.35,
                  maxHeight: size.height * 0.35,
                ),
                child: CachedNetworkImage(
                  imageUrl: message.mediaUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: ChatText(text: message.content)),
          ],
        ),
        SeenStatus(
          isMe: isMe,
          isSeen: message.isSeen,
          timestamp: message.sendDate,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMe =
        Provider.of<Chat>(context, listen: false).getUserId == message.fromId;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isMe) Avatar(imageUrl: avatarImageUrl),
        if (!isMe) SizedBox(width: 5),
        Flexible(
          child: Hero(
            tag: message.mediaUrl,
            child: DismssibleBubble(
              isMe: isMe,
              message: message,
              onDismissed: onReplied,
              child: GestureDetector(
                onTap: () => navToImageView(context),
                child: Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: isMe ? null : (message.type != MessageType.Media && message.content != null) ?  Border.all(color: kBorderColor3) : null,
                      color: isMe ? kBlackColor3 : kBlackColor,
                    ),
                    padding: const EdgeInsets.all(5),
                    constraints: BoxConstraints(
                      minWidth: size.width * 0.7,
                      maxWidth: size.width * 0.7,
                      minHeight: size.height * 0.35,
                      // maxHeight: mq.size.height * 0.35,
                    ),
                    child: message.content == null || message.content.isEmpty
                        ? _buildWithoutText(context, size, isMe)
                        : _buildWithText(context, size, isMe),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
