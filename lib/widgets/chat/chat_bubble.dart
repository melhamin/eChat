import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/providers/message.dart';
import 'package:whatsapp_clone/providers/person.dart';
import 'package:whatsapp_clone/widgets/image_view.dart';

class ChatBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final Person peer;
  final bool withoutImage;
  final bool last;
  final bool first;
  final bool middle;
  ChatBubble({
    @required this.message,
    @required this.isMe,
    @required this.peer,
    @required this.withoutImage,
    @required this.last,
    @required this.first,
    @required this.middle,
  });  

  String getTime() {
    int hour = message.timeStamp.hour;
    int min = message.timeStamp.minute;
    String hRes = hour <= 9 ? '0$hour' : hour.toString();
    String mRes = min <= 9 ? '0$min' : min.toString();

    return '$hRes:$mRes';
  }

  Widget _buildSeenStatus(BuildContext context) => Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text(
              getTime(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          if (isMe)
            Icon(
              Icons.done_all,
              color: (message.isSeen != null && message.isSeen)
                  ? Theme.of(context).accentColor
                  : Colors.white.withOpacity(0.35),
              size: 19,
            ),
        ],
      );

  Widget _buildBottomDetails(
          BuildContext context, BoxConstraints constraints) =>
      Material(
        color: Colors.transparent,
        child: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.all(5),
          height: 30,
          width: constraints.maxWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.6),
                Colors.black.withOpacity(0.01),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: _buildSeenStatus(context),
        ),
      );

  Widget _buildMediaText(BuildContext context, BoxConstraints constraints) {
    return Material(
      elevation: 0,
      color: Colors.transparent,
      child: _buildChatText(context, true),
    );
  }

  Widget _buildAvatar() => CircleAvatar(
        backgroundColor: Hexcolor('#202020'),
        backgroundImage: peer.imageUrl == null || peer.imageUrl == ''
            ? null
            : CachedNetworkImageProvider(peer.imageUrl),
        child: peer.imageUrl == null || peer.imageUrl == ''
            ? Icon(Icons.person, color: kBaseWhiteColor)
            : null,
        radius: 15,
      );

  void navToImageView(BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          ImageView(message.mediaUrl),
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

  Widget _buildMediaWithoutText(
      BuildContext context, MediaQueryData mq, BoxConstraints constraints) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            constraints: BoxConstraints(
              minWidth: mq.size.width * 0.7,
              maxWidth: mq.size.width * 0.7,
              minHeight: mq.size.height * 0.35,
              maxHeight: mq.size.height * 0.35,
            ),
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: message.mediaUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: _buildBottomDetails(context, constraints),
        ),
      ],
    );
  }

  Widget _buildMediaWithText(
      BuildContext context, MediaQueryData mq, BoxConstraints constraints) {
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
                  minWidth: mq.size.width * 0.7,
                  maxWidth: mq.size.width * 0.7,
                  minHeight: mq.size.height * 0.35,
                  maxHeight: mq.size.height * 0.35,
                ),
                child: CachedNetworkImage(
                  imageUrl: message.mediaUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: _buildMediaText(context, constraints),
            ),
          ],
        ),
        _buildSeenStatus(context),
      ],
    );
  }

  Widget _buildMediaBubble(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isMe) _buildAvatar(),
        if (!isMe) SizedBox(width: 5),
        Flexible(
          child: Hero(
            tag: message.mediaUrl,
            child: GestureDetector(
              onTap: () => navToImageView(context),
              child: Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Hexcolor('#303030')),
                    color: isMe ? Hexcolor('#202020') : Hexcolor('#121212'),
                  ),
                  padding: const EdgeInsets.all(5),
                  constraints: BoxConstraints(
                    minWidth: mq.size.width * 0.7,
                    maxWidth: mq.size.width * 0.7,
                    minHeight: mq.size.height * 0.35,
                    // maxHeight: mq.size.height * 0.35,
                  ),
                  child: LayoutBuilder(
                    builder: (cts, constraints) {
                      // print('content ======> ${message.content}');
                      if (message.content == null || message.content.isEmpty)
                        return _buildMediaWithoutText(context, mq, constraints);
                      return _buildMediaWithText(context, mq, constraints);
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatText(BuildContext context, [bool media = false]) {
    return SelectableText(
      message.content,
      style: TextStyle(
        fontSize: 17,
        color: kBaseWhiteColor,
      ),
    );
  }

  dynamic getRadius() {
    // print('Message =====> ${message.content} -- first--->$first, middle---> $middle, last ----> $last');
    if (first && !middle)
      return isMe
          ? BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(15),
            )
          : BorderRadius.only(
              bottomRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            );
    if (last && !middle)
      return isMe
          ? BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            )
          : BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            );
    if (middle)
      return isMe
          ? BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            )
          : BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            );

    return BorderRadius.circular(20
      // topLeft: Radius.circular(20),
      // bottomLeft: Radius.circular(20),
      // topRight: Radius.circular(20),
      // bottomRight: Radius.circular(20),
    );
  }

  Widget _buildWithoutAvatar(BuildContext context, BoxConstraints constraints) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: getRadius(),
        border: isMe ? null : Border.all(color: Hexcolor('#303030')),
        color: isMe ? Hexcolor('#303030') : Hexcolor('#121212'),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.end,
        runAlignment: WrapAlignment.end,
        alignment: WrapAlignment.end,
        spacing: 25,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 12),
            child: _buildChatText(context),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: _buildSeenStatus(context),
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
        withoutImage
            ? SizedBox(width: 30)
            : Flexible(                
                child: CircleAvatar(
                  backgroundColor: Hexcolor('#202020'),
                  backgroundImage: peer.imageUrl == null || peer.imageUrl == ''
                      ? null
                      : CachedNetworkImageProvider(peer.imageUrl),
                  child: peer.imageUrl == null || peer.imageUrl == ''
                      ? Icon(Icons.person, color: kBaseWhiteColor)
                      : null,
                  radius: 15,
                ),
              ),
        SizedBox(width: 5),
        Flexible(          
          child: _buildWithoutAvatar(context, constraints),
        ),
      ],
    );
  }

  Widget chatItem(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Container(      
      key: key,
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      margin: isMe ? EdgeInsets.only(left: 50) : EdgeInsets.only(right: 50),
      constraints: BoxConstraints(
        maxWidth: isMe ? mq.size.width * 0.8 : mq.size.width * 0.9,
      ),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          if (message.type == '0') {
            return !isMe
                ? _buildWithAvatar(context, constraints)
                : _buildWithoutAvatar(context, constraints);
          } else {
            return _buildMediaBubble(context);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // return CupertinoContextMenu(
    //   actions: [
    //     CupertinoContextMenuAction(
    //       child: Text('Reply'),
    //       onPressed: () {
    //         Navigator.of(context).pop();
    //       },
    //     ),
    //     CupertinoContextMenuAction(
    //       child: Text('Forward'),
    //       onPressed: () {
    //         Navigator.of(context).pop();
    //       },
    //     ),
    //   ],
    //   previewBuilder: (ctx, animation, wid)  {
    //     return chatItem(context);
    //   },
    // );
    return chatItem(context);
  }

  // void onLongPress(BuildContext context) {
  //   final screenWidth = MediaQuery.of(context).size.width;
  //   RenderBox box = key.currentContext.findRenderObject();
  //   Offset position = box.localToGlobal(Offset.zero);
  //   double top = position.dy;
  //   double left = position.dx;
  //   double right = screenWidth - left;

  //   print('dx =====> $left ---- dy ========> $top');
  //   showMenu(
  //     context: context,
  //     items: [
  //       PopupMenuItem(
  //         child: Text('Forward'),
  //       ),
  //       PopupMenuItem(
  //         child: Text('Reply'),
  //       ),
  //     ],
  //     position: RelativeRect.fromLTRB(left, top, right, 0),
  //   );
  // }
}
