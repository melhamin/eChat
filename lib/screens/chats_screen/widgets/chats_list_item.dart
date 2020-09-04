import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/models/chat_data.dart';
import 'package:whatsapp_clone/models/message.dart';
import 'package:whatsapp_clone/providers/chat.dart';
import 'package:whatsapp_clone/screens/chats_screen/chat_item_screen.dart';
import 'package:whatsapp_clone/screens/chats_screen/widgets/avatar.dart';
import 'package:whatsapp_clone/services/db.dart';

class ChatListItem extends StatefulWidget {
  final ChatData chatData;

  ChatListItem({@required this.chatData})
      : super(key: GlobalKey<_ChatListItemState>());

  @override
  _ChatListItemState createState() => _ChatListItemState();
}

class _ChatListItemState extends State<ChatListItem> {
  // GlobalKey key = GlobalKey<_ChatItemState>();
  DB db;
  List<dynamic> unreadMessages = [];
  // int unreadCount;
  Stream<QuerySnapshot> _stream;

  @override
  void initState() {
    super.initState();
    db = DB();
    _stream = db.getSnapshotsWithLimit(widget.chatData.groupId, 1);
  }

  String getDate() {
    DateTime date = DateTime.now();
    return DateFormat.yMd(date).toString();
  }

  String formatTime(Message message) {
    int hour = message.sendDate.hour;
    int min = message.sendDate.minute;
    String hRes = hour <= 9 ? '0$hour' : hour.toString();
    String mRes = min <= 9 ? '0$min' : min.toString();
    return '$hRes:$mRes';
  }

  // add new messages to ChatData and update unread count
  void _addNewMessages(Message newMsg) {
    final isIos = Theme.of(context).platform == TargetPlatform.iOS;
    if (widget.chatData.messages.isEmpty ||
        newMsg.sendDate.isAfter(widget.chatData.messages[0].sendDate)) {
      widget.chatData.addMessage(newMsg);

      if (newMsg.fromId != widget.chatData.userId) {
        widget.chatData.unreadCount++;

        // play notification sound
        // if(widget.initChatData.messages.isNotEmpty && widget.initChatData.messages[0].sendDate != newMsg.sendDate)
        // if(isIos)
        //   Utils.playSound('mp3/notificationIphone.mp3');
        // else Utils.playSound('mp3/notificationAndroid.mp3');

        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          Provider.of<Chat>(context, listen: false)
              .bringChatToTop(widget.chatData.groupId);
          setState(() {});
        });
      }
    }
  }

  void navToChatScreen() {
    widget.chatData.unreadCount = 0;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatItemScreen(widget.chatData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final peer = widget.chatData.peer;
    return Material(
      key: UniqueKey(),
      color: Colors.transparent,
      child: InkWell(
        // splashColor: Colors.transparent,
        highlightColor: kBlackColor2,
        onTap: navToChatScreen,
        child: Container(
          height: 80,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: Avatar(
              imageUrl: widget.chatData.peer.imageUrl,
              color: kBlackColor3,
              radius: 27,
            ),
            title: Text(peer.username, style: kChatItemTitleStyle),
            subtitle: _PreviewText(
              stream: _stream,
              onNewMessageRecieved: _addNewMessages,
              peerId: widget.chatData.peerId,
              userId: widget.chatData.userId,
            ),
            trailing: _UnreadCount(
              unreadCount: widget.chatData.unreadCount,
              lastMessage: widget.chatData.messages[0],
            ),
          ),
        ),
      ),
    );
  }
}

class _UnreadCount extends StatelessWidget {
  const _UnreadCount({
    Key key,
    @required this.unreadCount,
    this.lastMessage,
  }) : super(key: key);

  final int unreadCount;
  final Message lastMessage;

  String formatTime(Message message) {
    int hour = message.sendDate.hour;
    int min = message.sendDate.minute;
    String hRes = hour <= 9 ? '0$hour' : hour.toString();
    String mRes = min <= 9 ? '0$min' : min.toString();
    return '$hRes:$mRes';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (lastMessage != null)
          Text(formatTime(lastMessage), style: kChatItemSubtitleStyle),
        if (unreadCount != null && unreadCount > 0) ...[
          SizedBox(height: 5),
          Container(
            height: 25,
            width: 25,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Theme.of(context).accentColor,
            ),
            child: Center(
              child: Text(
                '$unreadCount',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ]
      ],
    );
  }
}

class _PreviewText extends StatelessWidget {
  const _PreviewText({
    Key key,
    @required this.stream,
    this.peerId,
    this.userId,
    this.onNewMessageRecieved,
  }) : super(key: key);

  final Stream<QuerySnapshot> stream;
  final String peerId;
  final String userId;
  final Function onNewMessageRecieved;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (ctx, snapshots) {
        if (snapshots.connectionState == ConnectionState.waiting)
          return Container(height: 0, width: 0);
        else {
          if (snapshots.data.documents.isNotEmpty) {
            final snapshot = snapshots.data.documents[0];
            Message newMsg = Message.fromJson(snapshot.data);
            onNewMessageRecieved(newMsg);
            return Row(
              children: [
                newMsg.type == MessageType.Media
                    ? Container(
                        child: Row(
                          children: [
                            Icon(
                              newMsg.mediaType == MediaType.Photo
                                  ? Icons.photo_camera
                                  : Icons.videocam,
                              size:
                                  newMsg.mediaType == MediaType.Photo ? 15 : 20,
                              color: Colors.white.withOpacity(0.45),
                            ),
                            SizedBox(width: 8),
                            Text(
                                newMsg.mediaType == MediaType.Photo
                                    ? 'Photo'
                                    : 'Video',
                                style: kChatItemSubtitleStyle)
                          ],
                        ),
                      )
                    : Flexible(
                        child: Text(newMsg.content,
                            style: kChatItemSubtitleStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                if (newMsg.fromId != peerId) ...[
                  SizedBox(width: 5),
                  Icon(
                    Icons.done_all,
                    size: 19,
                    color: newMsg.isSeen
                        ? Theme.of(context).accentColor
                        : Colors.white.withOpacity(0.7),
                  ),
                ],
              ],
            );
          } else
            return Container(height: 0, width: 0);
        }
      },
    );
  }
}
