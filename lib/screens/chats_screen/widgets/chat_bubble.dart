import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/models/message.dart';
import 'package:whatsapp_clone/models/person.dart';
import 'package:whatsapp_clone/screens/chats_screen/widgets/chat_reply_bubble.dart';
import 'package:whatsapp_clone/screens/chats_screen/widgets/media_bubble.dart';
import 'package:whatsapp_clone/screens/chats_screen/widgets/seen_status.dart';

import 'avatar.dart';
import 'chat_text.dart';
import 'dismissible_bubble.dart';

class ChatBubble extends StatefulWidget {
  final Message message;
  final bool isMe;
  final Person peer;
  final bool withoutAvatar;
  final Function onReplyPressed;
  ChatBubble({
    @required this.message,
    @required this.isMe,
    @required this.peer,
    @required this.withoutAvatar,
    this.onReplyPressed,
  }) : super();

  @override
  _ChatBubbleState createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble>
    with AutomaticKeepAliveClientMixin {
  GlobalKey key = GlobalKey<_ChatBubbleState>();

  dynamic getRadius() {
    if (widget.message.reply != null) {
      if (widget.isMe)
        return BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        );
      return BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
        topRight: Radius.circular(20),
      );
    }

    return BorderRadius.circular(20);
  }
  

  Widget _buildWithoutAvatar(BuildContext context, BoxConstraints constraints) {
    final size = MediaQuery.of(context).size;    
    return DismssibleBubble(
      isMe: widget.isMe,
      message: widget.message,
      onDismissed: widget.onReplyPressed,
      child: Wrap(
        children: [
          Stack(
            children: [
              if (widget.message.reply != null)
                Align(
                  alignment:
                      widget.isMe ? Alignment.topRight : Alignment.topLeft,
                  child: ChatReplyBubble(
                    message: widget.message,
                    peer: widget.peer,
                  ),
                ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  // key: key,
                  margin: widget.message.reply != null
                      ? EdgeInsets.only(
                          top: (widget.message.reply != null &&
                                  widget.message.reply.type == '0')
                              ? 50
                              : size.height * 0.25 - 5,
                        )
                      : const EdgeInsets.all(0),
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth * 0.8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: getRadius(),
                    border: widget.isMe
                        ? null
                        : Border.all(color: Hexcolor('#303030')),
                    color:
                        widget.isMe ? Hexcolor('#303030') : Hexcolor('#121212'),
                  ),
                  child: Padding(
                    key: key,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.end,
                      runAlignment: WrapAlignment.end,
                      alignment: WrapAlignment.end,
                      spacing: 20,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, bottom: 12),
                          child: ChatText(text: widget.message.content),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5.0),
                          child: SeenStatus(
                            isMe: widget.isMe,
                            isSeen: widget.message.isSeen,
                            timestamp: widget.message.timeStamp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWithAvatar(BuildContext context, BoxConstraints constraints) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        widget.withoutAvatar
            ? SizedBox(width: 30)
            : Avatar(imageUrl: widget.peer.imageUrl),
        SizedBox(width: 5),
        _buildWithoutAvatar(context, constraints),
      ],
    );
  }

  Widget chatItem(BuildContext context) {
    return Container(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          if (widget.message.type == '0') {
            return !widget.isMe
                ? _buildWithAvatar(context, constraints)
                : _buildWithoutAvatar(context, constraints);
          } else {
            return MediaBubble(
                message: widget.message,
                onReplied: widget.onReplyPressed,
                avatarImageUrl: widget.peer.imageUrl);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onLongPress: () => onLongPress(context),
      child: chatItem(context),
    );
  }

  void onLongPress(BuildContext context) async {
    final screenWidth = MediaQuery.of(context).size.width;
    RenderBox box = key.currentContext.findRenderObject();
    Offset position = box.localToGlobal(Offset.zero);
    double top = position.dy;
    double left = position.dx;
    double right = screenWidth - left;

    int selectedOption = await showMenu(
      context: context,
      items: [
        PopupMenuItem(
          child: Text('Forward'),
          value: 1,
        ),
        PopupMenuItem(
          child: Text('Reply'),
          value: 2,
        ),
      ],
      position: RelativeRect.fromLTRB(left, top, right, 0),
    );
    if (selectedOption != null) {
      if (selectedOption == 2) widget.onReplyPressed(widget.message);
    }
  }

  @override
  bool get wantKeepAlive => true;
}
